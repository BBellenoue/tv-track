import 'package:dio/dio.dart';

/// Client TMDB minimal (https://developer.themoviedb.org) — gratuit pour un
/// usage personnel, nécessite une clé API (v3).
class TmdbApi {
  TmdbApi(this._apiKey, [Dio? dio])
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api.themoviedb.org/3',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  final String _apiKey;
  final Dio _dio;

  static const imageBase = 'https://image.tmdb.org/t/p';

  /// Poster d'un film via son ID IMDB (ex: tt29623480), taille w342.
  Future<String?> moviePosterByImdb(String imdbId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/find/$imdbId',
      queryParameters: {'external_source': 'imdb_id', 'api_key': _apiKey},
    );
    final results = response.data?['movie_results'] as List?;
    if (results == null || results.isEmpty) return null;
    final path = (results.first as Map<String, dynamic>)['poster_path'];
    return path == null ? null : '$imageBase/w342$path';
  }
}
