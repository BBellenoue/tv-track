import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tv_track/data/tvdb/tvdb_api.dart';

/// Answers each TheTVDB route from [respond], and records what was asked for.
class _FakeTvdbAdapter implements HttpClientAdapter {
  _FakeTvdbAdapter(this.respond);

  /// Status and body for one request.
  final Future<(int, Map<String, dynamic>)> Function(RequestOptions request)
  respond;

  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, body) = await respond(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

TvdbApi _api(_FakeTvdbAdapter adapter, {String language = 'eng'}) =>
    TvdbApi.proxied(Dio()..httpClientAdapter = adapter, language: language);

const _extended = {
  'data': {
    'name': 'Berlin',
    'image': '/poster.jpg',
    'status': {'name': 'Continuing'},
    'latestNetwork': {'name': 'Netflix'},
  },
};

const _episodes = {
  'data': {
    'episodes': [
      {
        'seasonNumber': '1',
        'number': '1',
        'name': 'Pilot',
        'aired': '2024-01-01',
      },
    ],
  },
  'links': {'next': null},
};

Future<(int, Map<String, dynamic>)> _route(RequestOptions r) async {
  if (r.path.contains('/extended')) return (200, _extended);
  if (r.path.contains('/translations/')) {
    return (
      200,
      {
        'data': {'name': 'Berlin VF', 'overview': 'Un casse.'},
      },
    );
  }
  return (200, _episodes);
}

void main() {
  group('TvdbApi.series', () {
    test(
      'an id TheTVDB does not know gives null rather than throwing',
      () async {
        // Every route 404s for an unknown id, the episodes one included.
        final adapter = _FakeTvdbAdapter(
          (_) async => (404, <String, dynamic>{}),
        );

        expect(await _api(adapter).series(1), isNull);
      },
    );

    test('the translation wins over the original title', () async {
      final adapter = _FakeTvdbAdapter(_route);

      final series = await _api(adapter).series(1);

      expect(series!.name, 'Berlin VF');
      expect(series.overview, 'Un casse.');
      expect(series.status, 'Continuing');
      expect(series.network, 'Netflix');
      expect(series.episodes.single.name, 'Pilot');
    });

    test('a missing translation falls back to the original title', () async {
      final adapter = _FakeTvdbAdapter(
        (r) async => r.path.contains('/translations/')
            ? (404, <String, dynamic>{})
            : _route(r),
      );

      expect((await _api(adapter).series(1))!.name, 'Berlin');
    });

    test('an untranslated season takes its text from English', () async {
      // What TheTVDB serves for a season nobody has translated yet: the
      // episodes are listed, their text is not.
      Map<String, dynamic> episodes({required bool french}) => {
        'data': {
          'episodes': [
            {
              'seasonNumber': '5',
              'number': '1',
              'name': french ? '' : 'The Lost Fleet',
              'overview': french ? null : 'The Pogues sail south.',
              'aired': '2026-08-01',
            },
            if (!french)
              {
                'seasonNumber': '5',
                'number': '2',
                'name': 'Dead Reckoning',
                'aired': '2026-08-08',
              },
          ],
        },
        'links': {'next': null},
      };

      final adapter = _FakeTvdbAdapter((r) async {
        if (r.path.contains('/extended')) return (200, _extended);
        if (r.path.contains('/translations/')) {
          return (
            200,
            {
              'data': {
                'name': 'Outer Banks',
                'overview': r.path.endsWith('/fra')
                    ? null
                    : 'Chasse au trésor.',
              },
            },
          );
        }
        return (200, episodes(french: r.path.endsWith('/fra')));
      });

      final series = await _api(adapter, language: 'fra').series(1);

      final first = series!.episodes.first;
      expect(first.name, 'The Lost Fleet');
      expect(first.overview, 'The Pogues sail south.');
      // An episode the French listing does not carry at all still shows up.
      expect(series.episodes.map((e) => e.number), [1, 2]);
      // And the show overview, missing in French, comes from English too.
      expect(series.overview, 'Chasse au trésor.');
    });

    test('a complete translation asks English for nothing', () async {
      final adapter = _FakeTvdbAdapter(
        (r) async => r.path.contains('/episodes/')
            ? (
                200,
                {
                  'data': {
                    'episodes': [
                      {
                        'seasonNumber': '1',
                        'number': '1',
                        'name': 'Pilote',
                        'overview': 'Le début.',
                        'aired': '2024-01-01',
                      },
                    ],
                  },
                  'links': {'next': null},
                },
              )
            : _route(r),
      );

      await _api(adapter, language: 'fra').series(1);

      expect(adapter.requests.where((r) => r.path.endsWith('/eng')), isEmpty);
    });

    test('the three calls fly together', () async {
      // Nothing is answered until all three requests have arrived, so this
      // deadlocks rather than passing if they are issued one after the other.
      final arrived = Completer<void>();
      var seen = 0;
      final adapter = _FakeTvdbAdapter((r) async {
        if (++seen == 3) arrived.complete();
        await arrived.future;
        return _route(r);
      });

      await _api(adapter).series(1);

      expect(seen, 3);
    });
  });
}
