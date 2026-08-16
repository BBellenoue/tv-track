import 'package:flutter_test/flutter_test.dart';
import 'package:tv_track/data/models/movie.dart';
import 'package:tv_track/data/models/show.dart';

void main() {
  final airedEpisode = Episode(
    tvdbId: 10,
    number: 1,
    name: 'Pilot',
    airDate: DateTime(2020, 1, 1),
    still: 'https://img/still.jpg',
    overview: 'An enriched episode.',
  );

  Show completeShow() => Show(
    tvdbId: 1,
    title: 'X',
    tmdbId: 42,
    overview:
        'A family moves to a small town and they discover a secret '
        'that was buried for years.',
    poster: 'https://img/poster.jpg',
    seasons: [
      Season(number: 1, episodes: [airedEpisode]),
    ],
  );

  Movie completeMovie() => const Movie(
    tvdbId: 1,
    title: 'X',
    tmdbId: 42,
    overview:
        'A heist goes wrong and the crew turns on each other while '
        'they are hiding in the basement.',
    poster: 'https://img/poster.jpg',
    backdrop: 'https://img/backdrop.jpg',
    runtime: 118,
  );

  group('Show.isIncomplete', () {
    test('a fully enriched show needs nothing', () {
      expect(completeShow().isIncomplete, isFalse);
    });

    test('no overview', () {
      expect(completeShow().copyWith(overview: null).isIncomplete, isTrue);
    });

    test('no artwork at all', () {
      expect(completeShow().copyWith(poster: null).isIncomplete, isTrue);
    });

    test('no seasons', () {
      expect(completeShow().copyWith(seasons: const []).isIncomplete, isTrue);
    });

    test('a bare season, aired but never enriched by any provider', () {
      final withBareS2 = completeShow().copyWith(
        seasons: [
          ...completeShow().seasons,
          const Season(
            number: 2,
            episodes: [
              Episode(tvdbId: 20, number: 1, name: 'Stendhal Syndrome'),
              Episode(tvdbId: 21, number: 2, name: 'Oranges from China'),
            ],
          ),
        ],
      );
      expect(withBareS2.isIncomplete, isTrue);
    });

    test('an upcoming episode carries a date, so it is not bare', () {
      // Otherwise every show with a scheduled episode would repair on loop.
      final upcoming = completeShow().copyWith(
        seasons: [
          Season(
            number: 1,
            episodes: [
              airedEpisode,
              Episode(tvdbId: 11, number: 2, airDate: DateTime(2035, 1, 1)),
            ],
          ),
        ],
      );
      expect(upcoming.isIncomplete, isFalse);
    });
  });

  group('Movie.isIncomplete', () {
    test('a fully enriched movie needs nothing', () {
      expect(completeMovie().isIncomplete, isFalse);
    });

    test('never matched to TMDB', () {
      expect(completeMovie().copyWith(tmdbId: null).isIncomplete, isTrue);
    });

    test('no overview', () {
      expect(completeMovie().copyWith(overview: null).isIncomplete, isTrue);
    });

    test('no poster', () {
      expect(completeMovie().copyWith(poster: null).isIncomplete, isTrue);
    });

    test('no backdrop', () {
      expect(completeMovie().copyWith(backdrop: null).isIncomplete, isTrue);
    });

    test('no runtime', () {
      expect(completeMovie().copyWith(runtime: 0).isIncomplete, isTrue);
    });
  });
}
