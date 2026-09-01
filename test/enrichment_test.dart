import 'package:flutter_test/flutter_test.dart';
import 'package:tv_track/data/models/show.dart';
import 'package:tv_track/data/tvdb/enrichment.dart';
import 'package:tv_track/data/tvdb/tvdb_api.dart';

void main() {
  final now = DateTime(2026, 7, 5);
  // nextAirDate compares against the real clock, so this one has to stay
  // ahead of it whenever the suite runs.
  final upcoming = DateTime.now().add(const Duration(days: 30));

  final show = Show(
    tvdbId: 1001,
    title: 'Show In Progress',
    seasons: [
      const Season(
        number: 1,
        episodes: [
          // Stale title on a watched episode: the merge must replace the title
          // without touching watch state.
          Episode(tvdbId: 90001, number: 1, name: 'Old Title', watched: true),
          Episode(tvdbId: 90002, number: 2, watched: false),
        ],
      ),
    ],
  );

  final series = TvdbSeries(
    name: 'Show In Progress',
    overview: 'The show overview.',
    poster: 'https://artworks.thetvdb.com/banners/p.jpg',
    status: 'Continuing',
    network: 'HBO',
    episodes: [
      TvdbEpisode(
        season: 1,
        number: 1,
        name: 'Pilot',
        airDate: DateTime(2020, 1, 1),
      ),
      TvdbEpisode(
        season: 1,
        number: 2,
        name: 'Two',
        airDate: DateTime(2020, 1, 8),
        overview: 'Overview of episode two.',
        still: 'https://artworks.thetvdb.com/banners/s2.jpg',
      ),
      TvdbEpisode(season: 2, number: 1, name: 'Return', airDate: upcoming),
      const TvdbEpisode(season: 0, number: 1, name: 'Bonus'),
    ],
  );

  group('mergeTvdb', () {
    final merged = mergeTvdb(show, series, now: now);

    test('applies show metadata and maps the status', () {
      expect(merged.poster, 'https://artworks.thetvdb.com/banners/p.jpg');
      expect(merged.posterLarge, 'https://artworks.thetvdb.com/banners/p.jpg');
      expect(merged.airStatus, 'Running'); // Continuing → Running
      expect(merged.network, 'HBO');
      expect(merged.overview, 'The show overview.');
      expect(merged.metaRefreshedAt, now);
      expect(merged.isEnded, isFalse);
    });

    test('replaces a stale title while preserving watch state', () {
      final s1e1 = merged.regularSeasons.first.episodes.first;
      expect(s1e1.name, 'Pilot');
      expect(s1e1.watched, isTrue);
      expect(s1e1.tvdbId, 90001);
      expect(s1e1.airDate, DateTime(2020, 1, 1));
    });

    test('merges overview, still and air date', () {
      final s1e2 = merged.regularSeasons.first.episodes[1];
      expect(s1e2.name, 'Two');
      expect(s1e2.overview, 'Overview of episode two.');
      expect(s1e2.still, 'https://artworks.thetvdb.com/banners/s2.jpg');
      expect(s1e2.airDate, DateTime(2020, 1, 8));
      expect(s1e2.watched, isFalse);
    });

    test('adds a new season unwatched, with deterministic negative ids', () {
      final s2 = merged.regularSeasons.last;
      expect(s2.number, 2);
      expect(s2.episodes.single.tvdbId, -2001);
      expect(s2.episodes.single.watched, isFalse);
      expect(merged.totalEpisodes, 3);
      expect(merged.watchedEpisodes, 1);
    });

    test('drops specials', () {
      expect(merged.seasons.where((s) => s.number == 0), isEmpty);
    });

    test('takes the show title from TheTVDB, in the requested language', () {
      final imported = show.copyWith(title: 'Rhythm + Flow France');
      final translated = TvdbSeries(
        name: 'Nouvelle École',
        overview: series.overview,
        episodes: series.episodes,
      );
      expect(mergeTvdb(imported, translated, now: now).title, 'Nouvelle École');
    });

    test('keeps the stored title when TheTVDB has none', () {
      final untitled = TvdbSeries(name: '', episodes: series.episodes);
      expect(mergeTvdb(show, untitled, now: now).title, 'Show In Progress');
    });

    test('derives the next air date from the merged episodes', () {
      expect(merged.nextAirDate, upcoming);
    });

    test('is idempotent: ids and progress survive a second merge', () {
      final again = mergeTvdb(merged, series, now: now);
      expect(again.totalEpisodes, merged.totalEpisodes);
      expect(again.watchedEpisodes, merged.watchedEpisodes);
      expect(
        again.regularSeasons.last.episodes.single.tvdbId,
        merged.regularSeasons.last.episodes.single.tvdbId,
      );
    });

    test('survives a Firestore JSON round-trip', () {
      expect(Show.fromJson(merged.toJson()), equals(merged));
    });
  });
}
