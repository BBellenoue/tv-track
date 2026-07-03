import 'dart:convert';

import '../models/movie.dart';
import '../models/show.dart';

/// Parsing des fichiers d'export TV Time (tvtime-series-*.json et
/// tvtime-movies-*.json) vers les modèles du domaine.
///
/// Les dates de l'export sont soit ISO 8601 ("2025-06-09T18:01:55Z"), soit
/// "2026-03-29 14:28:52" — les deux sont acceptées par [DateTime.tryParse].
class TvTimeParser {
  static List<Show> parseShows(String jsonString) {
    final list = jsonDecode(jsonString) as List<dynamic>;
    return [
      for (final raw in list.cast<Map<String, dynamic>>())
        Show(
          tvdbId: (raw['id'] as Map<String, dynamic>)['tvdb'] as int,
          title: raw['title'] as String,
          isFavorite: raw['is_favorite'] as bool? ?? false,
          addedAt: _date(raw['created_at']),
          seasons: [
            for (final season
                in (raw['seasons'] as List? ?? []).cast<Map<String, dynamic>>())
              Season(
                number: season['number'] as int,
                isSpecials: season['is_specials'] as bool? ?? false,
                episodes: [
                  for (final episode in (season['episodes'] as List? ?? [])
                      .cast<Map<String, dynamic>>())
                    Episode(
                      tvdbId:
                          (episode['id'] as Map<String, dynamic>)['tvdb'] as int,
                      number: episode['number'] as int,
                      name: episode['name'] as String? ?? '',
                      special: episode['special'] as bool? ?? false,
                      watched: episode['is_watched'] as bool? ?? false,
                      watchedAt: _date(episode['watched_at']),
                    ),
                ],
              ),
          ],
        ),
    ];
  }

  static List<Movie> parseMovies(String jsonString) {
    final list = jsonDecode(jsonString) as List<dynamic>;
    return [
      for (final raw in list.cast<Map<String, dynamic>>())
        Movie(
          tvdbId: (raw['id'] as Map<String, dynamic>)['tvdb'] as int,
          imdbId: (raw['id'] as Map<String, dynamic>)['imdb'] as String?,
          title: raw['title'] as String,
          year: raw['year'] as int?,
          watched: raw['is_watched'] as bool? ?? false,
          watchedAt: _date(raw['watched_at']),
          isFavorite: raw['is_favorite'] as bool? ?? false,
          addedAt: _date(raw['created_at']),
        ),
    ];
  }

  /// Parse un lot de fichiers d'export sans connaître leur type à l'avance :
  /// un fichier dont les entrées ont une clé `seasons` est un export séries,
  /// sinon un export films.
  static ({List<Show> shows, List<Movie> movies}) parseFiles(
      Iterable<String> jsonStrings) {
    final shows = <Show>[];
    final movies = <Movie>[];
    for (final jsonString in jsonStrings) {
      final list = jsonDecode(jsonString) as List<dynamic>;
      if (list.isEmpty) continue;
      if ((list.first as Map<String, dynamic>).containsKey('seasons')) {
        shows.addAll(parseShows(jsonString));
      } else {
        movies.addAll(parseMovies(jsonString));
      }
    }
    return (shows: shows, movies: movies);
  }

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
}
