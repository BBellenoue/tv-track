import 'package:flutter_test/flutter_test.dart';
import 'package:tv_track/data/models/show.dart';
import 'package:tv_track/data/tvmaze/enrichment.dart';
import 'package:tv_track/data/tvmaze/tvmaze_api.dart';

void main() {
  final now = DateTime(2026, 7, 5);

  final show = Show(
    tvdbId: 1001,
    title: 'Série En Cours',
    seasons: [
      const Season(number: 1, episodes: [
        Episode(tvdbId: 90001, number: 1, name: 'Pilote', watched: true),
        Episode(tvdbId: 90002, number: 2, watched: false),
      ]),
    ],
  );

  const meta = TvmazeShow(
    id: 555,
    name: 'Série En Cours',
    status: 'Running',
    network: 'HBO',
    imageMedium: 'https://img.example/m.jpg',
    imageOriginal: 'https://img.example/o.jpg',
  );

  final episodes = [
    TvmazeEpisode(season: 1, number: 1, name: 'Pilot', airstamp: DateTime(2020, 1, 1)),
    TvmazeEpisode(season: 1, number: 2, name: 'Deux', airstamp: DateTime(2020, 1, 8)),
    TvmazeEpisode(season: 2, number: 1, name: 'Reprise', airstamp: DateTime(2026, 9, 1)),
    TvmazeEpisode(
        season: 0, number: 1, name: 'Special', type: 'significant_special'),
  ];

  group('mergeTvmaze', () {
    final merged = mergeTvmaze(show, meta, episodes, now: now);

    test('métadonnées appliquées', () {
      expect(merged.tvmazeId, 555);
      expect(merged.poster, 'https://img.example/m.jpg');
      expect(merged.airStatus, 'Running');
      expect(merged.network, 'HBO');
      expect(merged.metaRefreshedAt, now);
      expect(merged.isEnded, isFalse);
    });

    test('état de visionnage préservé, nom local prioritaire', () {
      final s1e1 = merged.regularSeasons.first.episodes.first;
      expect(s1e1.watched, isTrue);
      expect(s1e1.name, 'Pilote'); // pas écrasé par "Pilot"
      expect(s1e1.tvdbId, 90001);
      expect(s1e1.airDate, DateTime(2020, 1, 1));
    });

    test('nom manquant complété', () {
      final s1e2 = merged.regularSeasons.first.episodes[1];
      expect(s1e2.name, 'Deux');
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

    test('specials TVmaze ignorés', () {
      expect(merged.seasons.where((s) => s.isSpecials), isEmpty);
      expect(merged.seasons.where((s) => s.number == 0), isEmpty);
    });

    test('prochaine diffusion calculée depuis les airDates', () {
      expect(merged.nextAirDate, DateTime(2026, 9, 1));
    });

    test('idempotent : re-merger ne change ni IDs ni progression', () {
      final again = mergeTvmaze(merged, meta, episodes, now: now);
      expect(again.totalEpisodes, merged.totalEpisodes);
      expect(again.watchedEpisodes, merged.watchedEpisodes);
      expect(
        again.regularSeasons.last.episodes.single.tvdbId,
        merged.regularSeasons.last.episodes.single.tvdbId,
      );
    });

    test('round-trip Firestore avec les nouveaux champs', () {
      expect(Show.fromJson(merged.toJson()), equals(merged));
    });
  });
}
