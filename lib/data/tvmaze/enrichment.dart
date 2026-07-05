import 'package:collection/collection.dart';

import '../models/show.dart';
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
        ));
      } else {
        merged.add(Episode(
          tvdbId: -(seasonNumber * 1000 + remote.number),
          number: remote.number,
          name: remote.name,
          airDate: remote.airstamp,
          overview: remote.summary,
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
