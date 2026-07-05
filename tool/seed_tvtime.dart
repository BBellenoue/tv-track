// Seed one-shot d'un export TV Time vers Firestore (hors app).
//
// Écrit users/{uid}/shows/{tvdbId} et users/{uid}/movies/{tvdbId} au même
// format JSON que l'app (réutilise TvTimeParser + toJson des modèles).
//
// Usage :
//   dart run tool/seed_tvtime.dart \
//     --uid <FIREBASE_AUTH_UID> \
//     --series <tvtime-series-*.json> \
//     --movies <tvtime-movies-*.json> \
//     [--project tv-track-perso]
import 'dart:io';

import 'package:tv_track/data/tvtime/tvtime_parser.dart';

import 'firestore_rest.dart';

Future<void> main(List<String> args) async {
  final opts = {
    for (var i = 0; i + 1 < args.length; i += 2)
      if (args[i].startsWith('--')) args[i].substring(2): args[i + 1],
  };
  final uid = opts['uid'];
  if (uid == null) {
    stderr.writeln('Erreur : --uid manquant');
    exit(1);
  }
  final project = opts['project'] ?? 'tv-track-perso';

  final contents = [
    if (opts['series'] != null) File(opts['series']!).readAsStringSync(),
    if (opts['movies'] != null) File(opts['movies']!).readAsStringSync(),
  ];
  if (contents.isEmpty) {
    stderr.writeln('Erreur : fournir --series et/ou --movies');
    exit(1);
  }
  final parsed = TvTimeParser.parseFiles(contents);
  stdout.writeln(
      '${parsed.shows.length} séries, ${parsed.movies.length} films à écrire '
      'dans users/$uid (projet $project)');

  final db = FirestoreRest(project: project, token: await gcloudToken());
  var done = 0;

  for (final show in parsed.shows) {
    await db.patch('users/$uid/shows/${show.tvdbId}', show.toJson());
    if (++done % 50 == 0) stdout.writeln('  $done docs…');
  }
  for (final movie in parsed.movies) {
    await db.patch('users/$uid/movies/${movie.tvdbId}', movie.toJson());
    if (++done % 50 == 0) stdout.writeln('  $done docs…');
  }
  db.close();
  stdout.writeln('Terminé : $done documents écrits.');
}
