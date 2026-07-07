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
    // Métadonnées TMDB (enrichies hors app), en français.
    int? tmdbId,
    String? poster,
    String? backdrop,
    String? overview,
    int? runtime,
    DateTime? metaRefreshedAt,
  }) = _Movie;

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);

  /// Vrai si la fiche a du contenu manquant qu'un rafraîchissement live pourrait
  /// combler : jamais rattaché à TMDB, résumé absent ou resté en anglais, ni
  /// affiche, ni image de fond, ou durée inconnue. Déclenche la réparation à
  /// l'ouverture de la fiche (voir [LiveRepair]).
  bool get isIncomplete =>
      tmdbId == null ||
      (overview?.isEmpty ?? true) ||
      looksEnglish(overview) ||
      poster == null ||
      backdrop == null ||
      (runtime == null || runtime! <= 0);
}
