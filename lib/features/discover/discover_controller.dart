import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers.dart';
import '../../data/models/show.dart';
import '../../data/tmdb/tmdb_api.dart';
import '../../data/tvmaze/enrichment.dart';

part 'discover_controller.g.dart';

/// File de cartes du deck Découverte : séries populaires / tendances / en
/// diffusion (TMDB, FR), débarrassées de celles déjà suivies ou déjà swipées.
@riverpod
class DiscoverDeck extends _$DiscoverDeck {
  int _page = 0;
  final _loadedIds = <int>{};

  @override
  Future<List<TmdbTv>> build() async {
    // Recharge quand le suivi ou l'historique de swipe change.
    ref.watch(showsProvider);
    ref.watch(discoverSeenIdsProvider);
    return _loadMore(initial: true);
  }

  /// Ensemble des IDs TMDB à exclure : séries déjà suivies + déjà swipées.
  Set<int> get _excluded {
    final tracked = (ref.read(showsProvider).value ?? const [])
        .map((s) => s.tmdbId)
        .whereType<int>()
        .toSet();
    final seen = ref.read(discoverSeenIdsProvider).value ?? const <int>{};
    return {...tracked, ...seen};
  }

  Future<List<TmdbTv>> _loadMore({bool initial = false}) async {
    final tmdb = ref.read(tmdbApiProvider);
    if (tmdb == null) return const [];

    _page++;
    // Mélange les trois sources pour un deck varié (populaires en volume,
    // tendances pour la fraîcheur, on-the-air pour les séries du moment).
    final batches = await Future.wait([
      tmdb.trendingTv(page: _page),
      tmdb.popularTv(page: _page),
      tmdb.onTheAirTv(page: _page),
    ]);

    final excluded = _excluded;
    final fresh = <TmdbTv>[];
    for (final card in [
      for (var i = 0; i < 20; i++)
        for (final b in batches)
          if (i < b.length) b[i], // interleave par rang
    ]) {
      if (excluded.contains(card.id) || !_loadedIds.add(card.id)) continue;
      fresh.add(card);
    }
    final current = initial ? <TmdbTv>[] : (state.value ?? const []);
    return [...current, ...fresh];
  }

  /// « Envie » : marque vu, rattache la série au suivi (via TVmaze) et retire
  /// la carte du deck.
  Future<void> like(TmdbTv card) async {
    _removeAndSeen(card, liked: true);
    final repo = ref.read(trackingRepositoryProvider);
    final tmdb = ref.read(tmdbApiProvider);
    if (repo == null || tmdb == null) return;

    try {
      final tvdbId = await tmdb.tvdbIdByTmdb(card.id);
      if (tvdbId == null) return; // pas rattachable à TVmaze
      // Déjà suivie ? on ne recrée pas.
      final existing = (ref.read(showsProvider).value ?? const [])
          .any((s) => s.tvdbId == tvdbId);
      if (existing) return;

      var show = Show(tvdbId: tvdbId, title: card.name, tmdbId: card.id);
      // Enrichissement immédiat : poster, saisons, épisodes, résumé.
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
      // Rattachement best-effort : la carte reste marquée vue quoi qu'il arrive.
    }
  }

  /// « Passer » : marque vu et retire la carte, sans autre effet.
  Future<void> pass(TmdbTv card) async => _removeAndSeen(card, liked: false);

  void _removeAndSeen(TmdbTv card, {required bool liked}) {
    ref.read(trackingRepositoryProvider)?.markDiscoverSeen(card.id, liked: liked);
    final deck = <TmdbTv>[...?state.value]
      ..removeWhere((c) => c.id == card.id);
    state = AsyncData(deck);
    if (deck.length < 5) {
      // Recharge en tâche de fond quand la pile s'amenuise.
      _loadMore().then((more) {
        if (more.length > deck.length) state = AsyncData(more);
      }).catchError((_) {});
    }
  }
}
