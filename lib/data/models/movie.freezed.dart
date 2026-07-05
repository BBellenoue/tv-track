// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Movie {

 int get tvdbId; String? get imdbId; String get title; int? get year; bool get watched; DateTime? get watchedAt; bool get isFavorite; DateTime? get addedAt; String? get poster; DateTime? get metaRefreshedAt;
/// Create a copy of Movie
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovieCopyWith<Movie> get copyWith => _$MovieCopyWithImpl<Movie>(this as Movie, _$identity);

  /// Serializes this Movie to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Movie&&(identical(other.tvdbId, tvdbId) || other.tvdbId == tvdbId)&&(identical(other.imdbId, imdbId) || other.imdbId == imdbId)&&(identical(other.title, title) || other.title == title)&&(identical(other.year, year) || other.year == year)&&(identical(other.watched, watched) || other.watched == watched)&&(identical(other.watchedAt, watchedAt) || other.watchedAt == watchedAt)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.poster, poster) || other.poster == poster)&&(identical(other.metaRefreshedAt, metaRefreshedAt) || other.metaRefreshedAt == metaRefreshedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tvdbId,imdbId,title,year,watched,watchedAt,isFavorite,addedAt,poster,metaRefreshedAt);

@override
String toString() {
  return 'Movie(tvdbId: $tvdbId, imdbId: $imdbId, title: $title, year: $year, watched: $watched, watchedAt: $watchedAt, isFavorite: $isFavorite, addedAt: $addedAt, poster: $poster, metaRefreshedAt: $metaRefreshedAt)';
}


}

