import 'package:flutter_test/flutter_test.dart';
import 'package:tv_track/data/models/movie.dart';
import 'package:tv_track/data/models/show.dart';

void main() {
  // Une série « complète » de référence : rattachée à TMDB, synopsis FR,
  // affiche, et une saison avec un épisode.
  Show completeShow() => const Show(
        tvdbId: 1,
        title: 'X',
        tmdbId: 42,
        overview: 'Une famille déménage dans une petite ville et découvre '
            'un secret enfoui depuis des années.',
        poster: 'https://img/poster.jpg',
        seasons: [
          Season(number: 1, episodes: [Episode(tvdbId: 10, number: 1)]),
        ],
      );

  Movie completeMovie() => const Movie(
        tvdbId: 1,
        title: 'X',
        tmdbId: 42,
        overview: 'Un braquage tourne mal et les complices se déchirent '
            'dans une cave sordide.',
        poster: 'https://img/poster.jpg',
        backdrop: 'https://img/backdrop.jpg',
        runtime: 118,
      );

  group('Show.isIncomplete', () {
    test('fiche complète → rien à réparer', () {
      expect(completeShow().isIncomplete, isFalse);
    });

    test('sans synopsis → à réparer', () {
      expect(completeShow().copyWith(overview: null).isIncomplete, isTrue);
    });

    test('sans affiche (ni poster ni posterLarge) → à réparer', () {
      expect(completeShow().copyWith(poster: null).isIncomplete, isTrue);
    });

    test('sans épisodes → à réparer', () {
      expect(completeShow().copyWith(seasons: const []).isIncomplete, isTrue);
    });

    test('synopsis resté en anglais → à réparer', () {
      expect(
        completeShow()
            .copyWith(
                overview: 'A family moves to a small town and they discover '
                    'a secret that was buried for years.')
            .isIncomplete,
        isTrue,
      );
    });
  });

  group('Movie.isIncomplete', () {
    test('fiche complète → rien à réparer', () {
      expect(completeMovie().isIncomplete, isFalse);
    });

    test('jamais rattaché à TMDB → à réparer', () {
      expect(completeMovie().copyWith(tmdbId: null).isIncomplete, isTrue);
    });

    test('sans synopsis → à réparer', () {
      expect(completeMovie().copyWith(overview: null).isIncomplete, isTrue);
    });

    test('sans affiche → à réparer', () {
      expect(completeMovie().copyWith(poster: null).isIncomplete, isTrue);
    });

    test('sans image de fond → à réparer', () {
      expect(completeMovie().copyWith(backdrop: null).isIncomplete, isTrue);
    });

    test('durée inconnue → à réparer', () {
      expect(completeMovie().copyWith(runtime: 0).isIncomplete, isTrue);
    });

    test('synopsis resté en anglais → à réparer', () {
      expect(
        completeMovie()
            .copyWith(
                overview: 'A heist goes wrong and the crew turns on each '
                    'other while they are hiding in the basement.')
            .isIncomplete,
        isTrue,
      );
    });
  });
}
