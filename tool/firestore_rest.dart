// Helpers REST Firestore pour les outils CLI (seed, enrichissement).
// Accès via token OAuth gcloud (IAM) : les security rules ne s'appliquent pas.
import 'dart:convert';
import 'dart:io';

const base = 'https://firestore.googleapis.com/v1';

class FirestoreRest {
  FirestoreRest({required this.project, required this.token})
      : _client = HttpClient();

  final String project;
  final String token;
  final HttpClient _client;

  String get _root => 'projects/$project/databases/(default)/documents';

  Future<Map<String, dynamic>> _json(HttpClientRequest request,
      [Object? body]) async {
    request.headers
      ..set('Authorization', 'Bearer $token')
      ..contentType = ContentType.json;
    if (body != null) request.write(jsonEncode(body));
    final response = await request.close();
    final text = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode}: $text');
    }
    return jsonDecode(text) as Map<String, dynamic>;
  }

  /// Liste tous les documents d'une collection (suit la pagination).
  /// Retourne des paires (id, json décodé).
  Future<List<(String, Map<String, dynamic>)>> listAll(String path) async {
    final docs = <(String, Map<String, dynamic>)>[];
    String? pageToken;
    do {
      final query = pageToken == null
          ? 'pageSize=300'
          : 'pageSize=300&pageToken=$pageToken';
      final uri = Uri.parse('$base/$_root/$path?$query');
      final data = await _json(await _client.getUrl(uri));
      for (final doc
          in (data['documents'] as List? ?? []).cast<Map<String, dynamic>>()) {
        final id = (doc['name'] as String).split('/').last;
        docs.add((id, decodeFields(doc['fields'] as Map<String, dynamic>)));
      }
      pageToken = data['nextPageToken'] as String?;
    } while (pageToken != null);
    return docs;
  }

  Future<void> patch(String path, Map<String, dynamic> json) async {
    final uri = Uri.parse('$base/$_root/$path');
    await _json(await _client.patchUrl(uri), {'fields': encodeFields(json)});
  }

  void close() => _client.close();
}

/// JSON Dart → format "typed value" de l'API REST Firestore.
Map<String, dynamic> encodeValue(Object? v) => switch (v) {
      null => {'nullValue': null},
      bool b => {'booleanValue': b},
      int i => {'integerValue': '$i'},
      double d => {'doubleValue': d},
      String s => {'stringValue': s},
      List l => {
          'arrayValue': {'values': [for (final e in l) encodeValue(e)]}
        },
      Map m => {
          'mapValue': {'fields': encodeFields(m.cast<String, dynamic>())}
        },
      _ => throw ArgumentError('type non géré: ${v.runtimeType}'),
    };

Map<String, dynamic> encodeFields(Map<String, dynamic> json) =>
    {for (final e in json.entries) e.key: encodeValue(e.value)};

/// Format "typed value" → JSON Dart.
Object? decodeValue(Map<String, dynamic> v) {
  if (v.containsKey('nullValue')) return null;
  if (v.containsKey('booleanValue')) return v['booleanValue'];
  if (v.containsKey('integerValue')) return int.parse(v['integerValue']);
  if (v.containsKey('doubleValue')) return (v['doubleValue'] as num).toDouble();
  if (v.containsKey('stringValue')) return v['stringValue'];
  if (v.containsKey('timestampValue')) return v['timestampValue'];
  if (v.containsKey('arrayValue')) {
    return [
      for (final e in ((v['arrayValue'] as Map)['values'] as List? ?? []))
        decodeValue((e as Map).cast<String, dynamic>()),
    ];
  }
  if (v.containsKey('mapValue')) {
    return decodeFields(
        ((v['mapValue'] as Map)['fields'] as Map? ?? {}).cast());
  }
  throw ArgumentError('valeur non gérée: ${v.keys}');
}

Map<String, dynamic> decodeFields(Map<String, dynamic> fields) =>
    {for (final e in fields.entries) e.key: decodeValue((e.value as Map).cast())};

Future<String> gcloudToken() async {
  final r = await Process.run('gcloud', ['auth', 'print-access-token']);
  if (r.exitCode != 0) {
    stderr.writeln('gcloud auth print-access-token a échoué: ${r.stderr}');
    exit(1);
  }
  return (r.stdout as String).trim();
}