/// @nodoc
abstract mixin class $MovieCopyWith<$Res>  {
  factory $MovieCopyWith(Movie value, $Res Function(Movie) _then) = _$MovieCopyWithImpl;
@useResult
$Res call({
 int tvdbId, String? imdbId, String title, int? year, bool watched, DateTime? watchedAt, bool isFavorite, DateTime? addedAt, String? poster, DateTime? metaRefreshedAt
});




}
/// @nodoc
class _$MovieCopyWithImpl<$Res>
    implements $MovieCopyWith<$Res> {
  _$MovieCopyWithImpl(this._self, this._then);

  final Movie _self;
  final $Res Function(Movie) _then;

/// Create a copy of Movie
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tvdbId = null,Object? imdbId = freezed,Object? title = null,Object? year = freezed,Object? watched = null,Object? watchedAt = freezed,Object? isFavorite = null,Object? addedAt = freezed,Object? poster = freezed,Object? metaRefreshedAt = freezed,}) {
  return _then(_self.copyWith(
tvdbId: null == tvdbId ? _self.tvdbId : tvdbId // ignore: cast_nullable_to_non_nullable
as int,imdbId: freezed == imdbId ? _self.imdbId : imdbId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,watched: null == watched ? _self.watched : watched // ignore: cast_nullable_to_non_nullable
as bool,watchedAt: freezed == watchedAt ? _self.watchedAt : watchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,addedAt: freezed == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,poster: freezed == poster ? _self.poster : poster // ignore: cast_nullable_to_non_nullable
as String?,metaRefreshedAt: freezed == metaRefreshedAt ? _self.metaRefreshedAt : metaRefreshedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Movie].
extension MoviePatterns on Movie {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Movie value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Movie() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Movie value)  $default,){
final _that = this;
switch (_that) {
case _Movie():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Movie value)?  $default,){
final _that = this;
switch (_that) {
case _Movie() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int tvdbId,  String? imdbId,  String title,  int? year,  bool watched,  DateTime? watchedAt,  bool isFavorite,  DateTime? addedAt,  String? poster,  DateTime? metaRefreshedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Movie() when $default != null:
return $default(_that.tvdbId,_that.imdbId,_that.title,_that.year,_that.watched,_that.watchedAt,_that.isFavorite,_that.addedAt,_that.poster,_that.metaRefreshedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int tvdbId,  String? imdbId,  String title,  int? year,  bool watched,  DateTime? watchedAt,  bool isFavorite,  DateTime? addedAt,  String? poster,  DateTime? metaRefreshedAt)  $default,) {final _that = this;
switch (_that) {
case _Movie():
return $default(_that.tvdbId,_that.imdbId,_that.title,_that.year,_that.watched,_that.watchedAt,_that.isFavorite,_that.addedAt,_that.poster,_that.metaRefreshedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int tvdbId,  String? imdbId,  String title,  int? year,  bool watched,  DateTime? watchedAt,  bool isFavorite,  DateTime? addedAt,  String? poster,  DateTime? metaRefreshedAt)?  $default,) {final _that = this;
switch (_that) {
case _Movie() when $default != null:
return $default(_that.tvdbId,_that.imdbId,_that.title,_that.year,_that.watched,_that.watchedAt,_that.isFavorite,_that.addedAt,_that.poster,_that.metaRefreshedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Movie implements Movie {
  const _Movie({required this.tvdbId, this.imdbId, required this.title, this.year, this.watched = false, this.watchedAt, this.isFavorite = false, this.addedAt, this.poster, this.metaRefreshedAt});
  factory _Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);

@override final  int tvdbId;
@override final  String? imdbId;
@override final  String title;
@override final  int? year;
@override@JsonKey() final  bool watched;
@override final  DateTime? watchedAt;
@override@JsonKey() final  bool isFavorite;
@override final  DateTime? addedAt;
@override final  String? poster;
@override final  DateTime? metaRefreshedAt;

/// Create a copy of Movie
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovieCopyWith<_Movie> get copyWith => __$MovieCopyWithImpl<_Movie>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MovieToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Movie&&(identical(other.tvdbId, tvdbId) || other.tvdbId == tvdbId)&&(identical(other.imdbId, imdbId) || other.imdbId == imdbId)&&(identical(other.title, title) || other.title == title)&&(identical(other.year, year) || other.year == year)&&(identical(other.watched, watched) || other.watched == watched)&&(identical(other.watchedAt, watchedAt) || other.watchedAt == watchedAt)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.poster, poster) || other.poster == poster)&&(identical(other.metaRefreshedAt, metaRefreshedAt) || other.metaRefreshedAt == metaRefreshedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tvdbId,imdbId,title,year,watched,watchedAt,isFavorite,addedAt,poster,metaRefreshedAt);

@override
String toString() {
  return 'Movie(tvdbId: $tvdbId, imdbId: $imdbId, title: $title, year: $year, watched: $watched, watchedAt: $watchedAt, isFavorite: $isFavorite, addedAt: $addedAt, poster: $poster, metaRefreshedAt: $metaRefreshedAt)';
}


}

/// @nodoc
abstract mixin class _$MovieCopyWith<$Res> implements $MovieCopyWith<$Res> {
  factory _$MovieCopyWith(_Movie value, $Res Function(_Movie) _then) = __$MovieCopyWithImpl;
@override @useResult
$Res call({
 int tvdbId, String? imdbId, String title, int? year, bool watched, DateTime? watchedAt, bool isFavorite, DateTime? addedAt, String? poster, DateTime? metaRefreshedAt
});




}
/// @nodoc
class __$MovieCopyWithImpl<$Res>
    implements _$MovieCopyWith<$Res> {
  __$MovieCopyWithImpl(this._self, this._then);

  final _Movie _self;
  final $Res Function(_Movie) _then;

/// Create a copy of Movie
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tvdbId = null,Object? imdbId = freezed,Object? title = null,Object? year = freezed,Object? watched = null,Object? watchedAt = freezed,Object? isFavorite = null,Object? addedAt = freezed,Object? poster = freezed,Object? metaRefreshedAt = freezed,}) {
  return _then(_Movie(
tvdbId: null == tvdbId ? _self.tvdbId : tvdbId // ignore: cast_nullable_to_non_nullable
as int,imdbId: freezed == imdbId ? _self.imdbId : imdbId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,watched: null == watched ? _self.watched : watched // ignore: cast_nullable_to_non_nullable
as bool,watchedAt: freezed == watchedAt ? _self.watchedAt : watchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,addedAt: freezed == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,poster: freezed == poster ? _self.poster : poster // ignore: cast_nullable_to_non_nullable
as String?,metaRefreshedAt: freezed == metaRefreshedAt ? _self.metaRefreshedAt : metaRefreshedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
