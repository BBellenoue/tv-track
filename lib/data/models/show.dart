import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'show.freezed.dart';
part 'show.g.dart';

@freezed
abstract class Episode with _$Episode {
  const factory Episode({
    required int tvdbId,
    required int number,
    @Default('') String name,
    @Default(false) bool special,
    @Default(false) bool watched,
    DateTime? watchedAt,
  }) = _Episode;

  factory Episode.fromJson(Map<String, dynamic> json) =>
      _$EpisodeFromJson(json);
}

@freezed
abstract class Season with _$Season {
  const Season._();

  const factory Season({
    required int number,
    @Default(false) bool isSpecials,
    @Default(<Episode>[]) List<Episode> episodes,
  }) = _Season;

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);

  int get watchedCount => episodes.where((e) => e.watched).length;
  bool get isCompleted => episodes.isNotEmpty && watchedCount == episodes.length;
}

/// Position d'un épisode dans sa série (pour l'affichage "S02E05").
typedef EpisodeRef = ({Season season, Episode episode});

@freezed
abstract class Show with _$Show {
  const Show._();

  const factory Show({
    required int tvdbId,
    required String title,
    @Default(false) bool isFavorite,
    DateTime? addedAt,
    @Default(<Season>[]) List<Season> seasons,
  }) = _Show;

  factory Show.fromJson(Map<String, dynamic> json) => _$ShowFromJson(json);

  /// Saisons hors specials, triées par numéro.
  List<Season> get regularSeasons =>
      seasons.where((s) => !s.isSpecials).sorted((a, b) => a.number - b.number);

  int get totalEpisodes =>
      regularSeasons.fold(0, (sum, s) => sum + s.episodes.length);

  int get watchedEpisodes =>
      regularSeasons.fold(0, (sum, s) => sum + s.watchedCount);

  bool get isStarted => watchedEpisodes > 0;

  bool get isUpToDate => watchedEpisodes == totalEpisodes;

  /// Prochain épisode non vu (hors specials), dans l'ordre saison/épisode.
  EpisodeRef? get nextEpisode {
    for (final season in regularSeasons) {
      final episode = season.episodes
          .sorted((a, b) => a.number - b.number)
          .firstWhereOrNull((e) => !e.watched);
      if (episode != null) return (season: season, episode: episode);
    }
    return null;
  }

  DateTime? get lastWatchedAt => seasons
      .expand((s) => s.episodes)
      .map((e) => e.watchedAt)
      .whereType<DateTime>()
      .maxOrNull;

  /// Retourne une copie avec l'épisode [episodeTvdbId] marqué vu/non vu.
  Show withEpisodeWatched(int episodeTvdbId, bool watched) {
    return copyWith(
      seasons: [
        for (final season in seasons)
          season.copyWith(
            episodes: [
              for (final episode in season.episodes)
                if (episode.tvdbId == episodeTvdbId)
                  episode.copyWith(
                    watched: watched,
                    watchedAt: watched ? DateTime.now() : null,
                  )
                else
                  episode,
            ],
          ),
      ],
    );
  }

  /// Retourne une copie avec toute la saison [seasonNumber] marquée vue/non vue.
  Show withSeasonWatched(int seasonNumber, bool watched) {
    return copyWith(
      seasons: [
        for (final season in seasons)
          if (season.number == seasonNumber && !season.isSpecials)
            season.copyWith(
              episodes: [
                for (final episode in season.episodes)
                  if (episode.watched == watched)
                    episode
                  else
                    episode.copyWith(
                      watched: watched,
                      watchedAt: watched ? DateTime.now() : null,
                    ),
              ],
            )
          else
            season,
      ],
    );
  }
}
