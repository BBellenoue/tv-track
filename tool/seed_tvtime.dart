// One-shot import of a TV Time export into Firestore, outside the app.
//
// Writes users/{uid}/shows/{tvdbId} and users/{uid}/movies/{tvdbId} in exactly
// the shape the app reads, by reusing its parser and models. Idempotent: one
// document per id, safe to re-run.
//
// Usage:
//   dart run tool/seed_tvtime.dart \
//     --uid <FIREBASE_AUTH_UID> \
//     --project <FIREBASE_PROJECT_ID> \
//     --series <tvtime-series-*.json> \
//     --movies <tvtime-movies-*.json>
import 'dart:io';

import 'package:tv_track/data/tvtime/tvtime_parser.dart';

import 'firestore_rest.dart';

Future<void> main(List<String> args) async {
  final opts = {
    for (var i = 0; i + 1 < args.length; i += 2)
      if (args[i].startsWith('--')) args[i].substring(2): args[i + 1],
  };
  final uid = opts['uid'];
  final project = opts['project'];
  if (uid == null || project == null) {
    stderr.writeln(
      'Usage: dart run tool/seed_tvtime.dart '
      '--uid <UID> --project <PROJECT_ID> [--series f.json] [--movies f.json]',
    );
    exit(1);
  }

  final contents = [
    if (opts['series'] != null) File(opts['series']!).readAsStringSync(),
    if (opts['movies'] != null) File(opts['movies']!).readAsStringSync(),
  ];
  if (contents.isEmpty) {
    stderr.writeln('Nothing to do: pass --series and/or --movies.');
    exit(1);
  }
  final parsed = TvTimeParser.parseFiles(contents);
  stdout.writeln(
    '${parsed.shows.length} shows, ${parsed.movies.length} movies '
    'to write into users/$uid (project $project)',
  );

  final db = FirestoreRest(project: project, token: await gcloudToken());
  var done = 0;

  for (final show in parsed.shows) {
    await db.patch('users/$uid/shows/${show.tvdbId}', show.toJson());
    if (++done % 50 == 0) stdout.writeln('  $done documents…');
  }
  for (final movie in parsed.movies) {
    await db.patch('users/$uid/movies/${movie.tvdbId}', movie.toJson());
    if (++done % 50 == 0) stdout.writeln('  $done documents…');
  }
  db.close();
  stdout.writeln('Done: $done documents written.');
}
