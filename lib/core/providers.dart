import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/movie.dart';
import '../data/models/show.dart';
import '../data/repositories/tracking_repository.dart';
import '../data/tmdb/catalog_item.dart';
import '../data/tmdb/tmdb_api.dart';
import '../data/tvdb/tvdb_api.dart';
import 'config.dart';
import 'locale.dart';
import 'metadata_proxy.dart';

part 'providers.g.dart';

/// Overridden at startup with the instance loaded in `main`, so preferences can
/// be read synchronously from providers.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) =>
    throw UnimplementedError('sharedPreferencesProvider must be overridden');

/// Overridden at startup with the store opened in `main`, for the same reason
/// as the preferences above.
@Riverpod(keepAlive: true)
CacheStore metadataCacheStore(Ref ref) =>
    throw UnimplementedError('metadataCacheStoreProvider must be overridden');

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
Stream<User?> authState(Ref ref) =>
    ref.watch(firebaseAuthProvider).authStateChanges();

@riverpod
TrackingRepository? trackingRepository(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return TrackingRepository(FirebaseFirestore.instance, user.uid);
}

@riverpod
Stream<List<Show>> shows(Ref ref) {
  final repo = ref.watch(trackingRepositoryProvider);
  if (repo == null) return Stream.value(const []);
  return repo.watchShows();
}

@riverpod
Stream<List<Movie>> movies(Ref ref) {
  final repo = ref.watch(trackingRepositoryProvider);
  if (repo == null) return Stream.value(const []);
  return repo.watchMovies();
}

/// Null when no proxy is configured, which disables show enrichment.
/// keepAlive so the auth token survives for the whole session.
@Riverpod(keepAlive: true)
TvdbApi? tvdbApi(Ref ref) {
  if (metadataProxyUrl.isEmpty) return null;
  final dio = metadataProxyDio(
    'tvdb',
    auth: ref.watch(firebaseAuthProvider),
    store: ref.watch(metadataCacheStoreProvider),
  );
  ref.onDispose(dio.close);
  return TvdbApi.proxied(
    dio,
    language: ref.watch(localeControllerProvider).tvdb,
  );
}

/// Null when no proxy is configured, which disables Discover and search.
@Riverpod(keepAlive: true)
TmdbApi? tmdbApi(Ref ref) {
  if (metadataProxyUrl.isEmpty) return null;
  final dio = metadataProxyDio(
    'tmdb',
    auth: ref.watch(firebaseAuthProvider),
    store: ref.watch(metadataCacheStoreProvider),
  );
  ref.onDispose(dio.close);
  return TmdbApi.proxied(
    dio,
    language: ref.watch(localeControllerProvider).tmdb,
    region: watchRegion,
  );
}

/// Genres and credits for one title. Fetched when a detail screen opens
/// rather than stored, so no record has to be migrated to gain them.
@riverpod
Future<TmdbExtras?> titleExtras(Ref ref, MediaKind kind, int tmdbId) async {
  final tmdb = ref.watch(tmdbApiProvider);
  if (tmdb == null) return null;
  try {
    return await tmdb.extras(kind, tmdbId);
  } catch (_) {
    // Credits are a nice-to-have, never a reason to break the screen.
    return null;
  }
}

@riverpod
Stream<Set<String>> discoverSeenKeys(Ref ref) {
  final repo = ref.watch(trackingRepositoryProvider);
  if (repo == null) return Stream.value(const {});
  return repo.watchSeenKeys();
}

/// TMDB ids of tracked shows, used to grey out entries already in the library.
@riverpod
Set<int> trackedShowTmdbIds(Ref ref) =>
    (ref.watch(showsProvider).value ?? const [])
        .map((s) => s.tmdbId)
        .whereType<int>()
        .toSet();

@riverpod
Set<int> trackedMovieTmdbIds(Ref ref) =>
    (ref.watch(moviesProvider).value ?? const [])
        .map((m) => m.tmdbId)
        .whereType<int>()
        .toSet();
