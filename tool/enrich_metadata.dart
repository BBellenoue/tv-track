// Enrichissement one-shot des métadonnées dans Firestore :
//   - séries : TheTVDB (structure, titres/résumés d'épisodes FR, images, dates,
//     statut, chaîne — sans toucher l'état vu/non-vu) + TMDB pour les
//     plateformes de streaming
//   - films : TMDB (posters, résumé, durée) si TMDB_API_KEY est défini
//
// Variables d'env : TVDB_API_KEY (séries, requis), TMDB_API_KEY (plateformes +
// films, optionnel).
//
// Usage :
//   TVDB_API_KEY=… TMDB_API_KEY=… dart run tool/enrich_metadata.dart \
//     --uid <UID> [--project tv-track-perso] [--only shows|movies] [--incomplete]
//
// --incomplete : ne (ré)enrichit que les séries au contenu manquant
// (Show.isIncomplete), pour une réparation ciblée sans réécrire toute la base.
import 'dart:io';

import 'package:tv_track/data/models/movie.dart';
import 'package:tv_track/data/models/show.dart';
import 'package:tv_track/data/tmdb/tmdb_api.dart';
import 'package:tv_track/data/tvdb/enrichment.dart';
import 'package:tv_track/data/tvdb/tvdb_api.dart';

import 'firestore_rest.dart';

Future<void> main(List<String> args) async {
  final flags = args.where((a) => a.startsWith('--') && !a.contains('=')).toSet();
  final opts = {
    for (var i = 0; i + 1 < args.length; i += 2)
      if (args[i].startsWith('--') && !args[i + 1].startsWith('--'))
        args[i].substring(2): args[i + 1],
  };
  final uid = opts['uid'];
  if (uid == null) {
    stderr.writeln('Usage: dart run tool/enrich_metadata.dart --uid <UID>');
    exit(1);
  }
  final project = opts['project'] ?? 'tv-track-perso';
  final only = opts['only'];
  final onlyIncomplete = flags.contains('--incomplete');

  final db = FirestoreRest(project: project, token: await gcloudToken());

  if (only == null || only == 'shows') {
    await _enrichShows(db, uid, onlyIncomplete: onlyIncomplete);
  }
  if (only == null || only == 'movies') {
    await _enrichMovies(db, uid);
  }
  db.close();
}

Future<void> _enrichShows(FirestoreRest db, String uid,
    {bool onlyIncomplete = false}) async {
  final tvdbKey = Platform.environment['TVDB_API_KEY'];
  if (tvdbKey == null || tvdbKey.isEmpty) {
    stdout.writeln('TVDB_API_KEY absent → séries ignorées.');
    return;
  }
  final tvdb = TvdbApi(tvdbKey);
  // TMDB (optionnel) : plateformes de streaming FR où voir chaque série.
  final tmdbKey = Platform.environment['TMDB_API_KEY'];
  final tmdb = (tmdbKey != null && tmdbKey.isNotEmpty) ? TmdbApi(tmdbKey) : null;
  if (tmdb == null) {
    stdout.writeln('TMDB_API_KEY absent → pas de plateformes de streaming.');
  }

  var docs = await db.listAll('users/$uid/shows');
  if (onlyIncomplete) {
    docs = docs.where((d) => Show.fromJson(d.$2).isIncomplete).toList();
  }
  stdout.writeln('${docs.length} séries à enrichir via TheTVDB'
      '${onlyIncomplete ? ' (incomplètes uniquement)' : ''}…');
  var updated = 0, errors = 0;

  for (final (i, (id, json)) in docs.indexed) {
    final show = Show.fromJson(json);
    try {
      final merged = await enrichShowFromTvdb(show, tvdb, tmdb: tmdb);
      await db.patch('users/$uid/shows/$id', merged.toJson());
      updated++;
      final added = merged.totalEpisodes - show.totalEpisodes;
      final prov =
          merged.providers.isEmpty ? '' : ' [${merged.providers.join(', ')}]';
      stdout.writeln(
          '  [${i + 1}/${docs.length}] ${show.title}${added > 0 ? ' (+$added ép.)' : ''}$prov');
      await Future.delayed(const Duration(milliseconds: 250));
    } catch (e) {
      errors++;
      stdout.writeln('  [${i + 1}/${docs.length}] ERREUR ${show.title}: $e');
    }
  }
  stdout.writeln('Séries : $updated enrichies, $errors erreurs.');
}

Future<void> _enrichMovies(FirestoreRest db, String uid) async {
  final apiKey = Platform.environment['TMDB_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    stdout.writeln('TMDB_API_KEY absent → films ignorés (posters TMDB).');
    return;
  }
  final tmdb = TmdbApi(apiKey);
  final docs = await db.listAll('users/$uid/movies');
  stdout.writeln('${docs.length} films à enrichir via TMDB…');
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
        movie.copyWith(
          tmdbId: d.id,
          poster: d.poster ?? movie.poster,
          backdrop: d.backdrop,
          overview: d.overview,
          runtime: d.runtime,
          metaRefreshedAt: DateTime.now(),
        ).toJson(),
      );
      updated++;
      if (updated % 25 == 0) {
        stdout.writeln('  [${i + 1}/${docs.length}] $updated films…');
      }
    } catch (e) {
      errors++;
      stdout.writeln('  ERREUR ${movie.title}: $e');
    }
  }
  stdout.writeln(
      'Films : $updated enrichis, $skipped sans correspondance, $errors erreurs.');
}
