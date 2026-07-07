import 'dart:convert';

import 'package:collection/collection.dart';

import '../models/show.dart';
import '../tmdb/tmdb_api.dart';
import 'tvdb_api.dart';

/// Statut TheTVDB → statut interne de l'app (`Running`/`Ended`).
String? _mapStatus(String? s) => switch (s) {
      'Continuing' => 'Running',
      'Ended' => 'Ended',
      null => null,
      _ => s,
    };

/// Fusionne les métadonnées TheTVDB (déjà en français) dans un [Show] existant.
///
/// Règles :
/// - l'état de visionnage (watched/watchedAt) n'est JAMAIS modifié ;
/// - les épisodes existants (matchés par saison+numéro) reçoivent le titre FR,
///   le résumé FR, la date et la vignette de TheTVDB ; **le titre FR remplace**
///   un éventuel titre resté en anglais ;
/// - les épisodes inconnus (nouvelles saisons/épisodes) sont ajoutés non-vus,
///   avec un ID négatif déterministe -(saison*1000+numéro) pour ne jamais
///   entrer en collision avec les IDs TVDB positifs ;
/// - les specials (saison 0) sont ignorés (hors progression).
Show mergeTvdb(Show show, TvdbSeries series, {required DateTime now}) {
  final bySeason = groupBy(
      series.episodes.where((e) => !e.isSpecial && e.number > 0),
      (TvdbEpisode e) => e.season);

  final seasons = [...show.seasons];

  for (final entry in bySeason.entries) {
    final seasonNumber = entry.key;
    final index =
        seasons.indexWhere((s) => s.number == seasonNumber && !s.isSpecials);
    final existing = index >= 0 ? seasons[index] : null;
    final byNumber = {
      for (final e in existing?.episodes ?? const <Episode>[]) e.number: e,
    };

    final merged = <Episode>[];
    for (final remote in entry.value.sorted((a, b) => a.number - b.number)) {
      final local = byNumber.remove(remote.number);
      if (local != null) {
        merged.add(local.copyWith(
          // TheTVDB est la source de vérité du titre FR : il remplace un titre
          // local resté en anglais.
          name: remote.name.isNotEmpty ? remote.name : local.name,
          airDate: remote.airDate ?? local.airDate,
          overview: remote.overview ?? local.overview,
          still: remote.still ?? local.still,
        ));
      } else {
        merged.add(Episode(
          tvdbId: -(seasonNumber * 1000 + remote.number),
          number: remote.number,
          name: remote.name,
          airDate: remote.airDate,
          overview: remote.overview,
          still: remote.still,
        ));
      }
    }
    // Épisodes locaux absents de TheTVDB : on les garde (prudence).
    merged.addAll(byNumber.values);
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
    overview: series.overview ?? show.overview,
    poster: series.poster ?? show.poster,
    posterLarge: series.poster ?? show.posterLarge,
    airStatus: _mapStatus(series.status) ?? show.airStatus,
    network: series.network ?? show.network,
    metaRefreshedAt: now,
  );
}

/// Enrichit une série de bout en bout : structure + contenu FR + images depuis
/// **TheTVDB** (source principale), puis les **plateformes de streaming** depuis
/// TMDB (seule donnée que TheTVDB n'a pas). Best-effort : chaque appel qui
/// échoue laisse le champ existant intact. Utilisé par le refresh live, le
/// refresh par lots, l'ajout depuis Découverte et l'outil CLI.
Future<Show> enrichShowFromTvdb(
  Show show,
  TvdbApi tvdb, {
  TmdbApi? tmdb,
  DateTime? now,
}) async {
  final at = now ?? DateTime.now();

  final series = await tvdb.series(show.tvdbId);
  var out = series == null
      ? show.copyWith(metaRefreshedAt: at)
      : mergeTvdb(show, series, now: at);

  // Plateformes de streaming (JustWatch via TMDB) : rattache l'ID TMDB si besoin.
  if (tmdb != null) {
    final tmdbId = out.tmdbId ?? await tmdb.tvIdByTvdb(show.tvdbId);
    if (tmdbId != null) {
      out = out.copyWith(tmdbId: tmdbId);
      try {
        final providers = await tmdb.tvProviders(tmdbId);
        if (providers.isNotEmpty) out = out.copyWith(providers: providers);
      } catch (_) {
        // Plateformes indisponibles : non bloquant.
      }
    }
  }

  return _fitFirestore(out);
}

/// Firestore limite un document à 1 048 576 octets. Les séries à très grand
/// nombre d'épisodes (One Piece…) dépassent cette limite une fois chaque
/// épisode doté d'un résumé et d'une vignette. On allège alors le document par
/// paliers : d'abord les résumés d'épisodes, puis les vignettes — en gardant
/// toujours titres, dates et progression, qui sont légers.
Show _fitFirestore(Show show) {
  const maxBytes = 1000000; // marge sous la limite dure (1 048 576)
  int size(Show s) => utf8.encode(jsonEncode(s.toJson())).length;
  if (size(show) <= maxBytes) return show;

  var out = show.copyWith(seasons: [
    for (final s in show.seasons)
      s.copyWith(episodes: [
        for (final e in s.episodes) e.copyWith(overview: null),
      ]),
  ]);
  if (size(out) <= maxBytes) return out;

  return out.copyWith(seasons: [
    for (final s in out.seasons)
      s.copyWith(episodes: [
        for (final e in s.episodes) e.copyWith(still: null),
      ]),
  ]);
}
