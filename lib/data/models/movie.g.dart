// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Movie _$MovieFromJson(Map<String, dynamic> json) => _Movie(
  tvdbId: (json['tvdbId'] as num).toInt(),
  imdbId: json['imdbId'] as String?,
  title: json['title'] as String,
  year: (json['year'] as num?)?.toInt(),
  watched: json['watched'] as bool? ?? false,
  watchedAt: json['watchedAt'] == null
      ? null
      : DateTime.parse(json['watchedAt'] as String),
  isFavorite: json['isFavorite'] as bool? ?? false,
  addedAt: json['addedAt'] == null
      ? null
      : DateTime.parse(json['addedAt'] as String),
  tmdbId: (json['tmdbId'] as num?)?.toInt(),
  poster: json['poster'] as String?,
  backdrop: json['backdrop'] as String?,
  overview: json['overview'] as String?,
  runtime: (json['runtime'] as num?)?.toInt(),
  metaRefreshedAt: json['metaRefreshedAt'] == null
      ? null
      : DateTime.parse(json['metaRefreshedAt'] as String),
);

Map<String, dynamic> _$MovieToJson(_Movie instance) => <String, dynamic>{
  'tvdbId': instance.tvdbId,
  'imdbId': instance.imdbId,
  'title': instance.title,
  'year': instance.year,
  'watched': instance.watched,
  'watchedAt': instance.watchedAt?.toIso8601String(),
  'isFavorite': instance.isFavorite,
  'addedAt': instance.addedAt?.toIso8601String(),
  'tmdbId': instance.tmdbId,
  'poster': instance.poster,
  'backdrop': instance.backdrop,
  'overview': instance.overview,
  'runtime': instance.runtime,
  'metaRefreshedAt': instance.metaRefreshedAt?.toIso8601String(),
};
