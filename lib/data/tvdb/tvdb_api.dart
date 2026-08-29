import 'package:dio/dio.dart';

import '../api_dio.dart';

/// TheTVDB v4 client (https://thetvdb.github.io/v4-api/), the primary source of
/// show metadata: it lists new seasons before the other providers do, and
/// serves translated episode titles and overviews.
///
/// Show ids in this app are already TheTVDB ids (that is what the TV Time
/// export contains), so no id resolution is needed.
class TvdbApi {
  /// Reaches TheTVDB directly, logging in with [apiKey].
  TvdbApi.direct(String apiKey, {this.language = 'eng', Dio? dio})
    : _dio = (dio ?? apiDio(_base))..interceptors.add(_Login(apiKey));

  /// Reaches the proxy, which authenticates upstream on its behalf.
  TvdbApi.proxied(this._dio, {this.language = 'eng'});

  static const _base = 'https://api4.thetvdb.com/v4';

  /// TheTVDB serves a translated record with its untranslated fields left
  /// empty rather than falling back on its own, so English fills the gaps.
  static const _fallback = 'eng';

  final Dio _dio;

  /// ISO 639-2/T code used for translation endpoints.
  final String language;

  static const _artworks = 'https://artworks.thetvdb.com';

  static String? _img(String? p) {
    if (p == null || p.isEmpty) return null;
    return p.startsWith('http') ? p : '$_artworks$p';
  }

  static String? _nonEmpty(String? s) => (s == null || s.isEmpty) ? null : s;

  /// Show metadata plus every episode. Null when TheTVDB does not know the id.
  ///
  /// The three endpoints depend on nothing but the id, so they fly together:
  /// behind the proxy every leg costs two hops instead of one.
  Future<TvdbSeries?> series(int tvdbId) async {
    final (extended, translation, episodes) = await (
      _extended(tvdbId),
      _translation(tvdbId, language),
      _episodes(tvdbId),
    ).wait;
    if (extended == null) return null;

    final overview =
        translation.overview ??
        (language == _fallback
            ? null
            : (await _translation(tvdbId, _fallback)).overview);

    final status =
        (extended['status'] as Map<String, dynamic>?)?['name'] as String?;
    final network =
        (extended['latestNetwork'] as Map<String, dynamic>?)?['name']
            as String?;

    return TvdbSeries(
      name: translation.name ?? (extended['name'] as String? ?? ''),
      overview: overview,
      poster: _img(extended['image'] as String?),
      status: status,
      network: network,
      episodes: episodes,
    );
  }

