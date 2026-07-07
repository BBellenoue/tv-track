import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers.dart';
import '../../data/models/show.dart';
import '../../data/tvdb/enrichment.dart';

part 'refresh_controller.g.dart';

/// Rafraîchissement incrémental des métadonnées depuis l'app.
///
/// Deux déclencheurs :
/// - **automatique** (ouverture de l'app) : séries non terminées dont les
///   métas datent de plus de 24 h, **plus** toute fiche incomplète
///   (`isIncomplete` : contenu manquant ou resté en anglais) — au plus une
///   tentative / 24 h ;
/// - **manuel** (pull-to-refresh) : idem, mais on force les fiches incomplètes
///   même si elles ne sont pas encore périmées.
///
/// Chaque série est enrichie via **TheTVDB** (structure, titres/résumés FR,
/// images, dates, statut, chaîne) puis TMDB pour les seules plateformes de
/// streaming (voir [enrichShowFromTvdb]). Les séries introuvables côté TheTVDB
/// sont tamponnées pour ne pas boucler. Lots de 8, incomplètes d'abord.
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

    final tvdb = ref.read(tvdbApiProvider);
    if (tvdb == null) return; // pas de clé TheTVDB → enrichissement désactivé

    final cutoff = DateTime.now().subtract(_staleAfter);
    bool isStale(Show s) =>
        s.metaRefreshedAt == null || s.metaRefreshedAt!.isBefore(cutoff);
    bool eligible(Show s) => s.isIncomplete
        // Fiche incomplète (contenu manquant / resté en anglais) : au pull
        // manuel on force, sinon au plus une tentative / 24 h.
        ? (force || isStale(s))
        // Entretien courant : séries en cours dont les métas sont périmées.
        : (!s.isEnded && isStale(s));

    final batch = shows.where(eligible).sorted((a, b) {
      // Les fiches incomplètes passent en tête (le problème à corriger).
      final ra = a.isIncomplete ? 0 : 1;
      final rb = b.isIncomplete ? 0 : 1;
      if (ra != rb) return ra - rb;
      return (b.lastWatchedAt ?? DateTime(1970))
          .compareTo(a.lastWatchedAt ?? DateTime(1970));
    }).take(_batchSize).toList();
    if (batch.isEmpty) return;

    _running = true;
    state = true;
    final tmdb = ref.read(tmdbApiProvider);
    try {
      for (final show in batch) {
        try {
          final merged = await enrichShowFromTvdb(show, tvdb, tmdb: tmdb);
          await repo.saveShow(merged);
        } catch (_) {
          // Réseau/API en erreur : on passe à la suivante, retentée au
          // prochain rafraîchissement.
        }
        // Politesse envers l'API entre deux séries.
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } finally {
      _running = false;
      state = false;
    }
  }
}
