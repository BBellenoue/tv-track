import 'package:collection/collection.dart';

import '../models/show.dart';
import '../tmdb/tmdb_api.dart';
import 'tvmaze_api.dart';

/// Fusionne les métadonnées TVmaze dans un [Show] existant.
///
/// Règles :
/// - l'état de visionnage (watched/watchedAt) n'est JAMAIS modifié ;
/// - les épisodes existants (matchés par saison+numéro) reçoivent nom
///   manquant et date de diffusion ;
/// - les épisodes inconnus (nouvelles saisons/épisodes depuis l'export) sont
///   ajoutés non-vus, avec un ID négatif déterministe -(saison*1000+numéro)
///   pour ne jamais entrer en collision avec les IDs TVDB (positifs) ;
/// - les specials TVmaze non présents dans l'export sont ignorés (ils
///   n'entrent pas dans la progression).
Show mergeTvmaze(
  Show show,
  TvmazeShow meta,
  List<TvmazeEpisode> episodes, {
  required DateTime now,
}) {
  final bySeason = groupBy(episodes.where((e) => !e.isSpecial && e.number > 0),
      (TvmazeEpisode e) => e.season);

  final seasons = [...show.seasons];

  for (final entry in bySeason.entries) {
    final seasonNumber = entry.key;
    final index = seasons
        .indexWhere((s) => s.number == seasonNumber && !s.isSpecials);
    final existing = index >= 0 ? seasons[index] : null;
    final episodesByNumber = {
      for (final e in existing?.episodes ?? const <Episode>[]) e.number: e,
    };

    final merged = <Episode>[];
    for (final remote in entry.value.sorted((a, b) => a.number - b.number)) {
      final local = episodesByNumber.remove(remote.number);
      if (local != null) {
        merged.add(local.copyWith(
          name: local.name.isEmpty ? remote.name : local.name,
          airDate: remote.airstamp ?? local.airDate,
          overview: remote.summary ?? local.overview,
          still: remote.image ?? local.still,
        ));
      } else {
        merged.add(Episode(
          tvdbId: -(seasonNumber * 1000 + remote.number),
          number: remote.number,
          name: remote.name,
          airDate: remote.airstamp,
          overview: remote.summary,
          still: remote.image,
        ));
      }
    }
    // Épisodes locaux absents de TVmaze : on les garde (prudence).
    merged.addAll(episodesByNumber.values);
    merged.sort((a, b) => a.number - b.number);

    final season =
        (existing ?? Season(number: seasonNumber)).copyWith(episodes: merged);
    if (index >= 0) {
      seasons[index] = season;
    } else {
      seasons.add(season);
    }
  }
  seasons.sortBy<num>((s) => s.number);

  return show.copyWith(
    seasons: seasons,
    tvmazeId: meta.id,
    poster: meta.imageMedium ?? show.poster,
    posterLarge: meta.imageOriginal ?? show.posterLarge,
    airStatus: meta.status ?? show.airStatus,
    network: meta.network ?? show.network,
    overview: meta.summary ?? show.overview,
    metaRefreshedAt: now,
  );
}

/// Superpose l'enrichissement TMDB **français** sur une série déjà structurée
/// par TVmaze : rattache l'ID TMDB, remplace le résumé et (à défaut d'affiche)
/// le poster par leurs versions FR, renseigne les plateformes de streaming, et
/// localise titres + résumés d'épisodes. Best-effort : chaque appel qui échoue
/// laisse le champ existant intact — on ne dégrade jamais vers l'anglais.
///
/// C'est l'étape qui manquait au rafraîchissement in-app : sans elle, un pull
/// TVmaze réécrivait le synopsis français en anglais. Utilisée aussi par
/// `tool/enrich_metadata.dart` pour garantir un comportement identique.
Future<Show> applyTmdbFrench(Show show, TmdbApi tmdb) async {
  final tmdbId = show.tmdbId ?? await tmdb.tvIdByTvdb(show.tvdbId);
  if (tmdbId == null) return show;
  var out = show.copyWith(tmdbId: tmdbId);

  try {
    final d = await tmdb.tvDetailsFr(tmdbId);
    out = out.copyWith(
      overview: d.overview ?? out.overview,
      // Le poster TVmaze prime s'il existe ; TMDB comble les fiches sans image.
      poster: out.poster ?? d.poster,
      posterLarge: out.posterLarge ?? d.posterLarge,
    );
  } catch (_) {
    // Réseau/API : on garde le reste de l'enrichissement.
  }

  try {
    final providers = await tmdb.tvProviders(tmdbId);
    if (providers.isNotEmpty) out = out.copyWith(providers: providers);
  } catch (_) {
    // Plateformes indisponibles : non bloquant.
  }

  return _overlayFrenchEpisodes(out, tmdb, tmdbId);
}

/// Superpose les titres et résumés d'épisodes en français (TMDB) sur une série
/// déjà structurée par TVmaze. On ne touche jamais à l'état de visionnage ni
/// aux dates ; on ne remplace un champ que si TMDB a une valeur française.
Future<Show> _overlayFrenchEpisodes(
    Show show, TmdbApi tmdb, int tmdbId) async {
  final seasons = <Season>[];
  for (final season in show.seasons) {
    if (season.isSpecials || season.episodes.isEmpty) {
      seasons.add(season);
      continue;
    }
    Map<int, TmdbEpisode> fr;
    try {
      fr = await tmdb.tvSeasonFr(tmdbId, season.number);
      await Future.delayed(const Duration(milliseconds: 40));
    } catch (_) {
      seasons.add(season);
      continue;
    }
    seasons.add(season.copyWith(episodes: [
      for (final ep in season.episodes)
        if (fr[ep.number] case final f?)
          ep.copyWith(
            name: f.name ?? ep.name,
            overview: f.overview ?? ep.overview,
            // Date et vignette : repli TMDB uniquement si TVmaze n'a rien fourni
            // (cas d'une saison inconnue de TVmaze, ex. Berlin S2 sur Netflix).
            airDate: ep.airDate ?? f.airDate,
            still: ep.still ?? f.still,
          )
        else
          ep,
    ]));
  }
  return show.copyWith(seasons: seasons);
}
