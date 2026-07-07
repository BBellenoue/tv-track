import 'package:dio/dio.dart';

/// Client TheTVDB v4 (https://thetvdb.github.io/v4-api/) — **source principale**
/// des métadonnées de séries : c'est la base la plus à jour (elle référence les
/// nouvelles saisons avant TVmaze/TMDB) et fournit titres/résumés d'épisodes en
/// français, images, dates, statut et chaîne. Les IDs de l'app sont déjà des
/// IDs TheTVDB (issus de l'export TV Time), donc le rattachement est direct.
///
/// Authentification : `POST /login {apikey}` renvoie un jeton (valable ~1 mois)
/// mis en cache pour la session. Les images d'épisodes sont des chemins relatifs
/// préfixés par [_artworks].
class TvdbApi {
  TvdbApi(this._apiKey, [Dio? dio])
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api4.thetvdb.com/v4',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
            ));

  final String _apiKey;
  final Dio _dio;
  String? _token;

  static const _artworks = 'https://artworks.thetvdb.com';

  Future<void> _ensureAuth() async {
    if (_token != null) return;
    final r = await _dio.post<Map<String, dynamic>>(
      '/login',
      data: {'apikey': _apiKey},
    );
    _token = (r.data?['data'] as Map<String, dynamic>?)?['token'] as String?;
  }

  Options get _auth => Options(headers: {'Authorization': 'Bearer $_token'});

  static String? _img(String? p) {
    if (p == null || p.isEmpty) return null;
    return p.startsWith('http') ? p : '$_artworks$p';
  }

  static String? _nonEmpty(String? s) => (s == null || s.isEmpty) ? null : s;

  /// Métadonnées françaises d'une série + tous ses épisodes. Retourne null si
  /// TheTVDB ne connaît pas cet ID.
  Future<TvdbSeries?> series(int tvdbId) async {
    await _ensureAuth();
    Response<Map<String, dynamic>> ext;
    try {
      ext = await _dio.get<Map<String, dynamic>>(
        '/series/$tvdbId/extended',
        options: _auth,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
    final d = ext.data?['data'] as Map<String, dynamic>? ?? const {};

    // Nom + synopsis en français (repli sur l'original si pas de traduction).
    String? frName, frOverview;
    try {
      final t = await _dio.get<Map<String, dynamic>>(
        '/series/$tvdbId/translations/fra',
        options: _auth,
      );
      final td = t.data?['data'] as Map<String, dynamic>?;
      frName = _nonEmpty(td?['name'] as String?);
      frOverview = _nonEmpty(td?['overview'] as String?);
    } catch (_) {
      // Pas de traduction FR : on garde l'original.
    }

    final status = (d['status'] as Map<String, dynamic>?)?['name'] as String?;
    final network = (d['latestNetwork'] as Map<String, dynamic>?)?['name']
        as String?;

    return TvdbSeries(
      name: frName ?? (d['name'] as String? ?? ''),
      overview: frOverview,
      poster: _img(d['image'] as String?),
      status: status,
      network: network,
      episodes: await _episodes(tvdbId),
    );
  }

  /// Épisodes officiels en français (paginés). Les specials (saison 0) sont
  /// inclus ici ; c'est la fusion qui les écarte de la progression.
  Future<List<TvdbEpisode>> _episodes(int tvdbId) async {
    final out = <TvdbEpisode>[];
    var page = 0;
    while (true) {
      final r = await _dio.get<Map<String, dynamic>>(
        '/series/$tvdbId/episodes/official/fra',
        queryParameters: {'page': page},
        options: _auth,
      );
      final data = r.data?['data'] as Map<String, dynamic>? ?? const {};
      final eps = data['episodes'] as List? ?? const [];
      for (final e in eps.cast<Map<String, dynamic>>()) {
        // Cet endpoint renvoie ids/numéros en chaînes.
        final season = int.tryParse('${e['seasonNumber']}') ?? 0;
        final number = int.tryParse('${e['number']}') ?? 0;
        final aired = e['aired'] as String?;
        out.add(TvdbEpisode(
          season: season,
          number: number,
          name: (e['name'] as String?) ?? '',
          overview: _nonEmpty(e['overview'] as String?),
          still: _img(e['image'] as String?),
          // Ancrage midi UTC : évite les décalages de date en affichage local.
          airDate: (aired == null || aired.isEmpty)
              ? null
              : DateTime.tryParse('${aired}T12:00:00Z'),
        ));
      }
      if ((r.data?['links'] as Map<String, dynamic>?)?['next'] == null) break;
      page++;
    }
    return out;
  }
}

/// Métadonnées série issues de TheTVDB (déjà localisées en français).
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

/// Épisode TheTVDB localisé. Chaque champ optionnel est null si absent, pour ne
/// jamais écraser une valeur existante par du vide lors de la fusion.
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
}
