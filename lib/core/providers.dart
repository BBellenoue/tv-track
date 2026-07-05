import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/movie.dart';
import '../data/models/show.dart';
import '../data/repositories/tracking_repository.dart';
import '../data/tmdb/tmdb_api.dart';
import '../data/tvmaze/tvmaze_api.dart';
import 'config.dart';

part 'providers.g.dart';

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

@Riverpod(keepAlive: true)
TvmazeApi tvmazeApi(Ref ref) => TvmazeApi();

/// Client TMDB si une clé est configurée (sinon null → Découverte désactivée).
@Riverpod(keepAlive: true)
TmdbApi? tmdbApi(Ref ref) =>
    tmdbApiKey.isEmpty ? null : TmdbApi(tmdbApiKey);

@riverpod
Stream<Set<int>> discoverSeenIds(Ref ref) {
  final repo = ref.watch(trackingRepositoryProvider);
  if (repo == null) return Stream.value(const {});
  return repo.watchSeenTmdbIds();
}

