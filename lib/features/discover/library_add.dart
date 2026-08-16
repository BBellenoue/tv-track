import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers.dart';
import '../../data/models/movie.dart';
import '../../data/models/show.dart';
import '../../data/tmdb/catalog_item.dart';
import '../../data/tvdb/enrichment.dart';

part 'library_add.g.dart';

/// Adds a catalog entry to the user's library. Shared by the swipe deck, the
/// browse rails, the category grid and search.
@riverpod
class LibraryAdd extends _$LibraryAdd {
  @override
  void build() {}

  bool isTracked(CatalogItem item) {
    final ids = item.kind.isTv
        ? ref.read(trackedShowTmdbIdsProvider)
        : ref.read(trackedMovieTmdbIdsProvider);
    return ids.contains(item.tmdbId);
  }

  /// Returns false when the entry is already tracked or the add failed.
  Future<bool> add(CatalogItem item) async {
    if (isTracked(item)) return false;
    return item.kind.isTv ? _addTv(item) : _addMovie(item);
  }

  Future<bool> _addTv(CatalogItem item) async {
    final repo = ref.read(trackingRepositoryProvider);
    final tmdb = ref.read(tmdbApiProvider);
    final tvdb = ref.read(tvdbApiProvider);
    if (repo == null || tmdb == null) return false;
    try {
      final tvdbId = await tmdb.tvdbIdByTmdb(item.tmdbId);
      if (tvdbId == null) return false; // no TheTVDB counterpart to track
      if ((ref.read(showsProvider).value ?? const []).any(
        (s) => s.tvdbId == tvdbId,
      )) {
        return false;
      }
      // Start from what the catalog card already carries…
      var show = Show(
        tvdbId: tvdbId,
        title: item.title,
        tmdbId: item.tmdbId,
        overview: item.overview,
        posterLarge: item.backdropUrl,
      );
      // …then fill in seasons and episodes from TheTVDB, providers from TMDB.
      if (tvdb != null) {
        show = await enrichShowFromTvdb(show, tvdb, tmdb: tmdb);
      } else {
        show = show.copyWith(
          providers: await tmdb
              .tvProviders(item.tmdbId)
              .catchError((_) => <String>[]),
        );
      }
      await repo.saveShow(show);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _addMovie(CatalogItem item) async {
    final repo = ref.read(trackingRepositoryProvider);
    final tmdb = ref.read(tmdbApiProvider);
    if (repo == null || tmdb == null) return false;
    try {
      final imdbId = await tmdb
          .movieImdbId(item.tmdbId)
          .catchError((_) => null);
      // Movies added here key their document on the TMDB id, since they have
      // no TheTVDB id to key on.
      final movie = Movie(
        tvdbId: item.tmdbId,
        tmdbId: item.tmdbId,
        imdbId: imdbId,
        title: item.title,
        year: item.year,
        poster: item.posterUrl,
        backdrop: item.backdropUrl,
        overview: item.overview,
        addedAt: DateTime.now(),
      );
      await repo.saveMovie(movie);
      return true;
    } catch (_) {
      return false;
    }
  }
}
