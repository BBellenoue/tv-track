import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tv_track/data/models/show.dart';
import 'package:tv_track/data/tvtime/tvtime_parser.dart';

void main() {
  final seriesJson = File('test/fixtures/series.json').readAsStringSync();
  final moviesJson = File('test/fixtures/movies.json').readAsStringSync();

  group('TvTimeParser.parseShows', () {
    final shows = TvTimeParser.parseShows(seriesJson);

    test('parse les séries de la fixture', () {
      expect(shows, hasLength(2));
      expect(shows.first.title, 'Série En Cours');
      expect(shows.first.isFavorite, isTrue);
    });

    test('les dates "YYYY-MM-DD HH:mm:ss" sont bien parsées', () {
      final pilote = shows.first.seasons.first.episodes.first;
      expect(pilote.watchedAt, DateTime(2026, 3, 29, 14, 28, 52));
    });

    test('les specials sont exclus de la progression', () {
      final show = shows.first;
      expect(show.totalEpisodes, 2); // le bêtisier ne compte pas
      expect(show.watchedEpisodes, 1);
      expect(show.isStarted, isTrue);
      expect(show.isUpToDate, isFalse);
    });

    test('nextEpisode pointe le premier épisode non vu', () {
      final next = shows.first.nextEpisode!;
      expect(next.season.number, 1);
      expect(next.episode.number, 2);
      expect(shows[1].nextEpisode!.episode.number, 1);
    });

    test('round-trip JSON (Firestore) sans perte', () {
      for (final show in shows) {
        expect(Show.fromJson(show.toJson()), equals(show));
      }
    });
  });

  group('TvTimeParser.parseMovies', () {
    final movies = TvTimeParser.parseMovies(moviesJson);

    test('parse les films de la fixture', () {
      expect(movies, hasLength(2));
      expect(movies.where((m) => m.watched), hasLength(1));
      expect(movies[1].imdbId, isNull);
      expect(movies[0].watchedAt, isNotNull);
    });
  });

  group('TvTimeParser.parseFiles', () {
    test('détecte séries vs films au contenu', () {
      final parsed = TvTimeParser.parseFiles([moviesJson, seriesJson]);
      expect(parsed.shows, hasLength(2));
      expect(parsed.movies, hasLength(2));
    });
  });

  group('Show helpers', () {
    final shows = TvTimeParser.parseShows(seriesJson);

    test('withEpisodeWatched marque le prochain épisode', () {
      final show = shows.first;
      final next = show.nextEpisode!;
      final updated = show.withEpisodeWatched(next.episode.tvdbId, true);
      expect(updated.watchedEpisodes, show.watchedEpisodes + 1);
      expect(updated.isUpToDate, isTrue);
    });

    test('withSeasonWatched marque toute la saison', () {
      final updated = shows[1].withSeasonWatched(1, true);
      expect(updated.regularSeasons.first.isCompleted, isTrue);
    });
  });

  group('rattrapage des épisodes précédents (multi-saison)', () {
    // S1: 2 épisodes vus ; S2: E1 vu, E2 et E3 non vus.
    final show = Show(
      tvdbId: 42,
      title: 'Multi',
      seasons: [
        const Season(number: 1, episodes: [
          Episode(tvdbId: 1, number: 1, watched: true),
          Episode(tvdbId: 2, number: 2, watched: false),
        ]),
        const Season(number: 2, episodes: [
          Episode(tvdbId: 3, number: 1, watched: true),
          Episode(tvdbId: 4, number: 2, watched: false),
          Episode(tvdbId: 5, number: 3, watched: false),
        ]),
      ],
    );

    test('unwatchedBefore compte à travers les saisons', () {
      // Avant S2E3 : S1E2 (non vu) + S2E2 (non vu) = 2.
      expect(show.unwatchedBefore(2, 3), 2);
      // Avant S1E1 : aucun.
      expect(show.unwatchedBefore(1, 1), 0);
    });

    test('markWatchedUpTo marque tout jusqu\'à la cible incluse', () {
      final updated = show.markWatchedUpTo(2, 3);
      expect(updated.watchedEpisodes, 5); // tout vu
      expect(updated.unwatchedBefore(2, 3), 0);
      expect(updated.isUpToDate, isTrue);
    });

    test('markWatchedUpTo laisse les épisodes suivants intacts', () {
      final updated = show.markWatchedUpTo(1, 2); // jusqu'à S1E2
      expect(updated.seasons[0].isCompleted, isTrue);
      // S2E2/E3 restent non vus.
      expect(updated.seasons[1].episodes[1].watched, isFalse);
      expect(updated.seasons[1].episodes[2].watched, isFalse);
    });
  });

  // Validation optionnelle sur un vrai export TV Time (données perso, non
  // commité) : déposer les fichiers dans assets/tvtime/ pour l'exécuter.
  group('export TV Time réel', () {
    final realSeries = File('assets/tvtime/series.json');
    final realMovies = File('assets/tvtime/movies.json');
    final available = realSeries.existsSync() && realMovies.existsSync();

    test('parse sans erreur et round-trip Firestore', skip: !available ? 'pas d\'export réel dans assets/tvtime/' : null,
        () {
      final shows = TvTimeParser.parseShows(realSeries.readAsStringSync());
      final movies = TvTimeParser.parseMovies(realMovies.readAsStringSync());
      expect(shows, isNotEmpty);
      expect(movies, isNotEmpty);
      for (final show in shows) {
        expect(Show.fromJson(show.toJson()), equals(show));
      }
    });
  });
}
