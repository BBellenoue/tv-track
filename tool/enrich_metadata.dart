// Bulk metadata enrichment of an existing Firestore library, outside the app.
//
// Shows are enriched from TheTVDB — seasons, episode titles and overviews,
// artwork, air dates, status, network — plus TMDB for streaming providers.
// Watch state is never touched. Movies are enriched from TMDB alone.
//
// Environment: TVDB_API_KEY (required for shows), TMDB_API_KEY (providers and
// movies, optional).
//
// Usage:
//   TVDB_API_KEY=… TMDB_API_KEY=… dart run tool/enrich_metadata.dart \
//     --uid <UID> --project <PROJECT_ID> \
//     [--lang en|fr] [--only shows|movies] [--incomplete]
//
// --incomplete restricts the run to records with something missing, for a
// targeted repair instead of rewriting the whole library.
import 'dart:io';

import 'package:tv_track/data/models/movie.dart';
import 'package:tv_track/data/models/show.dart';
import 'package:tv_track/data/tmdb/tmdb_api.dart';
import 'package:tv_track/data/tvdb/enrichment.dart';
import 'package:tv_track/data/tvdb/tvdb_api.dart';

import 'firestore_rest.dart';

Future<void> main(List<String> args) async {
  final flags = args
      .where((a) => a.startsWith('--') && !a.contains('='))
      .toSet();
  final opts = {
    for (var i = 0; i + 1 < args.length; i += 2)
      if (args[i].startsWith('--') && !args[i + 1].startsWith('--'))
        args[i].substring(2): args[i + 1],
  };
  final uid = opts['uid'];
  final project = opts['project'];
  if (uid == null || project == null) {
    stderr.writeln(
      'Usage: dart run tool/enrich_metadata.dart '
      '--uid <UID> --project <PROJECT_ID> [--lang en|fr]',
    );
    exit(1);
  }
  final only = opts['only'];
  final onlyIncomplete = flags.contains('--incomplete');
  // Language the metadata is fetched in; mirror the app's setting so a later
  // in-app refresh does not immediately rewrite everything.
  final french = (opts['lang'] ?? 'en') == 'fr';

  final db = FirestoreRest(project: project, token: await gcloudToken());

  if (only == null || only == 'shows') {
    await _enrichShows(db, uid, onlyIncomplete: onlyIncomplete, french: french);
  }
  if (only == null || only == 'movies') {
    await _enrichMovies(db, uid, french: french);
  }
  db.close();
}

Future<void> _enrichShows(
  FirestoreRest db,
  String uid, {
  bool onlyIncomplete = false,
  bool french = false,
}) async {
  final tvdbKey = Platform.environment['TVDB_API_KEY'];
  if (tvdbKey == null || tvdbKey.isEmpty) {
    stdout.writeln('TVDB_API_KEY not set: skipping shows.');
    return;
  }
  final tvdb = TvdbApi.direct(tvdbKey, language: french ? 'fra' : 'eng');
  final tmdbKey = Platform.environment['TMDB_API_KEY'];
  final tmdb = (tmdbKey != null && tmdbKey.isNotEmpty)
      ? TmdbApi.direct(tmdbKey, language: french ? 'fr-FR' : 'en-US')
      : null;
  if (tmdb == null) {
    stdout.writeln('TMDB_API_KEY not set: no streaming providers.');
  }

  var docs = await db.listAll('users/$uid/shows');
  if (onlyIncomplete) {
    docs = docs.where((d) => Show.fromJson(d.$2).isIncomplete).toList();
  }
  stdout.writeln(
    '${docs.length} shows to enrich from TheTVDB'
    '${onlyIncomplete ? ' (incomplete only)' : ''}…',
  );
  var updated = 0, errors = 0;

  for (final (i, (id, json)) in docs.indexed) {
    final show = Show.fromJson(json);
    try {
      final merged = await enrichShowFromTvdb(show, tvdb, tmdb: tmdb);
      await db.patch('users/$uid/shows/$id', merged.toJson());
      updated++;
      final added = merged.totalEpisodes - show.totalEpisodes;
      final prov = merged.providers.isEmpty
          ? ''
          : ' [${merged.providers.join(', ')}]';
      stdout.writeln(
        '  [${i + 1}/${docs.length}] ${show.title}${added > 0 ? ' (+$added ep.)' : ''}$prov',
      );
      await Future.delayed(const Duration(milliseconds: 250));
    } catch (e) {
      errors++;
      stdout.writeln('  [${i + 1}/${docs.length}] FAILED ${show.title}: $e');
    }
  }
  stdout.writeln('Shows: $updated enriched, $errors failed.');
}

Future<void> _enrichMovies(
  FirestoreRest db,
  String uid, {
  bool french = false,
}) async {
  final apiKey = Platform.environment['TMDB_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    stdout.writeln('TMDB_API_KEY not set: skipping movies.');
    return;
  }
  final tmdb = TmdbApi.direct(apiKey, language: french ? 'fr-FR' : 'en-US');
  final docs = await db.listAll('users/$uid/movies');
  stdout.writeln('${docs.length} movies to enrich from TMDB…');
  var updated = 0, skipped = 0, errors = 0;

  for (final (i, (id, json)) in docs.indexed) {
    final movie = Movie.fromJson(json);
    if (movie.imdbId == null || movie.imdbId!.isEmpty) {
      skipped++;
      continue;
    }
    try {
      final d = await tmdb.movieByImdb(movie.imdbId!);
      await Future.delayed(const Duration(milliseconds: 30));
      if (d == null) {
        skipped++;
        continue;
      }
      await db.patch(
        'users/$uid/movies/$id',
        movie
            .copyWith(
              tmdbId: d.id,
              poster: d.poster ?? movie.poster,
              backdrop: d.backdrop,
              overview: d.overview,
              runtime: d.runtime,
              metaRefreshedAt: DateTime.now(),
            )
            .toJson(),
      );
      updated++;
      if (updated % 25 == 0) {
        stdout.writeln('  [${i + 1}/${docs.length}] $updated movies…');
      }
    } catch (e) {
      errors++;
      stdout.writeln('  FAILED ${movie.title}: $e');
    }
  }
  stdout.writeln(
    'Movies: $updated enriched, $skipped without a match, $errors failed.',
  );
}
