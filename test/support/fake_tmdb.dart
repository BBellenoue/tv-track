import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:tv_track/data/tmdb/tmdb_api.dart';

/// Serves canned TMDB payloads and records what was asked for, so the client
/// can be exercised without the network.
class FakeTmdbAdapter implements HttpClientAdapter {
  FakeTmdbAdapter(this.respond);

  /// Body for one request. Returning null serves an empty result set.
  final Map<String, dynamic>? Function(RequestOptions request) respond;

  final requests = <RequestOptions>[];

  List<int> get pagesRequested => [
    for (final r in requests) r.queryParameters['page'] as int,
  ];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(respond(options) ?? const {'results': <dynamic>[]}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

TmdbApi fakeTmdbApi(
  FakeTmdbAdapter adapter, {
  String language = 'en-US',
  String region = 'US',
}) => TmdbApi.direct(
  'test-key',
  language: language,
  region: region,
  dio: Dio()..httpClientAdapter = adapter,
);

/// A discover/search result carrying only what the mapping reads.
Map<String, dynamic> tvResult(int id, {String? poster = '/p.jpg'}) => {
  'id': id,
  'name': 'Show $id',
  'first_air_date': '2024-01-0${id % 9 + 1}',
  'poster_path': poster,
};
