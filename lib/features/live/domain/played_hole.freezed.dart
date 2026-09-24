// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'played_hole.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayedHoleGeo {

 String get id; String get name; int get par;@JsonKey(name: 'start_lat') double? get startLat;@JsonKey(name: 'start_lng') double? get startLng;
/// Create a copy of PlayedHoleGeo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayedHoleGeoCopyWith<PlayedHoleGeo> get copyWith => _$PlayedHoleGeoCopyWithImpl<PlayedHoleGeo>(this as PlayedHoleGeo, _$identity);

  /// Serializes this PlayedHoleGeo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlayedHoleGeo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayedHoleGeo&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.par, _this.par) || other.par == _this.par)&&(identical(other.startLat, _this.startLat) || other.startLat == _this.startLat)&&(identical(other.startLng, _this.startLng) || other.startLng == _this.startLng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlayedHoleGeo;
  return Object.hash(runtimeType,_this.id,_this.name,_this.par,_this.startLat,_this.startLng);
}

@override
String toString() {
  final _this = this as PlayedHoleGeo;
  return 'PlayedHoleGeo(id: ${_this.id}, name: ${_this.name}, par: ${_this.par}, startLat: ${_this.startLat}, startLng: ${_this.startLng})';
}


}

/// @nodoc
abstract mixin class $PlayedHoleGeoCopyWith<$Res>  {
  factory $PlayedHoleGeoCopyWith(PlayedHoleGeo value, $Res Function(PlayedHoleGeo) _then) = _$PlayedHoleGeoCopyWithImpl;
@useResult
$Res call({
 String id, String name, int par,@JsonKey(name: 'start_lat') double? startLat,@JsonKey(name: 'start_lng') double? startLng
});




}
/// @nodoc
class _$PlayedHoleGeoCopyWithImpl<$Res>
    implements $PlayedHoleGeoCopyWith<$Res> {
  _$PlayedHoleGeoCopyWithImpl(this._self, this._then);

  final PlayedHoleGeo _self;
  final $Res Function(PlayedHoleGeo) _then;

/// Create a copy of PlayedHoleGeo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? par = null,Object? startLat = freezed,Object? startLng = freezed,}) {
  return _then(PlayedHoleGeo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,par: null == par ? _self.par : par // ignore: cast_nullable_to_non_nullable
as int,startLat: freezed == startLat ? _self.startLat : startLat // ignore: cast_nullable_to_non_nullable
as double?,startLng: freezed == startLng ? _self.startLng : startLng // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayedHoleGeo].
extension PlayedHoleGeoPatterns on PlayedHoleGeo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayedHoleGeo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayedHoleGeo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayedHoleGeo value)  $default,){
final _that = this;
switch (_that) {
case _PlayedHoleGeo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayedHoleGeo value)?  $default,){
final _that = this;
switch (_that) {
case _PlayedHoleGeo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int par, @JsonKey(name: 'start_lat')  double? startLat, @JsonKey(name: 'start_lng')  double? startLng)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayedHoleGeo() when $default != null:
return $default(_that.id,_that.name,_that.par,_that.startLat,_that.startLng);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int par, @JsonKey(name: 'start_lat')  double? startLat, @JsonKey(name: 'start_lng')  double? startLng)  $default,) {final _that = this;
switch (_that) {
case _PlayedHoleGeo():
return $default(_that.id,_that.name,_that.par,_that.startLat,_that.startLng);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int par, @JsonKey(name: 'start_lat')  double? startLat, @JsonKey(name: 'start_lng')  double? startLng)?  $default,) {final _that = this;
switch (_that) {
case _PlayedHoleGeo() when $default != null:
return $default(_that.id,_that.name,_that.par,_that.startLat,_that.startLng);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayedHoleGeo implements PlayedHoleGeo {
  const _PlayedHoleGeo({required this.id, required this.name, required this.par, @JsonKey(name: 'start_lat') this.startLat, @JsonKey(name: 'start_lng') this.startLng});
  factory _PlayedHoleGeo.fromJson(Map<String, dynamic> json) => _$PlayedHoleGeoFromJson(json);

@override final  String id;
@override final  String name;
@override final  int par;
@override@JsonKey(name: 'start_lat') final  double? startLat;
@override@JsonKey(name: 'start_lng') final  double? startLng;

/// Create a copy of PlayedHoleGeo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayedHoleGeoCopyWith<_PlayedHoleGeo> get copyWith => __$PlayedHoleGeoCopyWithImpl<_PlayedHoleGeo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayedHoleGeoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayedHoleGeo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.par, par) || other.par == par)&&(identical(other.startLat, startLat) || other.startLat == startLat)&&(identical(other.startLng, startLng) || other.startLng == startLng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,par,startLat,startLng);
}

@override
String toString() {
    return 'PlayedHoleGeo(id: $id, name: $name, par: $par, startLat: $startLat, startLng: $startLng)';
}


}

/// @nodoc
abstract mixin class _$PlayedHoleGeoCopyWith<$Res> implements $PlayedHoleGeoCopyWith<$Res> {
  factory _$PlayedHoleGeoCopyWith(_PlayedHoleGeo value, $Res Function(_PlayedHoleGeo) _then) = __$PlayedHoleGeoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int par,@JsonKey(name: 'start_lat') double? startLat,@JsonKey(name: 'start_lng') double? startLng
});




}
/// @nodoc
class __$PlayedHoleGeoCopyWithImpl<$Res>
    implements _$PlayedHoleGeoCopyWith<$Res> {
  __$PlayedHoleGeoCopyWithImpl(this._self, this._then);

  final _PlayedHoleGeo _self;
  final $Res Function(_PlayedHoleGeo) _then;

/// Create a copy of PlayedHoleGeo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? par = null,Object? startLat = freezed,Object? startLng = freezed,}) {
  return _then(_PlayedHoleGeo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,par: null == par ? _self.par : par // ignore: cast_nullable_to_non_nullable
as int,startLat: freezed == startLat ? _self.startLat : startLat // ignore: cast_nullable_to_non_nullable
as double?,startLng: freezed == startLng ? _self.startLng : startLng // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$HoleScore {

@JsonKey(name: 'team_id') String get teamId; int get value;@JsonKey(name: 'updated_by') String? get updatedBy;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of HoleScore
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HoleScoreCopyWith<HoleScore> get copyWith => _$HoleScoreCopyWithImpl<HoleScore>(this as HoleScore, _$identity);

  /// Serializes this HoleScore to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HoleScore;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HoleScore&&(identical(other.teamId, _this.teamId) || other.teamId == _this.teamId)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.updatedBy, _this.updatedBy) || other.updatedBy == _this.updatedBy)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HoleScore;
  return Object.hash(runtimeType,_this.teamId,_this.value,_this.updatedBy,_this.updatedAt);
}

@override
String toString() {
  final _this = this as HoleScore;
  return 'HoleScore(teamId: ${_this.teamId}, value: ${_this.value}, updatedBy: ${_this.updatedBy}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $HoleScoreCopyWith<$Res>  {
  factory $HoleScoreCopyWith(HoleScore value, $Res Function(HoleScore) _then) = _$HoleScoreCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'team_id') String teamId, int value,@JsonKey(name: 'updated_by') String? updatedBy,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$HoleScoreCopyWithImpl<$Res>
    implements $HoleScoreCopyWith<$Res> {
  _$HoleScoreCopyWithImpl(this._self, this._then);

  final HoleScore _self;
  final $Res Function(HoleScore) _then;

/// Create a copy of HoleScore
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teamId = null,Object? value = null,Object? updatedBy = freezed,Object? updatedAt = freezed,}) {
  return _then(HoleScore(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [HoleScore].
extension HoleScorePatterns on HoleScore {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HoleScore value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HoleScore() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HoleScore value)  $default,){
final _that = this;
switch (_that) {
case _HoleScore():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HoleScore value)?  $default,){
final _that = this;
switch (_that) {
case _HoleScore() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'team_id')  String teamId,  int value, @JsonKey(name: 'updated_by')  String? updatedBy, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HoleScore() when $default != null:
return $default(_that.teamId,_that.value,_that.updatedBy,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'team_id')  String teamId,  int value, @JsonKey(name: 'updated_by')  String? updatedBy, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _HoleScore():
return $default(_that.teamId,_that.value,_that.updatedBy,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'team_id')  String teamId,  int value, @JsonKey(name: 'updated_by')  String? updatedBy, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _HoleScore() when $default != null:
return $default(_that.teamId,_that.value,_that.updatedBy,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HoleScore implements HoleScore {
  const _HoleScore({@JsonKey(name: 'team_id') required this.teamId, required this.value, @JsonKey(name: 'updated_by') this.updatedBy, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _HoleScore.fromJson(Map<String, dynamic> json) => _$HoleScoreFromJson(json);

@override@JsonKey(name: 'team_id') final  String teamId;
@override final  int value;
@override@JsonKey(name: 'updated_by') final  String? updatedBy;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of HoleScore
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HoleScoreCopyWith<_HoleScore> get copyWith => __$HoleScoreCopyWithImpl<_HoleScore>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HoleScoreToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HoleScore&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.value, value) || other.value == value)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,teamId,value,updatedBy,updatedAt);
}

@override
String toString() {
    return 'HoleScore(teamId: $teamId, value: $value, updatedBy: $updatedBy, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$HoleScoreCopyWith<$Res> implements $HoleScoreCopyWith<$Res> {
  factory _$HoleScoreCopyWith(_HoleScore value, $Res Function(_HoleScore) _then) = __$HoleScoreCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'team_id') String teamId, int value,@JsonKey(name: 'updated_by') String? updatedBy,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$HoleScoreCopyWithImpl<$Res>
    implements _$HoleScoreCopyWith<$Res> {
  __$HoleScoreCopyWithImpl(this._self, this._then);

  final _HoleScore _self;
  final $Res Function(_HoleScore) _then;

/// Create a copy of HoleScore
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teamId = null,Object? value = null,Object? updatedBy = freezed,Object? updatedAt = freezed,}) {
  return _then(_HoleScore(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$PlayedHole {

 String get id; int get position;@JsonKey(name: 'game_mode') GameMode get gameMode; PlayedHoleGeo? get hole; String? get label; int get par; String? get comment; List<HoleScore> get scores;
/// Create a copy of PlayedHole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayedHoleCopyWith<PlayedHole> get copyWith => _$PlayedHoleCopyWithImpl<PlayedHole>(this as PlayedHole, _$identity);

  /// Serializes this PlayedHole to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlayedHole;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayedHole&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.gameMode, _this.gameMode) || other.gameMode == _this.gameMode)&&(identical(other.hole, _this.hole) || other.hole == _this.hole)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.par, _this.par) || other.par == _this.par)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&const DeepCollectionEquality().equals(other.scores, _this.scores));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlayedHole;
  return Object.hash(runtimeType,_this.id,_this.position,_this.gameMode,_this.hole,_this.label,_this.par,_this.comment,const DeepCollectionEquality().hash(_this.scores));
}

@override
String toString() {
  final _this = this as PlayedHole;
  return 'PlayedHole(id: ${_this.id}, position: ${_this.position}, gameMode: ${_this.gameMode}, hole: ${_this.hole}, label: ${_this.label}, par: ${_this.par}, comment: ${_this.comment}, scores: ${_this.scores})';
}


}

/// @nodoc
abstract mixin class $PlayedHoleCopyWith<$Res>  {
  factory $PlayedHoleCopyWith(PlayedHole value, $Res Function(PlayedHole) _then) = _$PlayedHoleCopyWithImpl;
@useResult
$Res call({
 String id, int position,@JsonKey(name: 'game_mode') GameMode gameMode, PlayedHoleGeo? hole, String? label, int par, String? comment, List<HoleScore> scores
});


$PlayedHoleGeoCopyWith<$Res>? get hole;

}
/// @nodoc
class _$PlayedHoleCopyWithImpl<$Res>
    implements $PlayedHoleCopyWith<$Res> {
  _$PlayedHoleCopyWithImpl(this._self, this._then);

  final PlayedHole _self;
  final $Res Function(PlayedHole) _then;

/// Create a copy of PlayedHole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? position = null,Object? gameMode = null,Object? hole = freezed,Object? label = freezed,Object? par = null,Object? comment = freezed,Object? scores = null,}) {
  return _then(PlayedHole(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,gameMode: null == gameMode ? _self.gameMode : gameMode // ignore: cast_nullable_to_non_nullable
as GameMode,hole: freezed == hole ? _self.hole : hole // ignore: cast_nullable_to_non_nullable
as PlayedHoleGeo?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,par: null == par ? _self.par : par // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,scores: null == scores ? _self.scores : scores // ignore: cast_nullable_to_non_nullable
as List<HoleScore>,
  ));
}
/// Create a copy of PlayedHole
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayedHoleGeoCopyWith<$Res>? get hole {
    if (_self.hole == null) {
    return null;
  }

  return $PlayedHoleGeoCopyWith<$Res>(_self.hole!, (value) {
    return _then(_self.copyWith(hole: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayedHole].
extension PlayedHolePatterns on PlayedHole {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayedHole value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayedHole() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayedHole value)  $default,){
final _that = this;
switch (_that) {
case _PlayedHole():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayedHole value)?  $default,){
final _that = this;
switch (_that) {
case _PlayedHole() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int position, @JsonKey(name: 'game_mode')  GameMode gameMode,  PlayedHoleGeo? hole,  String? label,  int par,  String? comment,  List<HoleScore> scores)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayedHole() when $default != null:
return $default(_that.id,_that.position,_that.gameMode,_that.hole,_that.label,_that.par,_that.comment,_that.scores);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int position, @JsonKey(name: 'game_mode')  GameMode gameMode,  PlayedHoleGeo? hole,  String? label,  int par,  String? comment,  List<HoleScore> scores)  $default,) {final _that = this;
switch (_that) {
case _PlayedHole():
return $default(_that.id,_that.position,_that.gameMode,_that.hole,_that.label,_that.par,_that.comment,_that.scores);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int position, @JsonKey(name: 'game_mode')  GameMode gameMode,  PlayedHoleGeo? hole,  String? label,  int par,  String? comment,  List<HoleScore> scores)?  $default,) {final _that = this;
switch (_that) {
case _PlayedHole() when $default != null:
return $default(_that.id,_that.position,_that.gameMode,_that.hole,_that.label,_that.par,_that.comment,_that.scores);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayedHole implements PlayedHole {
  const _PlayedHole({required this.id, required this.position, @JsonKey(name: 'game_mode') required this.gameMode, this.hole, this.label, required this.par, this.comment, required  List<HoleScore> scores}): _scores = scores;
  factory _PlayedHole.fromJson(Map<String, dynamic> json) => _$PlayedHoleFromJson(json);

@override final  String id;
@override final  int position;
@override@JsonKey(name: 'game_mode') final  GameMode gameMode;
@override final  PlayedHoleGeo? hole;
@override final  String? label;
@override final  int par;
@override final  String? comment;
 final  List<HoleScore> _scores;
@override List<HoleScore> get scores {
  if (_scores is EqualUnmodifiableListView) return _scores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scores);
}


/// Create a copy of PlayedHole
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayedHoleCopyWith<_PlayedHole> get copyWith => __$PlayedHoleCopyWithImpl<_PlayedHole>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayedHoleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayedHole&&(identical(other.id, id) || other.id == id)&&(identical(other.position, position) || other.position == position)&&(identical(other.gameMode, gameMode) || other.gameMode == gameMode)&&(identical(other.hole, hole) || other.hole == hole)&&(identical(other.label, label) || other.label == label)&&(identical(other.par, par) || other.par == par)&&(identical(other.comment, comment) || other.comment == comment)&&const DeepCollectionEquality().equals(other.scores, _scores));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,position,gameMode,hole,label,par,comment,const DeepCollectionEquality().hash(_scores));
}

@override
String toString() {
    return 'PlayedHole(id: $id, position: $position, gameMode: $gameMode, hole: $hole, label: $label, par: $par, comment: $comment, scores: $scores)';
}


}

/// @nodoc
abstract mixin class _$PlayedHoleCopyWith<$Res> implements $PlayedHoleCopyWith<$Res> {
  factory _$PlayedHoleCopyWith(_PlayedHole value, $Res Function(_PlayedHole) _then) = __$PlayedHoleCopyWithImpl;
@override @useResult
$Res call({
 String id, int position,@JsonKey(name: 'game_mode') GameMode gameMode, PlayedHoleGeo? hole, String? label, int par, String? comment, List<HoleScore> scores
});


@override $PlayedHoleGeoCopyWith<$Res>? get hole;

}
/// @nodoc
class __$PlayedHoleCopyWithImpl<$Res>
    implements _$PlayedHoleCopyWith<$Res> {
  __$PlayedHoleCopyWithImpl(this._self, this._then);

  final _PlayedHole _self;
  final $Res Function(_PlayedHole) _then;

/// Create a copy of PlayedHole
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? position = null,Object? gameMode = null,Object? hole = freezed,Object? label = freezed,Object? par = null,Object? comment = freezed,Object? scores = null,}) {
  return _then(_PlayedHole(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,gameMode: null == gameMode ? _self.gameMode : gameMode // ignore: cast_nullable_to_non_nullable
as GameMode,hole: freezed == hole ? _self.hole : hole // ignore: cast_nullable_to_non_nullable
as PlayedHoleGeo?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,par: null == par ? _self.par : par // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,scores: null == scores ? _self._scores : scores // ignore: cast_nullable_to_non_nullable
as List<HoleScore>,
  ));
}

/// Create a copy of PlayedHole
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayedHoleGeoCopyWith<$Res>? get hole {
    if (_self.hole == null) {
    return null;
  }

  return $PlayedHoleGeoCopyWith<$Res>(_self.hole!, (value) {
    return _then(_self.copyWith(hole: value));
  });
}
}

// dart format on
