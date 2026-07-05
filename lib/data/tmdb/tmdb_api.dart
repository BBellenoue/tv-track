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

  /// ID TMDB d'une série via son ID TVDB.
  Future<int?> tvIdByTvdb(int tvdbId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/find/$tvdbId',
      queryParameters: {'external_source': 'tvdb_id', 'api_key': _apiKey},
    );
    final results = response.data?['tv_results'] as List?;
    if (results == null || results.isEmpty) return null;
    return (results.first as Map<String, dynamic>)['id'] as int?;
  }

  /// Plateformes de streaming (abonnement) où voir une série dans un pays.
  /// Données JustWatch via TMDB. Retourne les noms (ex: "Netflix", "Max").
  Future<List<String>> tvProviders(int tmdbTvId, {String region = 'FR'}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/tv/$tmdbTvId/watch/providers',
      queryParameters: {'api_key': _apiKey},
    );
    final country = (response.data?['results']
        as Map<String, dynamic>?)?[region] as Map<String, dynamic>?;
    final flatrate = country?['flatrate'] as List?;
    if (flatrate == null) return const [];
    final seen = <String>{};
    final names = <String>[];
    for (final p in flatrate.cast<Map<String, dynamic>>()) {
      final raw = p['provider_name'] as String?;
      if (raw == null) continue;
      final name = _normalizeProvider(raw);
      if (seen.add(name)) names.add(name);
    }
    return names;
  }

  /// Regroupe les déclinaisons TMDB d'un même service (offre avec pub,
  /// revente via Amazon/Apple Channel…) sous un nom unique et lisible.
  static String _normalizeProvider(String name) {
    var n = name;
    for (final suffix in const [
      ' Standard with Ads',
      ' with Ads',
      ' Amazon Channel',
      ' Apple TV Channel',
      ' Channel',
      ' Basic with Ads',
    ]) {
      if (n.endsWith(suffix)) n = n.substring(0, n.length - suffix.length);
    }
    return n.trim();
  }

  /// Séries populaires (page 1..n), localisées en français, région FR.
  Future<List<TmdbTv>> popularTv({int page = 1}) =>
      _tvList('/tv/popular', page);

  /// Séries tendances de la semaine.
  Future<List<TmdbTv>> trendingTv({int page = 1}) =>
      _tvList('/trending/tv/week', page);

  /// Séries actuellement en diffusion.
  Future<List<TmdbTv>> onTheAirTv({int page = 1}) =>
      _tvList('/tv/on_the_air', page);

  Future<List<TmdbTv>> _tvList(String path, int page) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: {
        'api_key': _apiKey,
        'language': 'fr-FR',
        'region': 'FR',
        'page': page,
      },
    );
    final results = response.data?['results'] as List? ?? const [];
    return [
      for (final r in results.cast<Map<String, dynamic>>())
        if (r['poster_path'] != null) TmdbTv.fromJson(r),
    ];
  }

  /// ID TVDB d'une série TMDB (pour rattacher une envie au suivi via TVmaze).
  Future<int?> tvdbIdByTmdb(int tmdbTvId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/tv/$tmdbTvId/external_ids',
      queryParameters: {'api_key': _apiKey},
    );
    return response.data?['tvdb_id'] as int?;
  }
}

class TmdbTv {
  const TmdbTv({
    required this.id,
    required this.name,
    this.overview,
    this.posterPath,
    this.firstAirDate,
    this.voteAverage,
  });

  factory TmdbTv.fromJson(Map<String, dynamic> json) => TmdbTv(
        id: json['id'] as int,
        name: (json['name'] ?? json['original_name']) as String? ?? '',
        overview: (json['overview'] as String?)?.isEmpty ?? true
            ? null
            : json['overview'] as String,
        posterPath: json['poster_path'] as String?,
        firstAirDate: json['first_air_date'] as String?,
        voteAverage: (json['vote_average'] as num?)?.toDouble(),
      );

  final int id;
  final String name;
  final String? overview;
  final String? posterPath;
  final String? firstAirDate; // "2019-05-06"
  final double? voteAverage;

  String? get posterUrl =>
      posterPath == null ? null : '${TmdbApi.imageBase}/w500$posterPath';

  int? get year =>
      firstAirDate != null && firstAirDate!.length >= 4
          ? int.tryParse(firstAirDate!.substring(0, 4))
          : null;
}
