// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Episode _$EpisodeFromJson(Map<String, dynamic> json) => _Episode(
  tvdbId: (json['tvdbId'] as num).toInt(),
  number: (json['number'] as num).toInt(),
  name: json['name'] as String? ?? '',
  special: json['special'] as bool? ?? false,
  watched: json['watched'] as bool? ?? false,
  watchedAt: json['watchedAt'] == null
      ? null
      : DateTime.parse(json['watchedAt'] as String),
  airDate: json['airDate'] == null
      ? null
      : DateTime.parse(json['airDate'] as String),
  overview: json['overview'] as String?,
  still: json['still'] as String?,
);

Map<String, dynamic> _$EpisodeToJson(_Episode instance) => <String, dynamic>{
  'tvdbId': instance.tvdbId,
  'number': instance.number,
  'name': instance.name,
  'special': instance.special,
  'watched': instance.watched,
  'watchedAt': instance.watchedAt?.toIso8601String(),
  'airDate': instance.airDate?.toIso8601String(),
  'overview': instance.overview,
  'still': instance.still,
};

_Season _$SeasonFromJson(Map<String, dynamic> json) => _Season(
  number: (json['number'] as num).toInt(),
  isSpecials: json['isSpecials'] as bool? ?? false,
  episodes:
      (json['episodes'] as List<dynamic>?)
          ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Episode>[],
);

Map<String, dynamic> _$SeasonToJson(_Season instance) => <String, dynamic>{
  'number': instance.number,
  'isSpecials': instance.isSpecials,
  'episodes': instance.episodes.map((e) => e.toJson()).toList(),
};

_Show _$ShowFromJson(Map<String, dynamic> json) => _Show(
  tvdbId: (json['tvdbId'] as num).toInt(),
  title: json['title'] as String,
  isFavorite: json['isFavorite'] as bool? ?? false,
  addedAt: json['addedAt'] == null
      ? null
      : DateTime.parse(json['addedAt'] as String),
  seasons:
      (json['seasons'] as List<dynamic>?)
          ?.map((e) => Season.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Season>[],
  tvmazeId: (json['tvmazeId'] as num?)?.toInt(),
  tmdbId: (json['tmdbId'] as num?)?.toInt(),
  poster: json['poster'] as String?,
  posterLarge: json['posterLarge'] as String?,
  airStatus: json['airStatus'] as String?,
  network: json['network'] as String?,
  overview: json['overview'] as String?,
  providers:
      (json['providers'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  metaRefreshedAt: json['metaRefreshedAt'] == null
      ? null
      : DateTime.parse(json['metaRefreshedAt'] as String),
);

Map<String, dynamic> _$ShowToJson(_Show instance) => <String, dynamic>{
  'tvdbId': instance.tvdbId,
  'title': instance.title,
  'isFavorite': instance.isFavorite,
  'addedAt': instance.addedAt?.toIso8601String(),
  'seasons': instance.seasons.map((e) => e.toJson()).toList(),
  'tvmazeId': instance.tvmazeId,
  'tmdbId': instance.tmdbId,
  'poster': instance.poster,
  'posterLarge': instance.posterLarge,
  'airStatus': instance.airStatus,
  'network': instance.network,
  'overview': instance.overview,
  'providers': instance.providers,
  'metaRefreshedAt': instance.metaRefreshedAt?.toIso8601String(),
};
