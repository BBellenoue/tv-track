import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/movie.dart';
import '../models/show.dart';

/// Firestore access to one user's tracking data.
///
///   users/{uid}/shows/{tvdbId}       one document per show, seasons inlined
///   users/{uid}/movies/{tvdbId}      one document per movie
///   users/{uid}/discover_seen/{id}   a Discover card already swiped
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
    (snap) => snap.docs.map((d) => Show.fromJson(d.data())).toList(),
  );

  Stream<List<Movie>> watchMovies() => _movies.snapshots().map(
    (snap) => snap.docs.map((d) => Movie.fromJson(d.data())).toList(),
  );

  Future<void> saveShow(Show show) =>
      _shows.doc('${show.tvdbId}').set(show.toJson());

  Future<void> saveMovie(Movie movie) =>
      _movies.doc('${movie.tvdbId}').set(movie.toJson());

  Future<void> deleteShow(int tvdbId) => _shows.doc('$tvdbId').delete();

  Future<void> deleteMovie(int tvdbId) => _movies.doc('$tvdbId').delete();

  /// Keys are namespaced by media kind ("tv_123" / "movie_123") because TMDB
  /// show and movie ids overlap.
  Stream<Set<String>> watchSeenKeys() => _discoverSeen.snapshots().map(
    (snap) => snap.docs.map((d) => d.id).toSet(),
  );

  Future<void> markDiscoverSeen(String key, {required bool liked}) =>
      _discoverSeen.doc(key).set({
        'liked': liked,
        'at': FieldValue.serverTimestamp(),
      });

  /// Initial import, batched under the Firestore limit of 500 operations.
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
