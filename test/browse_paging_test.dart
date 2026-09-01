import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tv_track/core/providers.dart';
import 'package:tv_track/data/tmdb/catalog_item.dart';
import 'package:tv_track/data/tmdb/tmdb_api.dart';
import 'package:tv_track/features/discover/browse_controller.dart';

import 'support/fake_tmdb.dart';

void main() {
  /// Serves the given ids per TMDB page number. Any page not listed is empty,
  /// which is how TMDB signals the end of a category.
  FakeTmdbAdapter pagedAdapter(Map<int, List<int>> pages) => FakeTmdbAdapter((
    request,
  ) {
    final page = request.queryParameters['page'] as int;
    return {
      'results': [for (final id in pages[page] ?? const <int>[]) tvResult(id)],
    };
  });

  ProviderContainer containerWith(
    FakeTmdbAdapter adapter, {
    Set<int> tracked = const {},
  }) => ProviderContainer.test(
    overrides: [
      tmdbApiProvider.overrideWithValue(fakeTmdbApi(adapter)),
      trackedShowIdsByTmdbProvider.overrideWithValue({
        for (final id in tracked) id: id,
      }),
    ],
  );

  final grid = categoryGridProvider(
    kind: MediaKind.tv,
    sort: CatalogSort.popular,
  );

  group('CategoryGrid', () {
    test('titles already in the library are filtered out', () async {
      final adapter = pagedAdapter({
        1: [1, 2, 3],
      });
      final container = containerWith(adapter, tracked: {2});

      final items = await container.read(grid.future);

      expect(items.map((e) => e.tmdbId), [1, 3]);
    });

    test('a page emptied by filtering pulls the next one', () async {
      final adapter = pagedAdapter({
        1: [1, 2],
        2: [3],
      });
      final container = containerWith(adapter, tracked: {1, 2});

      final items = await container.read(grid.future);

      expect(items.map((e) => e.tmdbId), [3]);
      expect(adapter.pagesRequested, [1, 2]);
    });

    test('a fully watched genre gives up instead of looping', () async {
      final adapter = pagedAdapter({
        1: [1],
        2: [2],
        3: [3],
        4: [4],
      });
      final container = containerWith(adapter, tracked: {1, 2, 3, 4});

      expect(await container.read(grid.future), isEmpty);
      expect(adapter.pagesRequested, [1, 2, 3]);
    });

    test('an entry TMDB repeats on the next page is kept once', () async {
      final adapter = pagedAdapter({
        1: [1, 2],
        2: [2, 3],
      });
      final container = containerWith(adapter);
      container.listen(grid, (_, _) {});

      await container.read(grid.future);
      await container.read(grid.notifier).loadMore();

      expect(container.read(grid).value!.map((e) => e.tmdbId), [1, 2, 3]);
    });

    test('an exhausted category stops asking for pages', () async {
      final adapter = pagedAdapter({
        1: [1],
      });
      final container = containerWith(adapter);
      container.listen(grid, (_, _) {});

      await container.read(grid.future);
      await container.read(grid.notifier).loadMore();
      final requestedSoFar = adapter.pagesRequested.length;
      await container.read(grid.notifier).loadMore();

      expect(adapter.pagesRequested.length, requestedSoFar);
      expect(container.read(grid).value!.map((e) => e.tmdbId), [1]);
    });
  });
}
