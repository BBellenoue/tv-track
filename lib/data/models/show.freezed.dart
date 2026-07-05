// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'show.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Episode {

/// ID externe : TVDB pour les épisodes issus de l'export TV Time,
/// négatif (-(saison*1000+numéro)) pour ceux ajoutés depuis TVmaze.
 int get tvdbId; int get number; String get name; bool get special; bool get watched; DateTime? get watchedAt; DateTime? get airDate;
/// Create a copy of Episode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EpisodeCopyWith<Episode> get copyWith => _$EpisodeCopyWithImpl<Episode>(this as Episode, _$identity);

  /// Serializes this Episode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Episode&&(identical(other.tvdbId, tvdbId) || other.tvdbId == tvdbId)&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&(identical(other.special, special) || other.special == special)&&(identical(other.watched, watched) || other.watched == watched)&&(identical(other.watchedAt, watchedAt) || other.watchedAt == watchedAt)&&(identical(other.airDate, airDate) || other.airDate == airDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tvdbId,number,name,special,watched,watchedAt,airDate);

@override
String toString() {
  return 'Episode(tvdbId: $tvdbId, number: $number, name: $name, special: $special, watched: $watched, watchedAt: $watchedAt, airDate: $airDate)';
}


}

/// @nodoc
abstract mixin class $EpisodeCopyWith<$Res>  {
  factory $EpisodeCopyWith(Episode value, $Res Function(Episode) _then) = _$EpisodeCopyWithImpl;
@useResult
$Res call({
 int tvdbId, int number, String name, bool special, bool watched, DateTime? watchedAt, DateTime? airDate
});




}
/// @nodoc
class _$EpisodeCopyWithImpl<$Res>
    implements $EpisodeCopyWith<$Res> {
  _$EpisodeCopyWithImpl(this._self, this._then);

  final Episode _self;
  final $Res Function(Episode) _then;

/// Create a copy of Episode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tvdbId = null,Object? number = null,Object? name = null,Object? special = null,Object? watched = null,Object? watchedAt = freezed,Object? airDate = freezed,}) {
  return _then(_self.copyWith(
tvdbId: null == tvdbId ? _self.tvdbId : tvdbId // ignore: cast_nullable_to_non_nullable
as int,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,special: null == special ? _self.special : special // ignore: cast_nullable_to_non_nullable
as bool,watched: null == watched ? _self.watched : watched // ignore: cast_nullable_to_non_nullable
as bool,watchedAt: freezed == watchedAt ? _self.watchedAt : watchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,airDate: freezed == airDate ? _self.airDate : airDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Episode].
extension EpisodePatterns on Episode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Episode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Episode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Episode value)  $default,){
final _that = this;
switch (_that) {
case _Episode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Episode value)?  $default,){
final _that = this;
switch (_that) {
case _Episode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int tvdbId,  int number,  String name,  bool special,  bool watched,  DateTime? watchedAt,  DateTime? airDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Episode() when $default != null:
return $default(_that.tvdbId,_that.number,_that.name,_that.special,_that.watched,_that.watchedAt,_that.airDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int tvdbId,  int number,  String name,  bool special,  bool watched,  DateTime? watchedAt,  DateTime? airDate)  $default,) {final _that = this;
switch (_that) {
case _Episode():
return $default(_that.tvdbId,_that.number,_that.name,_that.special,_that.watched,_that.watchedAt,_that.airDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int tvdbId,  int number,  String name,  bool special,  bool watched,  DateTime? watchedAt,  DateTime? airDate)?  $default,) {final _that = this;
switch (_that) {
case _Episode() when $default != null:
return $default(_that.tvdbId,_that.number,_that.name,_that.special,_that.watched,_that.watchedAt,_that.airDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Episode implements Episode {
  const _Episode({required this.tvdbId, required this.number, this.name = '', this.special = false, this.watched = false, this.watchedAt, this.airDate});
  factory _Episode.fromJson(Map<String, dynamic> json) => _$EpisodeFromJson(json);

/// ID externe : TVDB pour les épisodes issus de l'export TV Time,
/// négatif (-(saison*1000+numéro)) pour ceux ajoutés depuis TVmaze.
@override final  int tvdbId;
@override final  int number;
@override@JsonKey() final  String name;
@override@JsonKey() final  bool special;
@override@JsonKey() final  bool watched;
@override final  DateTime? watchedAt;
@override final  DateTime? airDate;

/// Create a copy of Episode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EpisodeCopyWith<_Episode> get copyWith => __$EpisodeCopyWithImpl<_Episode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EpisodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Episode&&(identical(other.tvdbId, tvdbId) || other.tvdbId == tvdbId)&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&(identical(other.special, special) || other.special == special)&&(identical(other.watched, watched) || other.watched == watched)&&(identical(other.watchedAt, watchedAt) || other.watchedAt == watchedAt)&&(identical(other.airDate, airDate) || other.airDate == airDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tvdbId,number,name,special,watched,watchedAt,airDate);

@override
String toString() {
  return 'Episode(tvdbId: $tvdbId, number: $number, name: $name, special: $special, watched: $watched, watchedAt: $watchedAt, airDate: $airDate)';
}


}

/// @nodoc
abstract mixin class _$EpisodeCopyWith<$Res> implements $EpisodeCopyWith<$Res> {
  factory _$EpisodeCopyWith(_Episode value, $Res Function(_Episode) _then) = __$EpisodeCopyWithImpl;
@override @useResult
$Res call({
 int tvdbId, int number, String name, bool special, bool watched, DateTime? watchedAt, DateTime? airDate
});




}
/// @nodoc
class __$EpisodeCopyWithImpl<$Res>
    implements _$EpisodeCopyWith<$Res> {
  __$EpisodeCopyWithImpl(this._self, this._then);

  final _Episode _self;
  final $Res Function(_Episode) _then;

/// Create a copy of Episode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tvdbId = null,Object? number = null,Object? name = null,Object? special = null,Object? watched = null,Object? watchedAt = freezed,Object? airDate = freezed,}) {
  return _then(_Episode(
tvdbId: null == tvdbId ? _self.tvdbId : tvdbId // ignore: cast_nullable_to_non_nullable
as int,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,special: null == special ? _self.special : special // ignore: cast_nullable_to_non_nullable
as bool,watched: null == watched ? _self.watched : watched // ignore: cast_nullable_to_non_nullable
as bool,watchedAt: freezed == watchedAt ? _self.watchedAt : watchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,airDate: freezed == airDate ? _self.airDate : airDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Season {

 int get number; bool get isSpecials; List<Episode> get episodes;
/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeasonCopyWith<Season> get copyWith => _$SeasonCopyWithImpl<Season>(this as Season, _$identity);

  /// Serializes this Season to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Season&&(identical(other.number, number) || other.number == number)&&(identical(other.isSpecials, isSpecials) || other.isSpecials == isSpecials)&&const DeepCollectionEquality().equals(other.episodes, episodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,isSpecials,const DeepCollectionEquality().hash(episodes));

@override
String toString() {
  return 'Season(number: $number, isSpecials: $isSpecials, episodes: $episodes)';
}


}

/// @nodoc
abstract mixin class $SeasonCopyWith<$Res>  {
  factory $SeasonCopyWith(Season value, $Res Function(Season) _then) = _$SeasonCopyWithImpl;
@useResult
$Res call({
 int number, bool isSpecials, List<Episode> episodes
});




}
/// @nodoc
class _$SeasonCopyWithImpl<$Res>
    implements $SeasonCopyWith<$Res> {
  _$SeasonCopyWithImpl(this._self, this._then);

  final Season _self;
  final $Res Function(Season) _then;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? isSpecials = null,Object? episodes = null,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,isSpecials: null == isSpecials ? _self.isSpecials : isSpecials // ignore: cast_nullable_to_non_nullable
as bool,episodes: null == episodes ? _self.episodes : episodes // ignore: cast_nullable_to_non_nullable
as List<Episode>,
  ));
}

}


/// Adds pattern-matching-related methods to [Season].
extension SeasonPatterns on Season {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Season value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Season() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Season value)  $default,){
final _that = this;
switch (_that) {
case _Season():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Season value)?  $default,){
final _that = this;
switch (_that) {
case _Season() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int number,  bool isSpecials,  List<Episode> episodes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that.number,_that.isSpecials,_that.episodes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int number,  bool isSpecials,  List<Episode> episodes)  $default,) {final _that = this;
switch (_that) {
case _Season():
return $default(_that.number,_that.isSpecials,_that.episodes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int number,  bool isSpecials,  List<Episode> episodes)?  $default,) {final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that.number,_that.isSpecials,_that.episodes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Season extends Season {
  const _Season({required this.number, this.isSpecials = false, final  List<Episode> episodes = const <Episode>[]}): _episodes = episodes,super._();
  factory _Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);

@override final  int number;
@override@JsonKey() final  bool isSpecials;
 final  List<Episode> _episodes;
@override@JsonKey() List<Episode> get episodes {
  if (_episodes is EqualUnmodifiableListView) return _episodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_episodes);
}


/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeasonCopyWith<_Season> get copyWith => __$SeasonCopyWithImpl<_Season>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeasonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Season&&(identical(other.number, number) || other.number == number)&&(identical(other.isSpecials, isSpecials) || other.isSpecials == isSpecials)&&const DeepCollectionEquality().equals(other._episodes, _episodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,isSpecials,const DeepCollectionEquality().hash(_episodes));

@override
String toString() {
  return 'Season(number: $number, isSpecials: $isSpecials, episodes: $episodes)';
}


}

/// @nodoc
abstract mixin class _$SeasonCopyWith<$Res> implements $SeasonCopyWith<$Res> {
  factory _$SeasonCopyWith(_Season value, $Res Function(_Season) _then) = __$SeasonCopyWithImpl;
@override @useResult
$Res call({
 int number, bool isSpecials, List<Episode> episodes
});




}
/// @nodoc
class __$SeasonCopyWithImpl<$Res>
    implements _$SeasonCopyWith<$Res> {
  __$SeasonCopyWithImpl(this._self, this._then);

  final _Season _self;
  final $Res Function(_Season) _then;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? isSpecials = null,Object? episodes = null,}) {
  return _then(_Season(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,isSpecials: null == isSpecials ? _self.isSpecials : isSpecials // ignore: cast_nullable_to_non_nullable
as bool,episodes: null == episodes ? _self._episodes : episodes // ignore: cast_nullable_to_non_nullable
as List<Episode>,
  ));
}


}


/// @nodoc
mixin _$Show {

 int get tvdbId; String get title; bool get isFavorite; DateTime? get addedAt; List<Season> get seasons; int? get tvmazeId; String? get poster; String? get posterLarge; String? get airStatus; String? get network; DateTime? get metaRefreshedAt;
/// Create a copy of Show
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShowCopyWith<Show> get copyWith => _$ShowCopyWithImpl<Show>(this as Show, _$identity);

  /// Serializes this Show to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Show&&(identical(other.tvdbId, tvdbId) || other.tvdbId == tvdbId)&&(identical(other.title, title) || other.title == title)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&const DeepCollectionEquality().equals(other.seasons, seasons)&&(identical(other.tvmazeId, tvmazeId) || other.tvmazeId == tvmazeId)&&(identical(other.poster, poster) || other.poster == poster)&&(identical(other.posterLarge, posterLarge) || other.posterLarge == posterLarge)&&(identical(other.airStatus, airStatus) || other.airStatus == airStatus)&&(identical(other.network, network) || other.network == network)&&(identical(other.metaRefreshedAt, metaRefreshedAt) || other.metaRefreshedAt == metaRefreshedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tvdbId,title,isFavorite,addedAt,const DeepCollectionEquality().hash(seasons),tvmazeId,poster,posterLarge,airStatus,network,metaRefreshedAt);

@override
String toString() {
  return 'Show(tvdbId: $tvdbId, title: $title, isFavorite: $isFavorite, addedAt: $addedAt, seasons: $seasons, tvmazeId: $tvmazeId, poster: $poster, posterLarge: $posterLarge, airStatus: $airStatus, network: $network, metaRefreshedAt: $metaRefreshedAt)';
}


}

/// @nodoc
abstract mixin class $ShowCopyWith<$Res>  {
  factory $ShowCopyWith(Show value, $Res Function(Show) _then) = _$ShowCopyWithImpl;
@useResult
$Res call({
 int tvdbId, String title, bool isFavorite, DateTime? addedAt, List<Season> seasons, int? tvmazeId, String? poster, String? posterLarge, String? airStatus, String? network, DateTime? metaRefreshedAt
});




}
/// @nodoc
class _$ShowCopyWithImpl<$Res>
    implements $ShowCopyWith<$Res> {
  _$ShowCopyWithImpl(this._self, this._then);

  final Show _self;
  final $Res Function(Show) _then;

/// Create a copy of Show
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tvdbId = null,Object? title = null,Object? isFavorite = null,Object? addedAt = freezed,Object? seasons = null,Object? tvmazeId = freezed,Object? poster = freezed,Object? posterLarge = freezed,Object? airStatus = freezed,Object? network = freezed,Object? metaRefreshedAt = freezed,}) {
  return _then(_self.copyWith(
tvdbId: null == tvdbId ? _self.tvdbId : tvdbId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,addedAt: freezed == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,seasons: null == seasons ? _self.seasons : seasons // ignore: cast_nullable_to_non_nullable
as List<Season>,tvmazeId: freezed == tvmazeId ? _self.tvmazeId : tvmazeId // ignore: cast_nullable_to_non_nullable
as int?,poster: freezed == poster ? _self.poster : poster // ignore: cast_nullable_to_non_nullable
as String?,posterLarge: freezed == posterLarge ? _self.posterLarge : posterLarge // ignore: cast_nullable_to_non_nullable
as String?,airStatus: freezed == airStatus ? _self.airStatus : airStatus // ignore: cast_nullable_to_non_nullable
as String?,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String?,metaRefreshedAt: freezed == metaRefreshedAt ? _self.metaRefreshedAt : metaRefreshedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Show].
extension ShowPatterns on Show {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Show value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Show() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Show value)  $default,){
final _that = this;
switch (_that) {
case _Show():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Show value)?  $default,){
final _that = this;
switch (_that) {
case _Show() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int tvdbId,  String title,  bool isFavorite,  DateTime? addedAt,  List<Season> seasons,  int? tvmazeId,  String? poster,  String? posterLarge,  String? airStatus,  String? network,  DateTime? metaRefreshedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Show() when $default != null:
return $default(_that.tvdbId,_that.title,_that.isFavorite,_that.addedAt,_that.seasons,_that.tvmazeId,_that.poster,_that.posterLarge,_that.airStatus,_that.network,_that.metaRefreshedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int tvdbId,  String title,  bool isFavorite,  DateTime? addedAt,  List<Season> seasons,  int? tvmazeId,  String? poster,  String? posterLarge,  String? airStatus,  String? network,  DateTime? metaRefreshedAt)  $default,) {final _that = this;
switch (_that) {
case _Show():
return $default(_that.tvdbId,_that.title,_that.isFavorite,_that.addedAt,_that.seasons,_that.tvmazeId,_that.poster,_that.posterLarge,_that.airStatus,_that.network,_that.metaRefreshedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int tvdbId,  String title,  bool isFavorite,  DateTime? addedAt,  List<Season> seasons,  int? tvmazeId,  String? poster,  String? posterLarge,  String? airStatus,  String? network,  DateTime? metaRefreshedAt)?  $default,) {final _that = this;
switch (_that) {
case _Show() when $default != null:
return $default(_that.tvdbId,_that.title,_that.isFavorite,_that.addedAt,_that.seasons,_that.tvmazeId,_that.poster,_that.posterLarge,_that.airStatus,_that.network,_that.metaRefreshedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Show extends Show {
  const _Show({required this.tvdbId, required this.title, this.isFavorite = false, this.addedAt, final  List<Season> seasons = const <Season>[], this.tvmazeId, this.poster, this.posterLarge, this.airStatus, this.network, this.metaRefreshedAt}): _seasons = seasons,super._();
  factory _Show.fromJson(Map<String, dynamic> json) => _$ShowFromJson(json);

@override final  int tvdbId;
@override final  String title;
@override@JsonKey() final  bool isFavorite;
@override final  DateTime? addedAt;
 final  List<Season> _seasons;
@override@JsonKey() List<Season> get seasons {
  if (_seasons is EqualUnmodifiableListView) return _seasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_seasons);
}

@override final  int? tvmazeId;
@override final  String? poster;
@override final  String? posterLarge;
@override final  String? airStatus;
@override final  String? network;
@override final  DateTime? metaRefreshedAt;

/// Create a copy of Show
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShowCopyWith<_Show> get copyWith => __$ShowCopyWithImpl<_Show>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Show&&(identical(other.tvdbId, tvdbId) || other.tvdbId == tvdbId)&&(identical(other.title, title) || other.title == title)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&const DeepCollectionEquality().equals(other._seasons, _seasons)&&(identical(other.tvmazeId, tvmazeId) || other.tvmazeId == tvmazeId)&&(identical(other.poster, poster) || other.poster == poster)&&(identical(other.posterLarge, posterLarge) || other.posterLarge == posterLarge)&&(identical(other.airStatus, airStatus) || other.airStatus == airStatus)&&(identical(other.network, network) || other.network == network)&&(identical(other.metaRefreshedAt, metaRefreshedAt) || other.metaRefreshedAt == metaRefreshedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tvdbId,title,isFavorite,addedAt,const DeepCollectionEquality().hash(_seasons),tvmazeId,poster,posterLarge,airStatus,network,metaRefreshedAt);

@override
String toString() {
  return 'Show(tvdbId: $tvdbId, title: $title, isFavorite: $isFavorite, addedAt: $addedAt, seasons: $seasons, tvmazeId: $tvmazeId, poster: $poster, posterLarge: $posterLarge, airStatus: $airStatus, network: $network, metaRefreshedAt: $metaRefreshedAt)';
}


}

/// @nodoc
abstract mixin class _$ShowCopyWith<$Res> implements $ShowCopyWith<$Res> {
  factory _$ShowCopyWith(_Show value, $Res Function(_Show) _then) = __$ShowCopyWithImpl;
@override @useResult
$Res call({
 int tvdbId, String title, bool isFavorite, DateTime? addedAt, List<Season> seasons, int? tvmazeId, String? poster, String? posterLarge, String? airStatus, String? network, DateTime? metaRefreshedAt
});




}
/// @nodoc
class __$ShowCopyWithImpl<$Res>
    implements _$ShowCopyWith<$Res> {
  __$ShowCopyWithImpl(this._self, this._then);

  final _Show _self;
  final $Res Function(_Show) _then;

/// Create a copy of Show
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tvdbId = null,Object? title = null,Object? isFavorite = null,Object? addedAt = freezed,Object? seasons = null,Object? tvmazeId = freezed,Object? poster = freezed,Object? posterLarge = freezed,Object? airStatus = freezed,Object? network = freezed,Object? metaRefreshedAt = freezed,}) {
  return _then(_Show(
tvdbId: null == tvdbId ? _self.tvdbId : tvdbId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,addedAt: freezed == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,seasons: null == seasons ? _self._seasons : seasons // ignore: cast_nullable_to_non_nullable
as List<Season>,tvmazeId: freezed == tvmazeId ? _self.tvmazeId : tvmazeId // ignore: cast_nullable_to_non_nullable
as int?,poster: freezed == poster ? _self.poster : poster // ignore: cast_nullable_to_non_nullable
as String?,posterLarge: freezed == posterLarge ? _self.posterLarge : posterLarge // ignore: cast_nullable_to_non_nullable
as String?,airStatus: freezed == airStatus ? _self.airStatus : airStatus // ignore: cast_nullable_to_non_nullable
as String?,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String?,metaRefreshedAt: freezed == metaRefreshedAt ? _self.metaRefreshedAt : metaRefreshedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
