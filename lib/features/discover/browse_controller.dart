import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers.dart';
import '../../data/tmdb/catalog_item.dart';
import '../../data/tmdb/tmdb_api.dart';

part 'browse_controller.g.dart';

@riverpod
Future<List<Genre>> catalogGenres(Ref ref, MediaKind kind) async {
  final tmdb = ref.watch(tmdbApiProvider);
  if (tmdb == null) return const [];
  return tmdb.genres(kind);
}

/// TMDB ids already in the library for one media kind. Watched rather than
/// read, so adding a title makes it disappear from Browse straight away.
Set<int> _tracked(Ref ref, MediaKind kind) =>
    (kind.isTv
            ? ref.watch(trackedShowIdsByTmdbProvider)
            : ref.watch(trackedMovieIdsByTmdbProvider))
        .keys
        .toSet();

/// One Browse rail: first page only. A null [genreId] means this week's
/// trending entries.
@riverpod
Future<List<CatalogItem>> catalogRow(
  Ref ref, {
  required MediaKind kind,
  int? genreId,
}) async {
  final tmdb = ref.watch(tmdbApiProvider);
  if (tmdb == null) return const [];
  final tracked = _tracked(ref, kind);
  final items = genreId == null
      ? await tmdb.trending(kind)
      : await tmdb.discover(kind, genreId: genreId);
  return items.where((e) => !tracked.contains(e.tmdbId)).toList();
}

/// Paginated, sortable category grid backing the infinite-scrolling screen.
@riverpod
class CategoryGrid extends _$CategoryGrid {
  /// How many extra pages to pull when filtering empties a page. Without this,
  /// a genre the user has largely worked through returns nothing visible and
  /// the scroll never reaches the trigger for the next load.
  static const _maxPagesPerLoad = 3;

  int _page = 0;
  bool _end = false;

  @override
  Future<List<CatalogItem>> build({
    required MediaKind kind,
    required CatalogSort sort,
    int? genreId,
  }) async {
    return _fetchVisible(<int>{});
  }

  /// Fetches pages until at least one entry survives filtering, or the source
  /// runs out. [exclude] holds ids already on screen, on top of the library.
  Future<List<CatalogItem>> _fetchVisible(Set<int> exclude) async {
    final tmdb = ref.read(tmdbApiProvider);
    if (tmdb == null) return const [];
    final tracked = _tracked(ref, kind);

    final out = <CatalogItem>[];
    for (var i = 0; i < _maxPagesPerLoad && !_end; i++) {
      _page++;
      final items = await tmdb.discover(
        kind,
        sort: sort,
        genreId: genreId,
        page: _page,
      );
      if (items.isEmpty) {
        _end = true;
        break;
      }
      for (final item in items) {
        // TMDB repeats entries across pages, so dedupe as well as filter.
        if (tracked.contains(item.tmdbId) || !exclude.add(item.tmdbId)) {
          continue;
        }
        out.add(item);
      }
      if (out.isNotEmpty) break;
    }
    return out;
  }

  Future<void> loadMore() async {
    if (_end || state.isLoading) return;
    final current = state.value ?? const <CatalogItem>[];
    final more = await _fetchVisible(current.map((e) => e.tmdbId).toSet());
    if (more.isNotEmpty) state = AsyncData([...current, ...more]);
  }
}
