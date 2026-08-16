import 'package:dio/dio.dart';

import '../api_dio.dart';
import 'catalog_item.dart';

/// Sort orders offered in Browse mode.
enum CatalogSort {
  popular('popularity.desc'),
  // Date descending, but the field name differs between shows and movies.
  recent(null),
  topRated('vote_average.desc');

  const CatalogSort(this._fixedKey);
  final String? _fixedKey;

  String sortKey(MediaKind kind) =>
      _fixedKey ??
      (kind.isTv ? 'first_air_date.desc' : 'primary_release_date.desc');
}

/// TMDB client (https://developer.themoviedb.org), used for the Discover
/// catalog, global search, streaming providers, movie details and as a fallback
/// for seasons TheTVDB has not published yet.
class TmdbApi {
  /// Reaches TMDB directly, signing every request with [apiKey].
  TmdbApi.direct(
    String apiKey, {
    this.language = 'en-US',
    this.region = 'US',
    Dio? dio,
  }) : _dio = (dio ?? apiDio(_base))..interceptors.add(_ApiKey(apiKey));

  /// Reaches the proxy, which holds the key and appends it upstream.
  TmdbApi.proxied(this._dio, {this.language = 'en-US', this.region = 'US'});

  static const _base = 'https://api.themoviedb.org/3';

  final Dio _dio;

  /// TMDB `language` parameter, e.g. `fr-FR`.
  final String language;

  /// Country code scoping streaming availability and release dates.
  final String region;

  static const imageBase = 'https://image.tmdb.org/t/p';

  Map<String, dynamic> _params([Map<String, dynamic> extra = const {}]) => {
    'language': language,
    ...extra,
  };

  /// Movie details from an IMDB id (e.g. `tt29623480`), which is what the TV
  /// Time export stores. Null when TMDB does not know the film.
  Future<TmdbMovie?> movieByImdb(String imdbId) async {
    final found = await _dio.get<Map<String, dynamic>>(
      '/find/$imdbId',
      queryParameters: _params({'external_source': 'imdb_id'}),
    );
    final results = found.data?['movie_results'] as List?;
    if (results == null || results.isEmpty) return null;
    final id = (results.first as Map<String, dynamic>)['id'] as int?;
    if (id == null) return null;

    // /find returns a trimmed payload; /movie/{id} has the full overview,
    // the backdrop and the runtime.
    return movieDetails(id);
  }

  /// Movie details by TMDB id. Null when TMDB does not answer.
  Future<TmdbMovie?> movieDetails(int tmdbMovieId) async {
    final detail = await _dio.get<Map<String, dynamic>>(
      '/movie/$tmdbMovieId',
      queryParameters: _params(),
    );
    final d = detail.data;
    if (d == null) return null;
    String? img(String key, String size) {
      final p = d[key] as String?;
      return p == null ? null : '$imageBase/$size$p';
    }

    final overview = d['overview'] as String?;
    return TmdbMovie(
      id: tmdbMovieId,
      poster: img('poster_path', 'w342'),
      backdrop: img('backdrop_path', 'w780'),
      overview: (overview == null || overview.isEmpty) ? null : overview,
      runtime: d['runtime'] as int?,
    );
  }

