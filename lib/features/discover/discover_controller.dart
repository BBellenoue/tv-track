import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers.dart';
import '../../data/models/movie.dart';
import '../../data/models/show.dart';
import '../../data/tmdb/catalog_item.dart';
import '../../data/tmdb/tmdb_api.dart';
import 'library_add.dart';

part 'discover_controller.g.dart';

/// TMDB carries plenty of titles rated 9/10 by nine people.
const deckMinVotes = 200;

/// Recommendations served between two serendipity cards.
const deckSerendipityEvery = 3;

/// Orders one round of candidates.
///
/// [fromSeeds] is one list per seed title, [unseeded] the trending pool that
/// owes nothing to the profile. A title several seeds point at outranks one a
/// single seed mentions, ties break on rating, and the unseeded pool is dealt
/// in one card every [deckSerendipityEvery] so the deck keeps a way out of the
/// profile. Anything in [excluded] or short of [deckMinVotes] is dropped.
List<CatalogItem> rankDeck({
  required List<List<CatalogItem>> fromSeeds,
  required List<CatalogItem> unseeded,
  required Set<int> excluded,
}) {
  final hits = <int, int>{};
  final cards = <int, CatalogItem>{};
  for (final batch in fromSeeds) {
    for (final card in batch) {
      cards.putIfAbsent(card.tmdbId, () => card);
      hits[card.tmdbId] = (hits[card.tmdbId] ?? 0) + 1;
    }
  }
  for (final card in unseeded) {
    cards.putIfAbsent(card.tmdbId, () => card);
  }

  final keep = cards.values
      .where((c) => !excluded.contains(c.tmdbId))
      .where((c) => c.voteCount >= deckMinVotes);

  final recommended = keep.where((c) => hits.containsKey(c.tmdbId)).toList()
    ..sort((a, b) {
      final byHits = hits[b.tmdbId]!.compareTo(hits[a.tmdbId]!);
      return byHits != 0
          ? byHits
          : (b.voteAverage ?? 0).compareTo(a.voteAverage ?? 0);
    });
  final serendipity = keep.where((c) => !hits.containsKey(c.tmdbId)).toList();

  final out = <CatalogItem>[];
  var r = 0, s = 0;
  while (r < recommended.length || s < serendipity.length) {
    for (var k = 0; k < deckSerendipityEvery && r < recommended.length; k++) {
      out.add(recommended[r++]);
    }
    if (s < serendipity.length) out.add(serendipity[s++]);
  }
  return out;
}

/// Card queue behind the swipe deck for one media kind.
///
/// Suggestions are drawn from what the library says was actually watched: the
/// most-watched titles seed TMDB's "also watched" lists, and a title several
/// seeds point at outranks one a single seed mentions. A quarter of the deck
/// is trending regardless of the profile, so the suggestions do not close in
/// on themselves.
///
/// The queue deliberately does not rebuild on each swipe — the UI holds a
/// cursor instead, which keeps a card from flickering as it flies out.
@riverpod
class DiscoverDeck extends _$DiscoverDeck {
  /// Seeds queried per round. Each one is a request, so this trades breadth
  /// against how long the deck takes to appear.
  static const _seedsPerRound = 6;

  int _page = 0;
  int _seedCursor = 0;
  final _loadedIds = <int>{};
  final _excluded = <int>{}; // tracked or already swiped, for this kind
  final _seeds = <int>[]; // tmdbIds of the titles worth recommending from

  @override
  Future<List<CatalogItem>> build(MediaKind kind) async {
    // Read once rather than watched, so a swipe does not rebuild the queue.
    // Straight from the repository rather than through the stream providers:
    // those are autoDispose, so their first value has to be awaited to be of
    // any use, and awaiting it races their disposal.
    final repo = ref.read(trackingRepositoryProvider);
    if (repo != null) {
      final Iterable<int?> tracked;
      if (kind.isTv) {
        final shows = await repo.watchShows().first;
        tracked = shows.map((s) => s.tmdbId);
        _seeds.addAll(_showSeeds(shows));
      } else {
        final movies = await repo.watchMovies().first;
        tracked = movies.map((m) => m.tmdbId);
        _seeds.addAll(_movieSeeds(movies));
      }
      final prefix = '${kind.path}_';
      final seen = (await repo.watchSeenKeys().first)
          .where((k) => k.startsWith(prefix))
          .map((k) => int.tryParse(k.substring(prefix.length)));
      _excluded
        ..addAll(tracked.whereType<int>())
        ..addAll(seen.whereType<int>());
    }
    return _fetch(kind);
  }

  /// Watched episodes as the affinity signal: `isFavorite` exists but goes
  /// unused, so it says nothing. Shuffled so two sessions do not open on the
  /// same suggestions.
  List<int> _showSeeds(List<Show> shows) {
    final ranked = shows.where((s) => s.watchedEpisodes > 0).toList()
      ..sort((a, b) => b.watchedEpisodes - a.watchedEpisodes);
    return _shuffledTop(ranked.map((s) => s.tmdbId));
  }

  List<int> _movieSeeds(List<Movie> movies) {
    final ranked = movies.where((m) => m.watched).toList()
      ..sort(
        (a, b) =>
            (b.watchedAt ?? DateTime(0)).compareTo(a.watchedAt ?? DateTime(0)),
      );
    return _shuffledTop(ranked.map((m) => m.tmdbId));
  }

  List<int> _shuffledTop(Iterable<int?> ids) =>
      ids.whereType<int>().take(30).toList()..shuffle(Random());

  Future<List<CatalogItem>> _fetch(MediaKind kind) async {
    final tmdb = ref.read(tmdbApiProvider);
    if (tmdb == null) return const [];
    _page++;

    final round = [
      for (var i = 0; i < _seedsPerRound && _seeds.isNotEmpty; i++)
        _seeds[(_seedCursor + i) % _seeds.length],
    ];
    _seedCursor += round.length;

    // One failing seed must not empty the deck.
    final batches = await Future.wait([
      for (final id in round) _orEmpty(tmdb.recommendations(kind, id)),
      _orEmpty(tmdb.trending(kind, page: _page)),
      if (round.isEmpty)
        _orEmpty(tmdb.discover(kind, sort: CatalogSort.popular, page: _page)),
    ]);

    final ranked = rankDeck(
      fromSeeds: batches.take(round.length).toList(),
      unseeded: batches.skip(round.length).expand((b) => b).toList(),
      excluded: _excluded,
    );
    return [
      for (final card in ranked)
        if (_loadedIds.add(card.tmdbId)) card,
    ];
  }

  Future<List<CatalogItem>> _orEmpty(Future<List<CatalogItem>> call) =>
      call.catchError((_) => const <CatalogItem>[]);

  Future<void> loadMore() async {
    try {
      final more = await _fetch(kind);
      if (more.isNotEmpty) state = AsyncData([...?state.value, ...more]);
    } catch (_) {}
  }

  Future<void> like(CatalogItem card) async {
    _markSeen(card, liked: true);
    await ref.read(libraryAddProvider.notifier).add(card);
  }

  Future<void> pass(CatalogItem card) async => _markSeen(card, liked: false);

  void _markSeen(CatalogItem card, {required bool liked}) {
    _excluded.add(card.tmdbId);
    ref
        .read(trackingRepositoryProvider)
        ?.markDiscoverSeen('${card.kind.path}_${card.tmdbId}', liked: liked);
  }
}
