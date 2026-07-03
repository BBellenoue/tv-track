// Seed one-shot d'un export TV Time vers Firestore (hors app).
//
// Écrit users/{uid}/shows/{tvdbId} et users/{uid}/movies/{tvdbId} au même
// format JSON que l'app (réutilise TvTimeParser + toJson des modèles).
// L'accès passe par l'API REST Firestore avec un token OAuth gcloud (IAM),
// les security rules ne s'appliquent donc pas.
//
// Usage :
//   dart run tool/seed_tvtime.dart \
//     --uid <FIREBASE_AUTH_UID> \
//     --series <tvtime-series-*.json> \
//     --movies <tvtime-movies-*.json> \
//     [--project tv-track-perso] \
//     [--token "$(gcloud auth print-access-token)"]
import 'dart:convert';
import 'dart:io';

import 'package:tv_track/data/tvtime/tvtime_parser.dart';

const _base = 'https://firestore.googleapis.com/v1';

Future<void> main(List<String> args) async {
  final opts = _parseArgs(args);
  final uid = opts['uid'] ?? _fail('--uid manquant');
  final project = opts['project'] ?? 'tv-track-perso';
  final token = opts['token'] ??
      (await _run('gcloud', ['auth', 'print-access-token'])).trim();

  final contents = [
    if (opts['series'] != null) File(opts['series']!).readAsStringSync(),
    if (opts['movies'] != null) File(opts['movies']!).readAsStringSync(),
  ];
  if (contents.isEmpty) _fail('fournir --series et/ou --movies');
  final parsed = TvTimeParser.parseFiles(contents);
  stdout.writeln(
      '${parsed.shows.length} séries, ${parsed.movies.length} films à écrire '
      'dans users/$uid (projet $project)');

  final client = HttpClient();
  final root = 'projects/$project/databases/(default)/documents';
  var done = 0;

  Future<void> write(String collection, int id, Map<String, dynamic> json) async {
    final uri = Uri.parse('$_base/$root/users/$uid/$collection/$id');
    final request = await client.patchUrl(uri);
    request.headers
      ..set('Authorization', 'Bearer $token')
      ..contentType = ContentType.json;
    request.write(jsonEncode({'fields': _fields(json)}));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      _fail('HTTP ${response.statusCode} sur $collection/$id : $body');
    }
    done++;
    if (done % 50 == 0) stdout.writeln('  $done docs…');
  }

  for (final show in parsed.shows) {
    await write('shows', show.tvdbId, show.toJson());
  }
  for (final movie in parsed.movies) {
    await write('movies', movie.tvdbId, movie.toJson());
  }
  client.close();
  stdout.writeln('Terminé : $done documents écrits.');
}

/// Encode une valeur JSON Dart au format "typed value" de l'API REST Firestore.
Map<String, dynamic> _value(Object? v) => switch (v) {
      null => {'nullValue': null},
      bool b => {'booleanValue': b},
      int i => {'integerValue': '$i'},
      double d => {'doubleValue': d},
      String s => {'stringValue': s},
      List l => {
          'arrayValue': {'values': [for (final e in l) _value(e)]}
        },
      Map m => {
          'mapValue': {'fields': _fields(m.cast<String, dynamic>())}
        },
      _ => throw ArgumentError('type non géré: ${v.runtimeType}'),
    };

Map<String, dynamic> _fields(Map<String, dynamic> json) =>
    {for (final e in json.entries) e.key: _value(e.value)};

Map<String, String> _parseArgs(List<String> args) => {
      for (var i = 0; i + 1 < args.length; i += 2)
        if (args[i].startsWith('--')) args[i].substring(2): args[i + 1],
    };

Future<String> _run(String cmd, List<String> a) async {
  final r = await Process.run(cmd, a);
  if (r.exitCode != 0) _fail('$cmd a échoué: ${r.stderr}');
  return r.stdout as String;
}

Never _fail(String message) {
  stderr.writeln('Erreur : $message');
  exit(1);
}
