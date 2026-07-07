import 'package:flutter_test/flutter_test.dart';
import 'package:tv_track/data/models/show.dart';
import 'package:tv_track/data/tvdb/enrichment.dart';
import 'package:tv_track/data/tvdb/tvdb_api.dart';

void main() {
  final now = DateTime(2026, 7, 5);

  final show = Show(
    tvdbId: 1001,
    title: 'Série En Cours',
    seasons: [
      const Season(number: 1, episodes: [
        // Titre resté en anglais + épisode vu : TheTVDB doit franciser le titre
        // sans toucher l'état vu.
        Episode(tvdbId: 90001, number: 1, name: 'Pilot', watched: true),
        Episode(tvdbId: 90002, number: 2, watched: false),
      ]),
    ],
  );

  final series = TvdbSeries(
    name: 'Série En Cours',
    overview: 'Le synopsis de la série.',
    poster: 'https://artworks.thetvdb.com/banners/p.jpg',
    status: 'Continuing',
    network: 'HBO',
    episodes: [
      TvdbEpisode(
          season: 1, number: 1, name: 'Pilote', airDate: DateTime(2020, 1, 1)),
      TvdbEpisode(
          season: 1,
          number: 2,
          name: 'Deux',
          airDate: DateTime(2020, 1, 8),
          overview: "Résumé de l'épisode deux.",
          still: 'https://artworks.thetvdb.com/banners/s2.jpg'),
      TvdbEpisode(
          season: 2, number: 1, name: 'Reprise', airDate: DateTime(2026, 9, 1)),
      const TvdbEpisode(season: 0, number: 1, name: 'Bonus'),
    ],
  );

  group('mergeTvdb', () {
    final merged = mergeTvdb(show, series, now: now);

    test('métadonnées série appliquées + statut mappé', () {
      expect(merged.poster, 'https://artworks.thetvdb.com/banners/p.jpg');
      expect(merged.posterLarge, 'https://artworks.thetvdb.com/banners/p.jpg');
      expect(merged.airStatus, 'Running'); // Continuing → Running
      expect(merged.network, 'HBO');
      expect(merged.overview, 'Le synopsis de la série.');
      expect(merged.metaRefreshedAt, now);
      expect(merged.isEnded, isFalse);
    });

    test('titre anglais francisé par TheTVDB, état vu préservé', () {
      final s1e1 = merged.regularSeasons.first.episodes.first;
      expect(s1e1.name, 'Pilote'); // "Pilot" remplacé par le FR
      expect(s1e1.watched, isTrue);
      expect(s1e1.tvdbId, 90001);
      expect(s1e1.airDate, DateTime(2020, 1, 1));
    });

    test('résumé + vignette + date fusionnés', () {
      final s1e2 = merged.regularSeasons.first.episodes[1];
      expect(s1e2.name, 'Deux');
      expect(s1e2.overview, "Résumé de l'épisode deux.");
      expect(s1e2.still, 'https://artworks.thetvdb.com/banners/s2.jpg');
      expect(s1e2.airDate, DateTime(2020, 1, 8));
      expect(s1e2.watched, isFalse);
    });

    test('nouvelle saison ajoutée non-vue avec ID négatif déterministe', () {
      final s2 = merged.regularSeasons.last;
      expect(s2.number, 2);
      expect(s2.episodes.single.tvdbId, -2001);
      expect(s2.episodes.single.watched, isFalse);
      expect(merged.totalEpisodes, 3);
      expect(merged.watchedEpisodes, 1);
    });

    test('specials (saison 0) ignorés', () {
      expect(merged.seasons.where((s) => s.number == 0), isEmpty);
    });

    test('prochaine diffusion calculée depuis les airDates', () {
      expect(merged.nextAirDate, DateTime(2026, 9, 1));
    });

    test('idempotent : re-merger ne change ni IDs ni progression', () {
      final again = mergeTvdb(merged, series, now: now);
      expect(again.totalEpisodes, merged.totalEpisodes);
      expect(again.watchedEpisodes, merged.watchedEpisodes);
      expect(
        again.regularSeasons.last.episodes.single.tvdbId,
        merged.regularSeasons.last.episodes.single.tvdbId,
      );
    });

    test('round-trip Firestore', () {
      expect(Show.fromJson(merged.toJson()), equals(merged));
    });
  });
}
