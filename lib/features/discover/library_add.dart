import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers.dart';
import '../../data/models/movie.dart';
import '../../data/models/show.dart';
import '../../data/tmdb/catalog_item.dart';
import '../../data/tvdb/enrichment.dart';

part 'library_add.g.dart';

/// Ajout d'un élément de catalogue (série ou film) à la liste de l'utilisateur.
/// Réutilisé par le deck, les rails, la grille et la recherche.
@riverpod
class LibraryAdd extends _$LibraryAdd {
  @override
  void build() {}

  /// True si l'élément est déjà suivi (série ou film selon son type).
  bool isTracked(CatalogItem item) {
    final ids = item.kind.isTv
        ? ref.read(trackedShowTmdbIdsProvider)
        : ref.read(trackedMovieTmdbIdsProvider);
    return ids.contains(item.tmdbId);
  }

  /// Ajoute l'élément à la liste. Retourne false si déjà présent ou échec.
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
      if (tvdbId == null) return false; // non rattachable à TheTVDB
      if ((ref.read(showsProvider).value ?? const [])
          .any((s) => s.tvdbId == tvdbId)) {
        return false;
      }
      // Fiche de base depuis la carte Découverte (déjà en FR)…
      var show = Show(
        tvdbId: tvdbId,
        title: item.title,
        tmdbId: item.tmdbId,
        overview: item.overview,
        posterLarge: item.backdropUrl,
      );
      // …puis structure + épisodes FR via TheTVDB, plateformes via TMDB.
      if (tvdb != null) {
        show = await enrichShowFromTvdb(show, tvdb, tmdb: tmdb);
      } else {
        show = show.copyWith(
          providers:
              await tmdb.tvProviders(item.tmdbId).catchError((_) => <String>[]),
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
      final imdbId = await tmdb.movieImdbId(item.tmdbId).catchError((_) => null);
      // Doc key : tmdbId (les films importés portent leur tmdbId en champ ;
      // ceux ajoutés ici utilisent tmdbId aussi comme identifiant de doc).
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
