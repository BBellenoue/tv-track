import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers.dart';
import '../../data/tmdb/catalog_item.dart';

part 'search_controller.g.dart';

/// TMDB search across both media kinds: shows first, then movies, each in the
/// order TMDB returns them. Entries without a poster are dropped, since the
/// result rows are poster-led.
@riverpod
Future<List<CatalogItem>> tmdbSearch(Ref ref, String query) async {
  final tmdb = ref.watch(tmdbApiProvider);
  if (tmdb == null || query.trim().length < 2) return const [];
  final results = await Future.wait([
    tmdb.search(MediaKind.tv, query),
    tmdb.search(MediaKind.movie, query),
  ]);
  return [
    for (final list in results)
      for (final item in list)
        if (item.posterPath != null) item,
  ];
}
