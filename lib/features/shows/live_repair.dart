import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers.dart';
import '../../data/models/movie.dart';
import '../../data/models/show.dart';
import '../../data/tmdb/tmdb_api.dart';
import '../../data/tvdb/enrichment.dart';

part 'live_repair.g.dart';

/// Réparation « live » d'une fiche isolée, déclenchée à l'ouverture de son écran
/// de détail quand le contenu est incomplet (voir [Show.isIncomplete] /
/// [Movie.isIncomplete]) : synopsis, affiche, image de fond, épisodes ou durée
/// manquants, ou affichage resté en anglais.
///
/// Complète le rafraîchissement par lots ([MetadataRefresh], à l'ouverture de
/// l'app / pull-to-refresh) : ici on cible une seule fiche, immédiatement,
/// sans attendre le prochain balayage.
///
/// Garde-fous :
/// - **anti-boucle** : chaque fiche n'est tentée qu'une fois par session, même
///   si elle reste incomplète (TMDB/TVmaze peut ne rien avoir) — évite de
///   marteler l'API à chaque rebuild ou réouverture ;
/// - **dédup in-flight** : une réparation déjà en cours n'est pas relancée.
///
/// L'état exposé est l'ensemble des clés en cours (`show-<id>` / `movie-<id>`),
/// pour qu'un écran affiche un indicateur « Mise à jour… ».
@Riverpod(keepAlive: true)
class LiveRepair extends _$LiveRepair {
  final _inFlight = <String>{};
  final _attempted = <String>{};

  @override
  Set<String> build() => const {};

  bool isRepairing(String key) => _inFlight.contains(key);

  /// Répare une série : structure, titres/résumés d'épisodes en français,
  /// images, dates, statut et chaîne via **TheTVDB** (source principale), puis
  /// les plateformes de streaming via TMDB. Ne dégrade jamais un champ déjà
  /// renseigné (voir [enrichShowFromTvdb]).
  Future<void> repairShow(Show show) async {
    final key = 'show-${show.tvdbId}';
    if (_attempted.contains(key) || _inFlight.contains(key)) return;
    final repo = ref.read(trackingRepositoryProvider);
    final tvdb = ref.read(tvdbApiProvider);
    if (repo == null || tvdb == null) return;

    _attempted.add(key);
    _begin(key);
    try {
      final merged = await enrichShowFromTvdb(
        show,
        tvdb,
        tmdb: ref.read(tmdbApiProvider),
      );
      // Toujours tamponner (enrichShowFromTvdb le fait), même si la fiche est
      // introuvable côté TheTVDB, pour rester cohérent avec le refresh par lots.
      await repo.saveShow(merged);
    } catch (_) {
      // Réseau/API : on réessaiera à la prochaine session.
    } finally {
      _end(key);
    }
  }

  /// Répare un film via TMDB : par son ID TMDB si connu, sinon via l'IMDB de
  /// l'export. Ne remplace le synopsis anglais que par une version française.
  Future<void> repairMovie(Movie movie) async {
    final key = 'movie-${movie.tvdbId}';
    if (_attempted.contains(key) || _inFlight.contains(key)) return;
    final repo = ref.read(trackingRepositoryProvider);
    final tmdb = ref.read(tmdbApiProvider);
    if (repo == null || tmdb == null) return;

    _attempted.add(key);
    _begin(key);
    try {
      TmdbMovie? d;
      if (movie.tmdbId != null) {
        d = await tmdb.movieDetailsFr(movie.tmdbId!);
      } else if (movie.imdbId != null) {
        d = await tmdb.movieByImdb(movie.imdbId!);
      }

      if (d == null) {
        await repo.saveMovie(movie.copyWith(metaRefreshedAt: DateTime.now()));
        return;
      }

      // Le synopsis local est gardé sauf s'il est absent ou resté en anglais.
      final keepOverview =
          (movie.overview?.isNotEmpty ?? false) && !looksEnglish(movie.overview);
      await repo.saveMovie(movie.copyWith(
        tmdbId: movie.tmdbId ?? d.id,
        poster: movie.poster ?? d.poster,
        backdrop: movie.backdrop ?? d.backdrop,
        overview: keepOverview ? movie.overview : (d.overview ?? movie.overview),
        runtime: (movie.runtime != null && movie.runtime! > 0)
            ? movie.runtime
            : d.runtime,
        metaRefreshedAt: DateTime.now(),
      ));
    } catch (_) {
      // Réseau/API : on réessaiera à la prochaine session.
    } finally {
      _end(key);
    }
  }

  void _begin(String key) {
    _inFlight.add(key);
    state = {..._inFlight};
  }

  void _end(String key) {
    _inFlight.remove(key);
    state = {..._inFlight};
  }
}
