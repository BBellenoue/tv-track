import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/api_dio.dart';
import 'config.dart';

/// Dio client for one provider path of the metadata proxy (`tmdb` or `tvdb`).
///
/// The proxy rejects anonymous callers, so every request carries the caller's
/// Firebase ID token. `getIdToken` serves a cached token and refreshes it on its
/// own once expired.
///
/// Responses are kept in [store] and revalidated with the ETag the proxy
/// forwards from the provider, so an unchanged payload comes back as a bodiless
/// 304 rather than being downloaded again over both legs.
Dio metadataProxyDio(
  String provider, {
  required FirebaseAuth auth,
  required CacheStore store,
}) {
  final dio = apiDio('$metadataProxyUrl/$provider');
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await auth.currentUser?.getIdToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );
  dio.interceptors.add(
    DioCacheInterceptor(
      options: CacheOptions(
        store: store,
        // The proxy answers "private, no-cache", so an entry is stored but
        // never served without asking the provider whether it still holds.
        policy: CachePolicy.request,
        // Stale metadata beats none when the upstream or the network fails,
        // but a rejected caller must be told so rather than served a copy.
        hitCacheOnErrorExcept: const [401, 403],
        maxStale: const Duration(days: 7),
      ),
    ),
  );
  return dio;
}
