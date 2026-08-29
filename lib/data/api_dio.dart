import 'dart:async';

import 'package:dio/dio.dart';

/// Transport shared by every metadata client, whether it reaches a provider
/// directly or through the proxy.
Dio apiDio(String baseUrl) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  dio.interceptors.add(_Retry(dio));
  return dio;
}

/// Retries a read that failed for a reason unlikely to repeat: a timeout, a
/// dropped connection, or an upstream 5xx.
///
/// The metadata proxy is a Cloud Function that cold starts, and every call
/// through it costs two hops, so the first request after a while can time out
/// where the next one goes through. Without this the caller sees a hard
/// failure and has to ask again by hand.
class _Retry extends Interceptor {
  _Retry(this._dio);

  static const _attempts = 2;
  static const _backoff = Duration(milliseconds: 400);

  final Dio _dio;

  static bool _worthRetrying(DioException e) {
    if (e.requestOptions.method != 'GET') return false;
    final status = e.response?.statusCode;
    if (status != null) return status >= 500 && status < 600;
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      _ => false,
    };
  }

  @override
  Future<void> onError(DioException e, ErrorInterceptorHandler handler) async {
    final done = (e.requestOptions.extra['retries'] as int?) ?? 0;
    if (done >= _attempts || !_worthRetrying(e)) return handler.next(e);

    e.requestOptions.extra['retries'] = done + 1;
    await Future<void>.delayed(_backoff * (done + 1));
    try {
      handler.resolve(await _dio.fetch<dynamic>(e.requestOptions));
    } on DioException catch (retried) {
      handler.next(retried);
    }
  }
}
