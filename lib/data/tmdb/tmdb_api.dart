import 'package:dio/dio.dart';

import 'catalog_item.dart';

/// Tri disponible dans le mode Parcourir.
enum CatalogSort {
  popular('Populaires', 'popularity.desc'),
  recent('Récentes', null), // date desc, dépend du type (voir _dateSortKey)
  topRated('Mieux notées', 'vote_average.desc');

  const CatalogSort(this.label, this._fixedKey);
  final String label;
  final String? _fixedKey;

  String sortKey(MediaKind kind) =>
      _fixedKey ??
      (kind.isTv ? 'first_air_date.desc' : 'primary_release_date.desc');
}

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

  /// Détails d'un film (en français) via son ID IMDB (ex: tt29623480).
  /// Retourne null si TMDB ne connaît pas le film.
  Future<TmdbMovie?> movieByImdb(String imdbId) async {
    final found = await _dio.get<Map<String, dynamic>>(
      '/find/$imdbId',
      queryParameters: {
        'external_source': 'imdb_id',
        'api_key': _apiKey,
        'language': 'fr-FR',
      },
    );
    final results = found.data?['movie_results'] as List?;
    if (results == null || results.isEmpty) return null;
    final id = (results.first as Map<String, dynamic>)['id'] as int?;
    if (id == null) return null;

    // /movie/{id} donne le résumé FR complet, le backdrop et la durée.
    final detail = await _dio.get<Map<String, dynamic>>(
      '/movie/$id',
      queryParameters: {'api_key': _apiKey, 'language': 'fr-FR'},
    );
    final d = detail.data ?? {};
    String? img(String key, String size) {
      final p = d[key] as String?;
      return p == null ? null : '$imageBase/$size$p';
    }

    final overview = d['overview'] as String?;
    return TmdbMovie(
      id: id,
      poster: img('poster_path', 'w342'),
      backdrop: img('backdrop_path', 'w780'),
      overview: (overview == null || overview.isEmpty) ? null : overview,
      runtime: d['runtime'] as int?,
    );
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

  /// Résumé d'une série en français (null si TMDB n'en a pas).
  Future<String?> tvOverviewFr(int tmdbTvId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/tv/$tmdbTvId',
      queryParameters: {'api_key': _apiKey, 'language': 'fr-FR'},
    );
    final o = response.data?['overview'] as String?;
    return (o == null || o.isEmpty) ? null : o;
  }

  /// Épisodes d'une saison en français : numéro d'épisode → (titre, résumé).
  /// Les champs vides côté TMDB sont laissés à null (pour retomber sur TVmaze).
  Future<Map<int, ({String? name, String? overview})>> tvSeasonFr(
      int tmdbTvId, int seasonNumber) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/tv/$tmdbTvId/season/$seasonNumber',
      queryParameters: {'api_key': _apiKey, 'language': 'fr-FR'},
    );
    final episodes = response.data?['episodes'] as List? ?? const [];
    final out = <int, ({String? name, String? overview})>{};
    for (final e in episodes.cast<Map<String, dynamic>>()) {
      final number = e['episode_number'] as int?;
      if (number == null) continue;
      String? nn = e['name'] as String?;
      String? oo = e['overview'] as String?;
      out[number] = (
        name: (nn == null || nn.isEmpty) ? null : nn,
        overview: (oo == null || oo.isEmpty) ? null : oo,
      );
    }
    return out;
  }

  // ---- Catalogue unifié (séries + films) pour Découverte v2 ----

  /// Liste des genres d'un type (tv|film), en français.
  Future<List<Genre>> genres(MediaKind kind) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/genre/${kind.path}/list',
      queryParameters: {'api_key': _apiKey, 'language': 'fr-FR'},
    );
    final list = response.data?['genres'] as List? ?? const [];
    return [
      for (final g in list.cast<Map<String, dynamic>>())
        (id: g['id'] as int, name: g['name'] as String),
    ];
  }

  /// /discover : filtrable par genre, triable, paginé. FR.
  Future<List<CatalogItem>> discover(
    MediaKind kind, {
    CatalogSort sort = CatalogSort.popular,
    int? genreId,
    int page = 1,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/discover/${kind.path}',
      queryParameters: {
        'api_key': _apiKey,
        'language': 'fr-FR',
        'watch_region': 'FR',
        'sort_by': sort.sortKey(kind),
        'page': page,
        if (genreId != null) 'with_genres': '$genreId',
        // Évite le bruit : un minimum de votes pour "mieux notées".
        if (sort == CatalogSort.topRated) 'vote_count.gte': 200,
      },
    );
    return _items(response.data, kind);
  }

  /// Tendances de la semaine (tv ou film), FR.
  Future<List<CatalogItem>> trending(MediaKind kind, {int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/trending/${kind.path}/week',
      queryParameters: {'api_key': _apiKey, 'language': 'fr-FR', 'page': page},
    );
    return _items(response.data, kind);
  }

  /// Recherche par titre (tv ou film), FR.
  Future<List<CatalogItem>> search(MediaKind kind, String query,
      {int page = 1}) async {
    if (query.trim().isEmpty) return const [];
    final response = await _dio.get<Map<String, dynamic>>(
      '/search/${kind.path}',
      queryParameters: {
        'api_key': _apiKey,
        'language': 'fr-FR',
        'query': query,
        'page': page,
      },
    );
    return _items(response.data, kind);
  }

  List<CatalogItem> _items(Map<String, dynamic>? data, MediaKind kind) {
    final results = data?['results'] as List? ?? const [];
    return [
      for (final r in results.cast<Map<String, dynamic>>())
        CatalogItem.fromJson(r, kind),
    ];
  }

  /// IMDB id d'un film TMDB (pour le rattacher au suivi).
  Future<String?> movieImdbId(int tmdbMovieId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/movie/$tmdbMovieId/external_ids',
      queryParameters: {'api_key': _apiKey},
    );
    final id = response.data?['imdb_id'] as String?;
    return (id == null || id.isEmpty) ? null : id;
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

class TmdbMovie {
  const TmdbMovie({
    required this.id,
    this.poster,
    this.backdrop,
    this.overview,
    this.runtime,
  });

  final int id;
  final String? poster;
  final String? backdrop;
  final String? overview;
  final int? runtime;
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
