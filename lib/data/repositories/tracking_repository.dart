import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/movie.dart';
import '../models/show.dart';

/// Accès Firestore au suivi de l'utilisateur.
///
/// Structure :
///   users/{uid}/shows/{tvdbId}       — un doc par série, saisons/épisodes
///   users/{uid}/movies/{tvdbId}      — un doc par film
///   users/{uid}/discover_seen/{id}   — carte Découverte déjà swipée (id TMDB)
class TrackingRepository {
  TrackingRepository(this._db, this.uid);

  final FirebaseFirestore _db;
  final String uid;

  CollectionReference<Map<String, dynamic>> get _shows =>
      _db.collection('users').doc(uid).collection('shows');

  CollectionReference<Map<String, dynamic>> get _movies =>
      _db.collection('users').doc(uid).collection('movies');

  CollectionReference<Map<String, dynamic>> get _discoverSeen =>
      _db.collection('users').doc(uid).collection('discover_seen');

  Stream<List<Show>> watchShows() => _shows.snapshots().map(
      (snap) => snap.docs.map((d) => Show.fromJson(d.data())).toList());

  Stream<List<Movie>> watchMovies() => _movies.snapshots().map(
      (snap) => snap.docs.map((d) => Movie.fromJson(d.data())).toList());

  Future<void> saveShow(Show show) =>
      _shows.doc('${show.tvdbId}').set(show.toJson());

  Future<void> saveMovie(Movie movie) =>
      _movies.doc('${movie.tvdbId}').set(movie.toJson());

  Future<void> deleteShow(int tvdbId) => _shows.doc('$tvdbId').delete();

  Future<void> deleteMovie(int tvdbId) => _movies.doc('$tvdbId').delete();

  /// Clés des cartes Découverte déjà swipées, namespacées par type
  /// ("tv_123" / "movie_123") car les IDs TMDB séries et films se chevauchent.
  Stream<Set<String>> watchSeenKeys() => _discoverSeen.snapshots().map(
      (snap) => snap.docs.map((d) => d.id).toSet());

  Future<void> markDiscoverSeen(String key, {required bool liked}) =>
      _discoverSeen.doc(key).set({
        'liked': liked,
        'at': FieldValue.serverTimestamp(),
      });

  /// Import initial : écrit tout par batches (limite Firestore : 500 ops).
  Future<void> importAll(
    List<Show> shows,
    List<Movie> movies, {
    void Function(int done, int total)? onProgress,
  }) async {
    final total = shows.length + movies.length;
    var done = 0;
    WriteBatch batch = _db.batch();
    var opsInBatch = 0;

    Future<void> flush() async {
      if (opsInBatch == 0) return;
      await batch.commit();
      batch = _db.batch();
      opsInBatch = 0;
      onProgress?.call(done, total);
    }

    for (final show in shows) {
      batch.set(_shows.doc('${show.tvdbId}'), show.toJson());
      done++;
      if (++opsInBatch >= 400) await flush();
    }
    for (final movie in movies) {
      batch.set(_movies.doc('${movie.tvdbId}'), movie.toJson());
      done++;
      if (++opsInBatch >= 400) await flush();
    }
    await flush();
  }
}
