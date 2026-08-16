import 'package:dio/dio.dart';

/// Transport shared by every metadata client, whether it reaches a provider
/// directly or through the proxy.
Dio apiDio(String baseUrl) => Dio(
  BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ),
);
