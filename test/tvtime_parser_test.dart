import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tv_track/data/models/show.dart';
import 'package:tv_track/data/tvtime/tvtime_parser.dart';

void main() {
  final seriesJson = File('test/fixtures/series.json').readAsStringSync();
  final moviesJson = File('test/fixtures/movies.json').readAsStringSync();

  group('TvTimeParser.parseShows', () {
    final shows = TvTimeParser.parseShows(seriesJson);

    test('parses the fixture shows', () {
      expect(shows, hasLength(2));
      expect(shows.first.title, 'Show In Progress');
      expect(shows.first.isFavorite, isTrue);
    });

    test('accepts the export\'s "YYYY-MM-DD HH:mm:ss" dates', () {
      final pilot = shows.first.seasons.first.episodes.first;
      expect(pilot.watchedAt, DateTime(2026, 3, 29, 14, 28, 52));
    });

    test('specials are excluded from progress', () {
      final show = shows.first;
      expect(show.totalEpisodes, 2); // the bloopers reel does not count
      expect(show.watchedEpisodes, 1);
      expect(show.isStarted, isTrue);
      expect(show.isUpToDate, isFalse);
    });

    test('nextEpisode points at the first unwatched episode', () {
      final next = shows.first.nextEpisode!;
      expect(next.season.number, 1);
      expect(next.episode.number, 2);
      expect(shows[1].nextEpisode!.episode.number, 1);
    });

    test('survives a Firestore JSON round-trip', () {
      for (final show in shows) {
        expect(Show.fromJson(show.toJson()), equals(show));
      }
    });
  });

  group('TvTimeParser.parseMovies', () {
    final movies = TvTimeParser.parseMovies(moviesJson);

    test('parses the fixture movies', () {
      expect(movies, hasLength(2));
      expect(movies.where((m) => m.watched), hasLength(1));
      expect(movies[1].imdbId, isNull);
      expect(movies[0].watchedAt, isNotNull);
    });
  });

  group('TvTimeParser.parseFiles', () {
    test('tells shows and movies apart by content', () {
      final parsed = TvTimeParser.parseFiles([moviesJson, seriesJson]);
      expect(parsed.shows, hasLength(2));
      expect(parsed.movies, hasLength(2));
    });
  });

  group('Show helpers', () {
    final shows = TvTimeParser.parseShows(seriesJson);

    test('withEpisodeWatched ticks the next episode', () {
      final show = shows.first;
      final next = show.nextEpisode!;
      final updated = show.withEpisodeWatched(next.episode.tvdbId, true);
      expect(updated.watchedEpisodes, show.watchedEpisodes + 1);
      expect(updated.isUpToDate, isTrue);
    });

    test('withSeasonWatched ticks the whole season', () {
      final updated = shows[1].withSeasonWatched(1, true);
      expect(updated.regularSeasons.first.isCompleted, isTrue);
    });
  });

  group('catching up on earlier episodes, across seasons', () {
    // S1: E1 watched, E2 not; S2: E1 watched, E2 and E3 not.
    final show = Show(
      tvdbId: 42,
      title: 'Multi',
      seasons: [
        const Season(
          number: 1,
          episodes: [
            Episode(tvdbId: 1, number: 1, watched: true),
            Episode(tvdbId: 2, number: 2, watched: false),
          ],
        ),
        const Season(
          number: 2,
          episodes: [
            Episode(tvdbId: 3, number: 1, watched: true),
            Episode(tvdbId: 4, number: 2, watched: false),
            Episode(tvdbId: 5, number: 3, watched: false),
          ],
        ),
      ],
    );

    test('unwatchedBefore counts across seasons', () {
      // Before S2E3: S1E2 and S2E2, so two.
      expect(show.unwatchedBefore(2, 3), 2);
      expect(show.unwatchedBefore(1, 1), 0);
    });

    test('markWatchedUpTo includes the target episode', () {
      final updated = show.markWatchedUpTo(2, 3);
      expect(updated.watchedEpisodes, 5);
      expect(updated.unwatchedBefore(2, 3), 0);
      expect(updated.isUpToDate, isTrue);
    });

    test('markWatchedUpTo leaves later episodes alone', () {
      final updated = show.markWatchedUpTo(1, 2);
      expect(updated.seasons[0].isCompleted, isTrue);
      expect(updated.seasons[1].episodes[1].watched, isFalse);
      expect(updated.seasons[1].episodes[2].watched, isFalse);
    });
  });

  // Optional check against a real TV Time export. Personal data, never
  // committed: drop the files in assets/tvtime/ to run it.
  group('real TV Time export', () {
    final realSeries = File('assets/tvtime/series.json');
    final realMovies = File('assets/tvtime/movies.json');
    final available = realSeries.existsSync() && realMovies.existsSync();

    test(
      'parses cleanly and survives a Firestore round-trip',
      skip: available ? null : 'no export in assets/tvtime/',
      () {
        final shows = TvTimeParser.parseShows(realSeries.readAsStringSync());
        final movies = TvTimeParser.parseMovies(realMovies.readAsStringSync());
        expect(shows, isNotEmpty);
        expect(movies, isNotEmpty);
        for (final show in shows) {
          expect(Show.fromJson(show.toJson()), equals(show));
        }
      },
    );
  });
}