  /// Null when TheTVDB does not know the id.
  Future<Map<String, dynamic>?> _extended(int tvdbId) async {
    try {
      final r = await _dio.get<Map<String, dynamic>>(
        '/series/$tvdbId/extended',
      );
      return r.data?['data'] as Map<String, dynamic>? ??
          const <String, dynamic>{};
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Both fields null when no translation exists, so the caller keeps the
  /// original text.
  Future<({String? name, String? overview})> _translation(
    int tvdbId,
    String lang,
  ) async {
    try {
      final r = await _dio.get<Map<String, dynamic>>(
        '/series/$tvdbId/translations/$lang',
      );
      final d = r.data?['data'] as Map<String, dynamic>?;
      return (
        name: _nonEmpty(d?['name'] as String?),
        overview: _nonEmpty(d?['overview'] as String?),
      );
    } catch (_) {
      return (name: null, overview: null);
    }
  }

  /// Specials (season 0) are returned here; the merge step is what drops them
  /// from progress tracking.
  ///
  /// A season nobody has translated yet comes back with blank titles and no
  /// overviews, so the English listing is fetched to fill them in, but only
  /// when something is actually missing.
  Future<List<TvdbEpisode>> _episodes(int tvdbId) async {
    final translated = await _episodePages(tvdbId, language);
    if (language == _fallback) return translated;
    if (!translated.any((e) => e.name.isEmpty || e.overview == null)) {
      return translated;
    }

    final english = await _episodePages(tvdbId, _fallback);
    if (english.isEmpty) return translated;

    final byNumber = {for (final e in english) (e.season, e.number): e};
    final out = [
      for (final e in translated)
        e.filledFrom(byNumber.remove((e.season, e.number))),
    ];
    // A season the translated listing does not carry at all still belongs in
    // the show.
    out.addAll(byNumber.values);
    return out;
  }

  Future<List<TvdbEpisode>> _episodePages(int tvdbId, String lang) async {
    final out = <TvdbEpisode>[];
    var page = 0;
    while (true) {
      Response<Map<String, dynamic>> r;
      try {
        r = await _dio.get<Map<String, dynamic>>(
          '/series/$tvdbId/episodes/official/$lang',
          queryParameters: {'page': page},
        );
      } on DioException catch (e) {
        // An id TheTVDB does not know 404s here too; `series` reads that from
        // the extended call and decides what it means.
        if (e.response?.statusCode == 404) return out;
        rethrow;
      }
      final data = r.data?['data'] as Map<String, dynamic>? ?? const {};
      final eps = data['episodes'] as List? ?? const [];
      for (final e in eps.cast<Map<String, dynamic>>()) {
        // This endpoint returns ids and numbers as strings.
        final season = int.tryParse('${e['seasonNumber']}') ?? 0;
        final number = int.tryParse('${e['number']}') ?? 0;
        final aired = e['aired'] as String?;
        out.add(
          TvdbEpisode(
            season: season,
            number: number,
            name: (e['name'] as String?) ?? '',
            overview: _nonEmpty(e['overview'] as String?),
            still: _img(e['image'] as String?),
            // Anchored at noon UTC so the date does not shift a day either way
            // when rendered in the device timezone.
            airDate: (aired == null || aired.isEmpty)
                ? null
                : DateTime.tryParse('${aired}T12:00:00Z'),
          ),
        );
      }
      if ((r.data?['links'] as Map<String, dynamic>?)?['next'] == null) break;
      page++;
    }
    return out;
  }
}

/// `POST /login` returns a token valid for about a month, so one login serves
/// the whole session. Concurrent requests share the in-flight one.
class _Login extends Interceptor {
  _Login(this._apiKey);

  final String _apiKey;
  Future<String?>? _pending;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await (_pending ??= _fetch());
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  Future<String?> _fetch() async {
    try {
      final r = await apiDio(
        TvdbApi._base,
      ).post<Map<String, dynamic>>('/login', data: {'apikey': _apiKey});
      return (r.data?['data'] as Map<String, dynamic>?)?['token'] as String?;
    } catch (_) {
      _pending = null;
      rethrow;
    }
  }
}

class TvdbSeries {
  const TvdbSeries({
    required this.name,
    this.overview,
    this.poster,
    this.status,
    this.network,
    this.episodes = const [],
  });

  final String name;
  final String? overview;
  final String? poster;
  final String? status; // Continuing / Ended / Upcoming
  final String? network;
  final List<TvdbEpisode> episodes;
}

/// Optional fields stay null when absent so the merge never overwrites an
/// existing value with a blank one.
class TvdbEpisode {
  const TvdbEpisode({
    required this.season,
    required this.number,
    required this.name,
    this.overview,
    this.still,
    this.airDate,
  });

  final int season;
  final int number;
  final String name;
  final String? overview;
  final String? still;
  final DateTime? airDate;

  bool get isSpecial => season == 0;

  /// This episode with every empty field taken from [other], the same episode
  /// in another language.
  TvdbEpisode filledFrom(TvdbEpisode? other) => other == null
      ? this
      : TvdbEpisode(
          season: season,
          number: number,
          name: name.isNotEmpty ? name : other.name,
          overview: overview ?? other.overview,
          still: still ?? other.still,
          airDate: airDate ?? other.airDate,
        );
}
