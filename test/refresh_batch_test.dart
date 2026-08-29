import 'package:flutter_test/flutter_test.dart';
import 'package:tv_track/data/models/show.dart';
import 'package:tv_track/features/shows/refresh_controller.dart';

final _now = DateTime(2026, 8, 29, 21);

/// A record with nothing missing, so only its age makes it eligible.
Show _complete(int id, {required Duration refreshedAgo, bool ended = false}) =>
    Show(
      tvdbId: id,
      title: 'Show $id',
      airStatus: ended ? 'Ended' : 'Running',
      overview: 'The crew has been sent after that which was taken from them.',
      poster: 'poster.jpg',
      metaRefreshedAt: _now.subtract(refreshedAgo),
      seasons: [
        Season(
          number: 1,
          episodes: [
            Episode(
              tvdbId: id * 10,
              number: 1,
              name: 'Pilot',
              airDate: DateTime(2020),
              overview: 'They meet.',
              still: 'still.jpg',
            ),
          ],
        ),
      ],
    );

/// A record TheTVDB has nothing for: it stays broken however often it is
/// refreshed.
Show _broken(int id, {required Duration refreshedAgo}) => Show(
  tvdbId: id,
  title: 'Broken $id',
  airStatus: 'Ended',
  metaRefreshedAt: _now.subtract(refreshedAgo),
);

List<int> _ids(List<Show> shows) => shows.map((s) => s.tvdbId).toList();

void main() {
  group('selectRefreshBatch', () {
    test('broken records never take the whole batch', () {
      final shows = [
        for (var i = 0; i < 20; i++)
          _broken(i, refreshedAgo: const Duration(days: 3)),
        for (var i = 20; i < 30; i++)
          _complete(i, refreshedAgo: const Duration(days: 2)),
      ];

      final batch = selectRefreshBatch(shows, wantEnglish: true, now: _now);

      expect(batch.length, 8);
      expect(batch.where((s) => s.needsRepair(wantEnglish: true)).length, 3);
    });

    test('the least recently refreshed go first, so the library rotates', () {
      final shows = [
        _complete(1, refreshedAgo: const Duration(days: 9)),
        _complete(2, refreshedAgo: const Duration(days: 2)),
        _complete(3, refreshedAgo: const Duration(days: 30)),
      ];

      final batch = selectRefreshBatch(
        shows,
        wantEnglish: true,
        now: _now,
        size: 2,
      );

      expect(_ids(batch), [3, 1]);
    });

    test('a fresh record waits its turn unless the pull forces it', () {
      final shows = [_complete(1, refreshedAgo: const Duration(minutes: 5))];

      expect(selectRefreshBatch(shows, wantEnglish: true, now: _now), isEmpty);
      expect(
        selectRefreshBatch(shows, wantEnglish: true, now: _now, force: true),
        hasLength(1),
      );
    });

    test('an ended show with everything filled in is left alone', () {
      final shows = [
        _complete(1, refreshedAgo: const Duration(days: 5), ended: true),
      ];

      expect(
        selectRefreshBatch(shows, wantEnglish: true, now: _now, force: true),
        isEmpty,
      );
    });
  });
}
