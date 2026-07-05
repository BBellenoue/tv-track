import 'package:dio/dio.dart';

/// Client TVmaze (https://www.tvmaze.com/api) — gratuit, sans clé.
/// Rate limit : ~20 requêtes / 10 s → throttler les accès en masse.
class TvmazeApi {
  TvmazeApi([Dio? dio])
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api.tvmaze.com',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  final Dio _dio;

  /// Résout une série par son ID TVDB. Retourne null si inconnue de TVmaze.
  Future<TvmazeShow?> lookupByTvdb(int tvdbId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/lookup/shows',
        queryParameters: {'thetvdb': tvdbId},
      );
      return TvmazeShow.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<List<TvmazeEpisode>> episodes(int tvmazeId) async {
    final response = await _dio.get<List<dynamic>>(
      '/shows/$tvmazeId/episodes',
      queryParameters: {'specials': 1},
    );
    return [
      for (final e in response.data!.cast<Map<String, dynamic>>())
        TvmazeEpisode.fromJson(e),
    ];
  }
}

class TvmazeShow {
  const TvmazeShow({
    required this.id,
    required this.name,
    this.status,
    this.network,
    this.imageMedium,
    this.imageOriginal,
    this.summary,
  });

  factory TvmazeShow.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>?;
    final network = (json['network'] ?? json['webChannel']) as Map<String, dynamic>?;
    return TvmazeShow(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      status: json['status'] as String?,
      network: network?['name'] as String?,
      imageMedium: image?['medium'] as String?,
      imageOriginal: image?['original'] as String?,
      summary: stripHtml(json['summary'] as String?),
    );
  }

  final int id;
  final String name;
  final String? status; // Running / Ended / To Be Determined / In Development
  final String? network;
  final String? imageMedium;
  final String? imageOriginal;
  final String? summary;
}

/// Retire les balises HTML des résumés TVmaze et décode les entités
/// courantes. Retourne null pour une entrée vide.
String? stripHtml(String? html) {
  if (html == null) return null;
  final text = html
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&agrave;', 'à')
      .replaceAll('&eacute;', 'é')
      .replaceAll('&nbsp;', ' ')
      .trim();
  return text.isEmpty ? null : text;
}

class TvmazeEpisode {
  const TvmazeEpisode({
    required this.season,
    required this.number,
    required this.name,
    this.type,
    this.airstamp,
    this.summary,
    this.image,
  });

  factory TvmazeEpisode.fromJson(Map<String, dynamic> json) => TvmazeEpisode(
        season: json['season'] as int? ?? 0,
        // number est null pour certains specials non numérotés.
        number: json['number'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        type: json['type'] as String?,
        airstamp: json['airstamp'] != null
            ? DateTime.tryParse(json['airstamp'] as String)
            : null,
        summary: stripHtml(json['summary'] as String?),
        image: (json['image'] as Map<String, dynamic>?)?['medium'] as String?,
      );

  final int season;
  final int number;
  final String name;
  final String? type; // regular / significant_special / insignificant_special
  final DateTime? airstamp;
  final String? summary;
  final String? image;

  bool get isSpecial => type != null && type != 'regular';
}
