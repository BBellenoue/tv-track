/// Type de contenu découvrable.
enum MediaKind {
  tv,
  movie;

  bool get isTv => this == MediaKind.tv;
  String get path => this == MediaKind.tv ? 'tv' : 'movie';
}

/// Élément de catalogue TMDB (série OU film), unifié pour l'UI de découverte
/// (deck, rails, grille, recherche). Ne porte que ce qu'il faut afficher +
/// de quoi le rattacher au suivi (tmdbId).
class CatalogItem {
  const CatalogItem({
    required this.tmdbId,
    required this.kind,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.date, // première diffusion (tv) ou sortie (film), "YYYY-MM-DD"
    this.voteAverage,
  });

  factory CatalogItem.fromJson(Map<String, dynamic> json, MediaKind kind) {
    final overview = json['overview'] as String?;
    return CatalogItem(
      tmdbId: json['id'] as int,
      kind: kind,
      title: (kind.isTv
              ? (json['name'] ?? json['original_name'])
              : (json['title'] ?? json['original_title'])) as String? ??
          '',
      overview: (overview == null || overview.isEmpty) ? null : overview,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      date: (kind.isTv ? json['first_air_date'] : json['release_date'])
          as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
    );
  }

  final int tmdbId;
  final MediaKind kind;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? date;
  final double? voteAverage;

  static const _imageBase = 'https://image.tmdb.org/t/p';

  String? get posterUrl =>
      posterPath == null ? null : '$_imageBase/w500$posterPath';

  String? get posterUrlSmall =>
      posterPath == null ? null : '$_imageBase/w342$posterPath';

  String? get backdropUrl =>
      backdropPath == null ? null : '$_imageBase/w780$backdropPath';

  int? get year =>
      (date != null && date!.length >= 4) ? int.tryParse(date!.substring(0, 4)) : null;
}

/// Genre TMDB.
typedef Genre = ({int id, String name});
