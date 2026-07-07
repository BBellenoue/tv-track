import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers.dart';
import '../../data/models/show.dart';
import '../../data/tvmaze/enrichment.dart';

part 'refresh_controller.g.dart';

/// Rafraîchissement incrémental des métadonnées depuis l'app.
///
/// Deux déclencheurs :
/// - **automatique** (ouverture de l'app) : séries non terminées dont les
///   métas datent de plus de 24 h, **plus** toute série dont l'affichage est
///   resté en anglais (`needsFrenchRepair`) — au plus une tentative / 24 h ;
/// - **manuel** (pull-to-refresh) : idem, mais on force les réparations FR
///   même si elles ne sont pas encore périmées.
///
/// Chaque série est enrichie via TVmaze (structure, dates, vignettes) **puis**
/// TMDB en français (synopsis, poster, plateformes, titres/résumés d'épisodes),
/// pour ne jamais rebasculer l'affichage en anglais. Les séries en échec de
/// réparation (TMDB muet) sont tamponnées pour ne pas boucler à chaque
/// ouverture. Lots de 8, réparations d'abord, pour respecter le rate limit
/// TVmaze (~20 req/10 s).
@riverpod
class MetadataRefresh extends _$MetadataRefresh {
  static const _batchSize = 8;
  static const _staleAfter = Duration(hours: 24);

  bool _running = false;

  @override
  bool build() => false; // true = rafraîchissement en cours

  Future<void> run({bool force = false}) async {
    if (_running) return;
    final repo = ref.read(trackingRepositoryProvider);
    final shows = ref.read(showsProvider).value;
    if (repo == null || shows == null) return;

    final cutoff = DateTime.now().subtract(_staleAfter);
    bool isStale(Show s) =>
        s.metaRefreshedAt == null || s.metaRefreshedAt!.isBefore(cutoff);
    bool eligible(Show s) => s.needsFrenchRepair
        // Réparation FR : au pull manuel on force, sinon une fois / 24 h.
        ? (force || isStale(s))
        // Entretien courant : séries en cours dont les métas sont périmées.
        : (!s.isEnded && isStale(s));

    final batch = shows.where(eligible).sorted((a, b) {
      // Les fiches restées en anglais passent en tête (le problème à corriger).
      final ra = a.needsFrenchRepair ? 0 : 1;
      final rb = b.needsFrenchRepair ? 0 : 1;
      if (ra != rb) return ra - rb;
      return (b.lastWatchedAt ?? DateTime(1970))
          .compareTo(a.lastWatchedAt ?? DateTime(1970));
    }).take(_batchSize).toList();
    if (batch.isEmpty) return;

    _running = true;
    state = true;
    final tvmaze = ref.read(tvmazeApiProvider);
    final tmdb = ref.read(tmdbApiProvider);
    try {
      for (final show in batch) {
        try {
          final meta = await tvmaze.lookupByTvdb(show.tvdbId);
          await Future.delayed(const Duration(milliseconds: 600));
          if (meta == null) {
            // Inconnue de TVmaze : on tamponne pour ne pas réessayer à chaque pull.
            await repo.saveShow(show.copyWith(metaRefreshedAt: DateTime.now()));
            continue;
          }
          final episodes = await tvmaze.episodes(meta.id);
          await Future.delayed(const Duration(milliseconds: 600));
          var merged = mergeTvmaze(show, meta, episodes, now: DateTime.now());
          // Repasse le synopsis, le poster et les épisodes en français.
          if (tmdb != null) {
            merged = await applyTmdbFrench(merged, tmdb);
          }
          await repo.saveShow(merged);
        } catch (_) {
          // Réseau/API en erreur : on passe à la suivante, retentée au
          // prochain rafraîchissement.
        }
      }
    } finally {
      _running = false;
      state = false;
    }
  }
}
