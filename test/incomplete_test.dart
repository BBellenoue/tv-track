import 'package:flutter_test/flutter_test.dart';
import 'package:tv_track/data/models/movie.dart';
import 'package:tv_track/data/models/show.dart';

void main() {
  // Une série « complète » de référence : rattachée à TMDB, synopsis FR,
  // affiche, et une saison avec un épisode.
  final airedEpisode = Episode(
    tvdbId: 10,
    number: 1,
    name: 'Pilote',
    airDate: DateTime(2020, 1, 1),
    still: 'https://img/still.jpg',
    overview: 'Un épisode enrichi.',
  );

  Show completeShow() => Show(
        tvdbId: 1,
        title: 'X',
        tmdbId: 42,
        overview: 'Une famille déménage dans une petite ville et découvre '
            'un secret enfoui depuis des années.',
        poster: 'https://img/poster.jpg',
        seasons: [
          Season(number: 1, episodes: [airedEpisode]),
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

    test('saison nue (épisodes sans date/vignette/résumé) → à réparer', () {
      // Cas Berlin S2 : saison sortie mais qu'aucune source n'a enrichie.
      final withBareS2 = completeShow().copyWith(seasons: [
        ...completeShow().seasons,
        const Season(number: 2, episodes: [
          Episode(tvdbId: 20, number: 1, name: 'Stendhal Syndrome'),
          Episode(tvdbId: 21, number: 2, name: 'Oranges from China'),
        ]),
      ]);
      expect(withBareS2.isIncomplete, isTrue);
    });

    test('épisode à venir (date seule, sans vignette/résumé) → pas nu', () {
      // Un épisode simplement pas encore diffusé a au moins une date : il ne
      // doit pas déclencher de réparation en boucle.
      final upcoming = completeShow().copyWith(seasons: [
        Season(number: 1, episodes: [
          airedEpisode,
          Episode(tvdbId: 11, number: 2, airDate: DateTime(2035, 1, 1)),
        ]),
      ]);
      expect(upcoming.isIncomplete, isFalse);
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
