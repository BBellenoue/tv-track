import 'package:freezed_annotation/freezed_annotation.dart';

part 'movie.freezed.dart';
part 'movie.g.dart';

@freezed
abstract class Movie with _$Movie {
  const factory Movie({
    required int tvdbId,
    String? imdbId,
    required String title,
    int? year,
    @Default(false) bool watched,
    DateTime? watchedAt,
    @Default(false) bool isFavorite,
    DateTime? addedAt,
    // Métadonnées TMDB (enrichies hors app).
    String? poster,
    DateTime? metaRefreshedAt,
  }) = _Movie;

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);
}
