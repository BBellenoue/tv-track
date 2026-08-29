import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tv_track/data/api_dio.dart';

/// Fails the first [failures] requests the way a cold-starting proxy does,
/// then answers.
class _FlakyAdapter implements HttpClientAdapter {
  _FlakyAdapter({this.failures = 1, this.status});

  final int failures;
  final int? status;

  var calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    if (calls <= failures) {
      if (status != null) {
        return ResponseBody.fromString(jsonEncode({'error': 'nope'}), status!);
      }
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.receiveTimeout,
      );
    }
    return ResponseBody.fromString(
      jsonEncode({'ok': true}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(_FlakyAdapter adapter) =>
    apiDio('https://example.test')..httpClientAdapter = adapter;

void main() {
  group('apiDio', () {
    test('a timed out read is retried rather than handed back', () async {
      final adapter = _FlakyAdapter();

      final r = await _dio(adapter).get<Map<String, dynamic>>('/thing');

      expect(r.data, {'ok': true});
      expect(adapter.calls, 2);
    });

    test('an upstream 5xx is retried', () async {
      final adapter = _FlakyAdapter(status: 503);

      final r = await _dio(adapter).get<Map<String, dynamic>>('/thing');

      expect(r.data, {'ok': true});
      expect(adapter.calls, 2);
    });

    test('a 404 is the answer, not a hiccup', () async {
      final adapter = _FlakyAdapter(failures: 1, status: 404);

      await expectLater(
        _dio(adapter).get<Map<String, dynamic>>('/thing'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            404,
          ),
        ),
      );
      expect(adapter.calls, 1);
    });

    test('a request that keeps failing gives up and throws', () async {
      final adapter = _FlakyAdapter(failures: 99);

      await expectLater(
        _dio(adapter).get<Map<String, dynamic>>('/thing'),
        throwsA(isA<DioException>()),
      );
      // The first try plus the two retries.
      expect(adapter.calls, 3);
    });

    test('a POST is never replayed', () async {
      final adapter = _FlakyAdapter(failures: 99);

      await expectLater(
        _dio(adapter).post<Map<String, dynamic>>('/thing'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 1);
    });
  });
}
