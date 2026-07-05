// Enrichissement one-shot des métadonnées dans Firestore :
//   - séries : TVmaze (posters, statut, chaîne, dates de diffusion,
//     nouveaux épisodes fusionnés sans toucher l'état vu/non-vu)
//   - films : TMDB (posters) si TMDB_API_KEY est défini dans l'environnement
//
// Usage :
//   dart run tool/enrich_metadata.dart --uid <UID> [--project tv-track-perso] [--only shows|movies]
//
// TVmaze limite à ~20 req/10 s → ~600 ms entre requêtes (2 req/série,
// comptez ~5 min pour 224 séries).
import 'dart:io';

import 'package:tv_track/data/models/movie.dart';
import 'package:tv_track/data/models/show.dart';
import 'package:tv_track/data/tmdb/tmdb_api.dart';
import 'package:tv_track/data/tvmaze/enrichment.dart';
import 'package:tv_track/data/tvmaze/tvmaze_api.dart';

import 'firestore_rest.dart';

Future<void> main(List<String> args) async {
  final opts = {
    for (var i = 0; i + 1 < args.length; i += 2)
      if (args[i].startsWith('--')) args[i].substring(2): args[i + 1],
  };
  final uid = opts['uid'];
  if (uid == null) {
    stderr.writeln('Usage: dart run tool/enrich_metadata.dart --uid <UID>');
    exit(1);
  }
  final project = opts['project'] ?? 'tv-track-perso';
  final only = opts['only'];

  final db = FirestoreRest(project: project, token: await gcloudToken());

  if (only == null || only == 'shows') {
    await _enrichShows(db, uid);
  }
  if (only == null || only == 'movies') {
    await _enrichMovies(db, uid);
  }
  db.close();
}

Future<void> _enrichShows(FirestoreRest db, String uid) async {
  final tvmaze = TvmazeApi();
  // TMDB (optionnel) : plateformes de streaming FR où voir chaque série.
  final tmdbKey = Platform.environment['TMDB_API_KEY'];
  final tmdb = (tmdbKey != null && tmdbKey.isNotEmpty) ? TmdbApi(tmdbKey) : null;
  if (tmdb == null) {
    stdout.writeln('TMDB_API_KEY absent → pas de plateformes de streaming.');
  }

  final docs = await db.listAll('users/$uid/shows');
  stdout.writeln('${docs.length} séries à enrichir via TVmaze…');
  var updated = 0, missing = 0, errors = 0;

  for (final (i, (id, json)) in docs.indexed) {
    final show = Show.fromJson(json);
    try {
      final meta = await tvmaze.lookupByTvdb(show.tvdbId);
      await Future.delayed(const Duration(milliseconds: 600));
      if (meta == null) {
        missing++;
        stdout.writeln('  [${i + 1}/${docs.length}] introuvable : ${show.title}');
        continue;
      }
      final episodes = await tvmaze.episodes(meta.id);
      await Future.delayed(const Duration(milliseconds: 600));
      var merged = mergeTvmaze(show, meta, episodes, now: DateTime.now());

      if (tmdb != null) {
        try {
          final tmdbId = await tmdb.tvIdByTvdb(show.tvdbId);
          if (tmdbId != null) {
            final providers = await tmdb.tvProviders(tmdbId);
            merged = merged.copyWith(tmdbId: tmdbId, providers: providers);
          }
        } catch (_) {
          // Providers best-effort : on garde le reste de l'enrichissement.
        }
      }

      await db.patch('users/$uid/shows/$id', merged.toJson());
      updated++;
      final added = merged.totalEpisodes - show.totalEpisodes;
      final prov = merged.providers.isEmpty ? '' : ' [${merged.providers.join(', ')}]';
      stdout.writeln(
          '  [${i + 1}/${docs.length}] ${show.title}${added > 0 ? ' (+$added ép.)' : ''}$prov');
    } catch (e) {
      errors++;
      stdout.writeln('  [${i + 1}/${docs.length}] ERREUR ${show.title}: $e');
    }
  }
  stdout.writeln(
      'Séries : $updated enrichies, $missing introuvables, $errors erreurs.');
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
      final poster = await tmdb.moviePosterByImdb(movie.imdbId!);
      await Future.delayed(const Duration(milliseconds: 30));
      if (poster == null) {
        skipped++;
        continue;
      }
      await db.patch(
        'users/$uid/movies/$id',
        movie
            .copyWith(poster: poster, metaRefreshedAt: DateTime.now())
            .toJson(),
      );
      updated++;
      if (updated % 25 == 0) {
        stdout.writeln('  [${i + 1}/${docs.length}] $updated posters…');
      }
    } catch (e) {
      errors++;
      stdout.writeln('  ERREUR ${movie.title}: $e');
    }
  }
  stdout.writeln(
      'Films : $updated posters, $skipped sans correspondance, $errors erreurs.');
}