  Future<int?> tvIdByTvdb(int tvdbId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/find/$tvdbId',
      queryParameters: {'external_source': 'tvdb_id'},
    );
    final results = response.data?['tv_results'] as List?;
    if (results == null || results.isEmpty) return null;
    return (results.first as Map<String, dynamic>)['id'] as int?;
  }

  /// Subscription services streaming a show in [region] (JustWatch data),
  /// as display names such as "Netflix" or "Max".
  Future<List<String>> tvProviders(int tmdbTvId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/tv/$tmdbTvId/watch/providers',
    );
    final country =
        (response.data?['results'] as Map<String, dynamic>?)?[region]
            as Map<String, dynamic>?;
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

  /// TMDB lists the same service several times (ad-supported tier, resale
  /// through an Amazon or Apple channel…). Collapse those into one readable
  /// name so the detail screen does not show "Max" three times.
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

  Future<String?> tvOverview(int tmdbTvId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/tv/$tmdbTvId',
      queryParameters: _params(),
    );
    final o = response.data?['overview'] as String?;
    return (o == null || o.isEmpty) ? null : o;
  }

  /// Localized overview and poster for a show. Used to move a record left in
  /// another language over to the current one.
  Future<({String? overview, String? poster, String? posterLarge})> tvDetails(
    int tmdbTvId,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/tv/$tmdbTvId',
      queryParameters: _params(),
    );
    final d = response.data ?? const {};
    final o = d['overview'] as String?;
    final p = d['poster_path'] as String?;
    return (
      overview: (o == null || o.isEmpty) ? null : o,
      poster: p == null ? null : '$imageBase/w342$p',
      posterLarge: p == null ? null : '$imageBase/original$p',
    );
  }

  /// Episodes of one season, keyed by episode number. Also serves as the
  /// fallback when TheTVDB has not published a season yet (a streaming drop can
  /// land there first), which is where air dates and stills come from.
  Future<Map<int, TmdbEpisode>> tvSeason(int tmdbTvId, int seasonNumber) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/tv/$tmdbTvId/season/$seasonNumber',
      queryParameters: _params(),
    );
    final episodes = response.data?['episodes'] as List? ?? const [];
    final out = <int, TmdbEpisode>{};
    for (final e in episodes.cast<Map<String, dynamic>>()) {
      final number = e['episode_number'] as int?;
      if (number == null) continue;
      final nn = e['name'] as String?;
      final oo = e['overview'] as String?;
      final air = e['air_date'] as String?;
      final still = e['still_path'] as String?;
      out[number] = TmdbEpisode(
        name: (nn == null || nn.isEmpty) ? null : nn,
        overview: (oo == null || oo.isEmpty) ? null : oo,
        airDate: (air == null || air.isEmpty) ? null : DateTime.tryParse(air),
        still: still == null ? null : '$imageBase/w300$still',
      );
    }
    return out;
  }

  // ---- Unified catalog (shows + movies) behind Discover ----

  Future<List<Genre>> genres(MediaKind kind) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/genre/${kind.path}/list',
      queryParameters: _params(),
    );
    final list = response.data?['genres'] as List? ?? const [];
    return [
      for (final g in list.cast<Map<String, dynamic>>())
        (id: g['id'] as int, name: g['name'] as String),
    ];
  }

  Future<List<CatalogItem>> discover(
    MediaKind kind, {
    CatalogSort sort = CatalogSort.popular,
    int? genreId,
    int page = 1,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/discover/${kind.path}',
      queryParameters: _params({
        'watch_region': region,
        'sort_by': sort.sortKey(kind),
        'page': page,
        if (genreId != null) 'with_genres': '$genreId',
        // Without a vote floor, "top rated" surfaces obscure titles with a
        // single 10/10 rating.
        if (sort == CatalogSort.topRated) 'vote_count.gte': 200,
      }),
    );
    return _items(response.data, kind);
  }

  /// Genres and credits for one title, fetched when a detail screen opens
  /// rather than stored: `append_to_response` folds the credits into the
  /// details call, so it costs nothing over fetching the details alone.
  Future<TmdbExtras?> extras(MediaKind kind, int tmdbId) async {
    // `credits` on a series only bills whoever is attached to the show record,
    // often a single lead; `aggregate_credits` gathers the cast across every
    // season.
    final creditsKey = kind.isTv ? 'aggregate_credits' : 'credits';
    final response = await _dio.get<Map<String, dynamic>>(
      '/${kind.path}/$tmdbId',
      queryParameters: _params({'append_to_response': creditsKey}),
    );
    final d = response.data;
    if (d == null) return null;
    final credits = d[creditsKey] as Map<String, dynamic>? ?? const {};

    List<String> names(List? raw) => [
      for (final e in (raw ?? const []).cast<Map<String, dynamic>>())
        if ((e['name'] as String?)?.isNotEmpty ?? false) e['name'] as String,
    ];

    return TmdbExtras(
      genres: names(d['genres'] as List?),
      // A series has no director, only per-episode ones; TMDB names the
      // people who created it instead.
      authors: kind.isTv
          ? names(d['created_by'] as List?)
          : [
              for (final c
                  in (credits['crew'] as List? ?? const [])
                      .cast<Map<String, dynamic>>())
                if (c['job'] == 'Director' &&
                    ((c['name'] as String?)?.isNotEmpty ?? false))
                  c['name'] as String,
            ],
      cast: names(credits['cast'] as List?).take(6).toList(),
    );
  }

  /// TMDB's "viewers of this also watched" list. Collaborative rather than
  /// editorial, which is what makes it usable as a personal signal.
  Future<List<CatalogItem>> recommendations(
    MediaKind kind,
    int tmdbId, {
    int page = 1,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/${kind.path}/$tmdbId/recommendations',
      queryParameters: _params({'page': page}),
    );
    return _items(response.data, kind);
  }

  Future<List<CatalogItem>> trending(MediaKind kind, {int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/trending/${kind.path}/week',
      queryParameters: _params({'page': page}),
    );
    return _items(response.data, kind);
  }

  Future<List<CatalogItem>> search(
    MediaKind kind,
    String query, {
    int page = 1,
  }) async {
    if (query.trim().isEmpty) return const [];
    final response = await _dio.get<Map<String, dynamic>>(
      '/search/${kind.path}',
      queryParameters: _params({'query': query, 'page': page}),
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

  Future<String?> movieImdbId(int tmdbMovieId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/movie/$tmdbMovieId/external_ids',
    );
    final id = response.data?['imdb_id'] as String?;
    return (id == null || id.isEmpty) ? null : id;
  }

  Future<List<TmdbTv>> popularTv({int page = 1}) =>
      _tvList('/tv/popular', page);

  Future<List<TmdbTv>> trendingTv({int page = 1}) =>
      _tvList('/trending/tv/week', page);

  Future<List<TmdbTv>> onTheAirTv({int page = 1}) =>
      _tvList('/tv/on_the_air', page);

  Future<List<TmdbTv>> _tvList(String path, int page) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: _params({'region': region, 'page': page}),
    );
    final results = response.data?['results'] as List? ?? const [];
    return [
      for (final r in results.cast<Map<String, dynamic>>())
        // Posterless entries look broken in the swipe deck.
        if (r['poster_path'] != null) TmdbTv.fromJson(r),
    ];
  }

  /// TheTVDB id behind a TMDB show, needed to add a discovered show to the
  /// library since tracking is keyed on TheTVDB ids.
  Future<int?> tvdbIdByTmdb(int tmdbTvId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/tv/$tmdbTvId/external_ids',
    );
    return response.data?['tvdb_id'] as int?;
  }
}

class _ApiKey extends Interceptor {
  _ApiKey(this._apiKey);

  final String _apiKey;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters = {...options.queryParameters, 'api_key': _apiKey};
    handler.next(options);
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

/// Every field is null when TMDB has nothing, so merging never overwrites a
/// TheTVDB value with a blank.
class TmdbEpisode {
  const TmdbEpisode({this.name, this.overview, this.airDate, this.still});

  final String? name;
  final String? overview;
  final DateTime? airDate;
  final String? still;
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

  int? get year => firstAirDate != null && firstAirDate!.length >= 4
      ? int.tryParse(firstAirDate!.substring(0, 4))
      : null;
}

/// Genres and credits shown on a detail screen. [authors] holds the director
/// for a movie and the creators for a series.
class TmdbExtras {
  const TmdbExtras({
    this.genres = const [],
    this.authors = const [],
    this.cast = const [],
  });

  final List<String> genres;
  final List<String> authors;
  final List<String> cast;

  bool get isEmpty => genres.isEmpty && authors.isEmpty && cast.isEmpty;
}
