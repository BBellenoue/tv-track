import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'show.freezed.dart';
part 'show.g.dart';

const _englishMarkers = {
  'the', 'and', 'with', 'when', 'who', 'she', 'his', 'her', 'they', //
  'their', 'about', 'which', 'while', 'has', 'have', 'been', 'from',
  'after', 'before', 'that', 'this', 'him', 'are', 'was', 'were',
};

const _frenchMarkers = {
  'les', 'des', 'une', 'pour', 'dans', 'avec', 'qui', 'que', 'sur', //
  'par', 'est', 'sont', 'ses', 'leur', 'plus', 'tout', 'elle', 'lui',
  'mais', 'sans', 'entre', 'aux', 'ils', 'cette', 'son', 'ans',
};

/// Guesses whether stored text is English by counting function words that are
/// frequent in one language and absent from the other. Returns null when
/// neither side wins clearly — callers then leave the text alone instead of
/// re-fetching it on every pass.
///
/// Three hits is enough to decide, which avoids tripping on a lone proper noun.
bool? looksEnglish(String? text) {
  if (text == null || text.length < 20) return null;
  var english = 0, french = 0;
  for (final word in text.toLowerCase().split(RegExp(r"[^a-zà-ÿ']+"))) {
    if (_englishMarkers.contains(word)) english++;
    if (_frenchMarkers.contains(word)) french++;
  }
  if (english >= 3 && english > french) return true;
  if (french >= 3 && french > english) return false;
  return null;
}

/// A "bare" episode has no air date, still or overview at all — a sign it was
/// never enriched, as opposed to a merely upcoming one, which at least has a
/// date. Used to trigger a live repair of the show.
bool _episodeBare(Episode e) =>
    e.airDate == null && e.still == null && (e.overview?.isEmpty ?? true);

@freezed
abstract class Episode with _$Episode {
  const factory Episode({
    /// TheTVDB id for episodes coming from the TV Time export; a negative
    /// `-(season * 1000 + number)` for episodes added later by enrichment,
    /// which keeps them from colliding with real ids.
    required int tvdbId,
    required int number,
    @Default('') String name,
    @Default(false) bool special,
    @Default(false) bool watched,
    DateTime? watchedAt,
    DateTime? airDate,
    String? overview,
    String? still,
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
  bool get isCompleted =>
      episodes.isNotEmpty && watchedCount == episodes.length;
}

/// An episode together with the season it belongs to, for "S02E05" display.
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
    // Metadata filled in by enrichment, not by the import.
    int? tvmazeId,
    int? tmdbId,
    String? poster,
    String? posterLarge,
    String? airStatus,
    String? network,
    String? overview,
    @Default(<String>[]) List<String> providers,
    DateTime? metaRefreshedAt,
  }) = _Show;

  factory Show.fromJson(Map<String, dynamic> json) => _$ShowFromJson(json);

  /// Specials are excluded everywhere progress is counted.
  List<Season> get regularSeasons =>
      seasons.where((s) => !s.isSpecials).sorted((a, b) => a.number - b.number);

  int get totalEpisodes =>
      regularSeasons.fold(0, (sum, s) => sum + s.episodes.length);

  int get watchedEpisodes =>
      regularSeasons.fold(0, (sum, s) => sum + s.watchedCount);

  bool get isStarted => watchedEpisodes > 0;

  bool get isUpToDate => watchedEpisodes == totalEpisodes;

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

  bool get isEnded => airStatus == 'Ended';

  /// True when a refresh could fill something in: no overview, no artwork, no
  /// season structure, or **at least one entirely bare episode** — typically a
  /// season that aired but that no provider had indexed when the record was
  /// last written.
  bool get isIncomplete =>
      (overview?.isEmpty ?? true) ||
      (poster == null && posterLarge == null) ||
      regularSeasons.isEmpty ||
      regularSeasons.any((s) => s.episodes.any(_episodeBare));

  /// True when the stored overview is clearly in the other language, which a
  /// refresh can fix by re-fetching it. Undecidable text counts as a match, so
  /// short overviews are not re-fetched forever.
  bool needsRepair({required bool wantEnglish}) =>
      isIncomplete || looksEnglish(overview) == !wantEnglish;

  DateTime? get nextAirDate {
    final now = DateTime.now();
    return regularSeasons
        .expand((s) => s.episodes)
        .map((e) => e.airDate)
        .whereType<DateTime>()
        .where((d) => d.isAfter(now))
        .minOrNull;
  }

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

  /// Counts unwatched episodes strictly before (season, number), across
  /// seasons — what the "mark everything before this" prompt is based on.
  int unwatchedBefore(int seasonNumber, int episodeNumber) {
    var count = 0;
    for (final season in regularSeasons) {
      for (final episode in season.episodes) {
        final before =
            season.number < seasonNumber ||
            (season.number == seasonNumber && episode.number < episodeNumber);
        if (before && !episode.watched) count++;
      }
    }
    return count;
  }

  /// Marks every regular episode up to and including (season, number).
  Show markWatchedUpTo(int seasonNumber, int episodeNumber) {
    final now = DateTime.now();
    return copyWith(
      seasons: [
        for (final season in seasons)
          if (season.isSpecials)
            season
          else
            season.copyWith(
              episodes: [
                for (final episode in season.episodes)
                  if (!episode.watched &&
                      (season.number < seasonNumber ||
                          (season.number == seasonNumber &&
                              episode.number <= episodeNumber)))
                    episode.copyWith(watched: true, watchedAt: now)
                  else
                    episode,
              ],
            ),
      ],
    );
  }
}
