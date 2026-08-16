import 'package:flutter_test/flutter_test.dart';
import 'package:tv_track/data/tmdb/catalog_item.dart';
import 'package:tv_track/data/tmdb/tmdb_api.dart';

void main() {
  group('CatalogItem.fromJson', () {
    test('a show is titled from name, a movie from title', () {
      final show = CatalogItem.fromJson({
        'id': 1,
        'name': 'Berlin',
        'original_name': 'Berlín',
      }, MediaKind.tv);
      final movie = CatalogItem.fromJson({
        'id': 2,
        'title': 'Dune',
        'original_title': 'Dune: Part One',
      }, MediaKind.movie);

      expect(show.title, 'Berlin');
      expect(movie.title, 'Dune');
    });

    test('an untranslated entry falls back to its original title', () {
      final show = CatalogItem.fromJson({
        'id': 1,
        'original_name': 'Berlín',
      }, MediaKind.tv);
      final movie = CatalogItem.fromJson({
        'id': 2,
        'original_title': 'Dune: Part One',
      }, MediaKind.movie);

      expect(show.title, 'Berlín');
      expect(movie.title, 'Dune: Part One');
    });

    test('an entry with no title at all maps rather than throwing', () {
      expect(CatalogItem.fromJson({'id': 1}, MediaKind.tv).title, '');
    });

    test('each kind reads its own date field', () {
      final show = CatalogItem.fromJson({
        'id': 1,
        'first_air_date': '2023-12-25',
        'release_date': '1999-01-01',
      }, MediaKind.tv);
      final movie = CatalogItem.fromJson({
        'id': 2,
        'first_air_date': '1999-01-01',
        'release_date': '2021-09-15',
      }, MediaKind.movie);

      expect(show.date, '2023-12-25');
      expect(show.year, 2023);
      expect(movie.date, '2021-09-15');
      expect(movie.year, 2021);
    });

    test('year is null when TMDB has no usable date', () {
      for (final date in [null, '', '20']) {
        final item = CatalogItem.fromJson({
          'id': 1,
          'first_air_date': date,
        }, MediaKind.tv);
        expect(item.year, isNull, reason: 'date: $date');
      }
    });

    test('an empty overview is null, so the UI can drop the block', () {
      final item = CatalogItem.fromJson({
        'id': 1,
        'overview': '',
      }, MediaKind.tv);
      expect(item.overview, isNull);
    });

    test('a whole rating comes back as a double', () {
      final item = CatalogItem.fromJson({
        'id': 1,
        'vote_average': 8,
      }, MediaKind.tv);
      expect(item.voteAverage, 8.0);
    });

    test('image urls are null without a path', () {
      final item = CatalogItem.fromJson({'id': 1}, MediaKind.tv);
      expect(item.posterUrl, isNull);
      expect(item.posterUrlSmall, isNull);
      expect(item.backdropUrl, isNull);
    });

    test('image urls carry the size each surface renders at', () {
      final item = CatalogItem.fromJson({
        'id': 1,
        'poster_path': '/p.jpg',
        'backdrop_path': '/b.jpg',
      }, MediaKind.tv);

      expect(item.posterUrl, 'https://image.tmdb.org/t/p/w500/p.jpg');
      expect(item.posterUrlSmall, 'https://image.tmdb.org/t/p/w342/p.jpg');
      expect(item.backdropUrl, 'https://image.tmdb.org/t/p/w780/b.jpg');
    });
  });

  group('CatalogSort.sortKey', () {
    test('recent resolves to the date field of the media kind', () {
      expect(CatalogSort.recent.sortKey(MediaKind.tv), 'first_air_date.desc');
      expect(
        CatalogSort.recent.sortKey(MediaKind.movie),
        'primary_release_date.desc',
      );
    });

    test('the other orders use one field for both kinds', () {
      expect(CatalogSort.popular.sortKey(MediaKind.tv), 'popularity.desc');
      expect(CatalogSort.popular.sortKey(MediaKind.movie), 'popularity.desc');
      expect(CatalogSort.topRated.sortKey(MediaKind.tv), 'vote_average.desc');
      expect(
        CatalogSort.topRated.sortKey(MediaKind.movie),
        'vote_average.desc',
      );
    });
  });
}
