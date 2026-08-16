import 'package:freezed_annotation/freezed_annotation.dart';

import 'show.dart' show looksEnglish;

part 'movie.freezed.dart';
part 'movie.g.dart';

@freezed
abstract class Movie with _$Movie {
  const Movie._();

  const factory Movie({
    required int tvdbId,
    String? imdbId,
    required String title,
    int? year,
    @Default(false) bool watched,
    DateTime? watchedAt,
    @Default(false) bool isFavorite,
    DateTime? addedAt,
    // Metadata filled in by enrichment, not by the import.
    int? tmdbId,
    String? poster,
    String? backdrop,
    String? overview,
    int? runtime,
    DateTime? metaRefreshedAt,
  }) = _Movie;

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);

  /// True when a refresh could fill something in: never matched to TMDB, no
  /// overview, no artwork, or no runtime.
  bool get isIncomplete =>
      tmdbId == null ||
      (overview?.isEmpty ?? true) ||
      poster == null ||
      backdrop == null ||
      (runtime == null || runtime! <= 0);

  /// True when the stored overview is clearly in the other language, which a
  /// refresh can fix by re-fetching it.
  bool needsRepair({required bool wantEnglish}) =>
      isIncomplete || looksEnglish(overview) == !wantEnglish;
}
