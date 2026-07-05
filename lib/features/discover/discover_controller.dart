import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers.dart';
import '../../data/models/show.dart';
import '../../data/tmdb/tmdb_api.dart';
import '../../data/tvmaze/enrichment.dart';

part 'discover_controller.g.dart';

/// File de cartes du deck Découverte : séries populaires / tendances / en
/// diffusion (TMDB, FR), débarrassées de celles déjà suivies ou déjà swipées.
///
/// La file ne se reconstruit PAS à chaque swipe : l'avancement est piloté par
/// un curseur local dans l'UI. Ici on ne fait qu'alimenter la file (pagination)
/// et persister l'historique de swipe. Cela évite tout clignotement au moment
/// où une carte quitte l'écran.
@riverpod
class DiscoverDeck extends _$DiscoverDeck {
  int _page = 0;
  final _loadedIds = <int>{};
  final _excluded = <int>{};

  @override
  Future<List<TmdbTv>> build() async {
    // Lu une seule fois (pas `watch`) pour ne pas se reconstruire au swipe.
    final tracked = (ref.read(showsProvider).value ?? const [])
        .map((s) => s.tmdbId)
        .whereType<int>();
    final seen = ref.read(discoverSeenIdsProvider).value ?? const <int>{};
    _excluded
      ..addAll(tracked)
      ..addAll(seen);
    return _fetch();
  }

  Future<List<TmdbTv>> _fetch() async {
    final tmdb = ref.read(tmdbApiProvider);
    if (tmdb == null) return const [];

    _page++;
    // Mélange trois sources : populaires (volume), tendances (fraîcheur),
    // en diffusion (séries du moment).
    final batches = await Future.wait([
      tmdb.trendingTv(page: _page),
      tmdb.popularTv(page: _page),
      tmdb.onTheAirTv(page: _page),
    ]);

    final fresh = <TmdbTv>[];
    for (final card in [
      for (var i = 0; i < 20; i++)
        for (final b in batches)
          if (i < b.length) b[i], // interleave par rang
    ]) {
      if (_excluded.contains(card.id) || !_loadedIds.add(card.id)) continue;
      fresh.add(card);
    }
    return fresh;
  }

  /// Alimente la file quand le curseur approche de la fin. Ajoute en queue
  /// sans jamais toucher aux cartes déjà présentes.
  Future<void> loadMore() async {
    try {
      final more = await _fetch();
      if (more.isNotEmpty) {
        state = AsyncData([...?state.value, ...more]);
      }
    } catch (_) {
      // Réseau : on réessaiera au prochain appel.
    }
  }

  /// « Envie » : marque vu et rattache la série au suivi (via TVmaze).
  Future<void> like(TmdbTv card) async {
    _markSeen(card, liked: true);
    final repo = ref.read(trackingRepositoryProvider);
    final tmdb = ref.read(tmdbApiProvider);
    if (repo == null || tmdb == null) return;

    try {
      final tvdbId = await tmdb.tvdbIdByTmdb(card.id);
      if (tvdbId == null) return; // pas rattachable à TVmaze
      final existing = (ref.read(showsProvider).value ?? const [])
          .any((s) => s.tvdbId == tvdbId);
      if (existing) return;

      var show = Show(tvdbId: tvdbId, title: card.name, tmdbId: card.id);
      final tvmaze = ref.read(tvmazeApiProvider);
      final meta = await tvmaze.lookupByTvdb(tvdbId);
      if (meta != null) {
        final episodes = await tvmaze.episodes(meta.id);
        show = mergeTvmaze(show, meta, episodes, now: DateTime.now());
      }
      show = show.copyWith(
        providers: await tmdb.tvProviders(card.id).catchError((_) => <String>[]),
      );
      await repo.saveShow(show);
    } catch (_) {
      // Rattachement best-effort ; la carte reste marquée vue quoi qu'il arrive.
    }
  }

  /// « Passer » : marque vu, sans autre effet.
  Future<void> pass(TmdbTv card) async => _markSeen(card, liked: false);

  void _markSeen(TmdbTv card, {required bool liked}) {
    _excluded.add(card.id);
    ref.read(trackingRepositoryProvider)?.markDiscoverSeen(card.id, liked: liked);
  }
}
