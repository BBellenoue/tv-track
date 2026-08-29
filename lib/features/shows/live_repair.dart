import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/locale.dart';
import '../../core/providers.dart';
import '../../data/models/movie.dart';
import '../../data/models/show.dart';
import '../../data/tmdb/tmdb_api.dart';
import '../../data/tvdb/enrichment.dart';

part 'live_repair.g.dart';

/// Repairs a single record on demand, when its detail screen opens and finds
/// something missing. Complements the batch [MetadataRefresh] by fixing the
/// one record the user is looking at right now.
///
/// Each record is attempted at most once per session even if it stays
/// incomplete (a provider may simply have nothing), which keeps a rebuild or
/// a reopen from hammering the API.
///
/// The exposed state is the set of in-flight keys (`show-<id>` / `movie-<id>`),
/// so a screen can show a progress indicator.
@Riverpod(keepAlive: true)
class LiveRepair extends _$LiveRepair {
  final _inFlight = <String>{};
  final _attempted = <String>{};

  @override
  Set<String> build() => const {};

  bool isRepairing(String key) => _inFlight.contains(key);

  /// [force] is what a pull-to-refresh passes: it retries a record already
  /// attempted this session.
  Future<void> repairShow(Show show, {bool force = false}) async {
    final key = 'show-${show.tvdbId}';
    if (_inFlight.contains(key)) return;
    if (!force && _attempted.contains(key)) return;
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
      // Saved even when TheTVDB knows nothing: enrichShowFromTvdb still
      // stamps metaRefreshedAt, which is what stops the retry loop.
      await repo.saveShow(merged);
    } catch (_) {
      // Retried next session.
    } finally {
      _end(key);
    }
  }

  /// Looks the movie up by TMDB id when known, falling back to the IMDB id
  /// carried by the TV Time export.
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
        d = await tmdb.movieDetails(movie.tmdbId!);
      } else if (movie.imdbId != null) {
        d = await tmdb.movieByImdb(movie.imdbId!);
      }

      if (d == null) {
        await repo.saveMovie(movie.copyWith(metaRefreshedAt: DateTime.now()));
        return;
      }

      // Keep the stored overview unless it is missing or in the wrong
      // language.
      final wantEnglish =
          ref.read(localeControllerProvider) == AppLocale.english;
      final keepOverview =
          (movie.overview?.isNotEmpty ?? false) &&
          looksEnglish(movie.overview) != !wantEnglish;
      await repo.saveMovie(
        movie.copyWith(
          tmdbId: movie.tmdbId ?? d.id,
          poster: movie.poster ?? d.poster,
          backdrop: movie.backdrop ?? d.backdrop,
          overview: keepOverview
              ? movie.overview
              : (d.overview ?? movie.overview),
          runtime: (movie.runtime != null && movie.runtime! > 0)
              ? movie.runtime
              : d.runtime,
          metaRefreshedAt: DateTime.now(),
        ),
      );
    } catch (_) {
      // Retried next session.
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
