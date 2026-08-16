import 'dart:convert';

import 'package:collection/collection.dart';

import '../models/show.dart';
import '../tmdb/tmdb_api.dart';
import 'tvdb_api.dart';

/// TheTVDB status vocabulary mapped onto the app's own.
String? _mapStatus(String? s) => switch (s) {
  'Continuing' => 'Running',
  'Ended' => 'Ended',
  null => null,
  _ => s,
};

/// Merges TheTVDB metadata into an existing [Show].
///
/// Watch state is never touched. Episodes are matched on season and number:
/// known ones take TheTVDB's title, overview, date and still, new ones are
/// appended as unwatched, and specials are dropped since they sit outside
/// progress tracking.
Show mergeTvdb(Show show, TvdbSeries series, {required DateTime now}) {
  final bySeason = groupBy(
    series.episodes.where((e) => !e.isSpecial && e.number > 0),
    (TvdbEpisode e) => e.season,
  );

  final seasons = [...show.seasons];

  for (final entry in bySeason.entries) {
    final seasonNumber = entry.key;
    final index = seasons.indexWhere(
      (s) => s.number == seasonNumber && !s.isSpecials,
    );
    final existing = index >= 0 ? seasons[index] : null;
    final byNumber = {
      for (final e in existing?.episodes ?? const <Episode>[]) e.number: e,
    };

    final merged = <Episode>[];
    for (final remote in entry.value.sorted((a, b) => a.number - b.number)) {
      final local = byNumber.remove(remote.number);
      if (local != null) {
        merged.add(
          local.copyWith(
            // TheTVDB wins on the title so a record left in another language
            // gets replaced rather than kept.
            name: remote.name.isNotEmpty ? remote.name : local.name,
            airDate: remote.airDate ?? local.airDate,
            overview: remote.overview ?? local.overview,
            still: remote.still ?? local.still,
          ),
        );
      } else {
        merged.add(
          Episode(
            tvdbId: -(seasonNumber * 1000 + remote.number),
            number: remote.number,
            name: remote.name,
            airDate: remote.airDate,
            overview: remote.overview,
            still: remote.still,
          ),
        );
      }
    }
    // Keep local episodes TheTVDB does not list rather than dropping them.
    merged.addAll(byNumber.values);
    merged.sort((a, b) => a.number - b.number);

    final season = (existing ?? Season(number: seasonNumber)).copyWith(
      episodes: merged,
    );
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

/// Enriches a show end to end: structure, text and artwork from TheTVDB, then
/// streaming providers from TMDB — the one thing TheTVDB does not carry.
///
/// Best effort throughout: a call that fails leaves the existing field alone.
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

  if (tmdb != null) {
    final tmdbId = out.tmdbId ?? await tmdb.tvIdByTvdb(show.tvdbId);
    if (tmdbId != null) {
      out = out.copyWith(tmdbId: tmdbId);
      try {
        final providers = await tmdb.tvProviders(tmdbId);
        if (providers.isNotEmpty) out = out.copyWith(providers: providers);
      } catch (_) {
        // Providers are a nice-to-have, never a reason to fail the refresh.
      }
    }
  }

  return _fitFirestore(out);
}

/// Firestore caps a document at 1,048,576 bytes. Shows with a very large
/// episode count (One Piece and friends) blow past that once every episode
/// carries an overview and a still, so drop weight in stages — overviews
/// first, then stills. Titles, dates and progress are small and always kept.
Show _fitFirestore(Show show) {
  const maxBytes = 1000000; // headroom under the hard limit
  int size(Show s) => utf8.encode(jsonEncode(s.toJson())).length;
  if (size(show) <= maxBytes) return show;

  var out = show.copyWith(
    seasons: [
      for (final s in show.seasons)
        s.copyWith(
          episodes: [for (final e in s.episodes) e.copyWith(overview: null)],
        ),
    ],
  );
  if (size(out) <= maxBytes) return out;

  return out.copyWith(
    seasons: [
      for (final s in out.seasons)
        s.copyWith(
          episodes: [for (final e in s.episodes) e.copyWith(still: null)],
        ),
    ],
  );
}
