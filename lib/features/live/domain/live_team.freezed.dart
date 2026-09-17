// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_team.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TeamPlayerName {

@JsonKey(name: 'player_id') String get playerId; String get name;
/// Create a copy of TeamPlayerName
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamPlayerNameCopyWith<TeamPlayerName> get copyWith => _$TeamPlayerNameCopyWithImpl<TeamPlayerName>(this as TeamPlayerName, _$identity);

  /// Serializes this TeamPlayerName to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TeamPlayerName;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamPlayerName&&(identical(other.playerId, _this.playerId) || other.playerId == _this.playerId)&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TeamPlayerName;
  return Object.hash(runtimeType,_this.playerId,_this.name);
}

@override
String toString() {
  final _this = this as TeamPlayerName;
  return 'TeamPlayerName(playerId: ${_this.playerId}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $TeamPlayerNameCopyWith<$Res>  {
  factory $TeamPlayerNameCopyWith(TeamPlayerName value, $Res Function(TeamPlayerName) _then) = _$TeamPlayerNameCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'player_id') String playerId, String name
});




}
/// @nodoc
class _$TeamPlayerNameCopyWithImpl<$Res>
    implements $TeamPlayerNameCopyWith<$Res> {
  _$TeamPlayerNameCopyWithImpl(this._self, this._then);

  final TeamPlayerName _self;
  final $Res Function(TeamPlayerName) _then;

/// Create a copy of TeamPlayerName
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playerId = null,Object? name = null,}) {
  return _then(TeamPlayerName(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamPlayerName].
extension TeamPlayerNamePatterns on TeamPlayerName {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamPlayerName value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamPlayerName() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamPlayerName value)  $default,){
final _that = this;
switch (_that) {
case _TeamPlayerName():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamPlayerName value)?  $default,){
final _that = this;
switch (_that) {
case _TeamPlayerName() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'player_id')  String playerId,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamPlayerName() when $default != null:
return $default(_that.playerId,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'player_id')  String playerId,  String name)  $default,) {final _that = this;
switch (_that) {
case _TeamPlayerName():
return $default(_that.playerId,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'player_id')  String playerId,  String name)?  $default,) {final _that = this;
switch (_that) {
case _TeamPlayerName() when $default != null:
return $default(_that.playerId,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamPlayerName implements TeamPlayerName {
  const _TeamPlayerName({@JsonKey(name: 'player_id') required this.playerId, required this.name});
  factory _TeamPlayerName.fromJson(Map<String, dynamic> json) => _$TeamPlayerNameFromJson(json);

@override@JsonKey(name: 'player_id') final  String playerId;
@override final  String name;

/// Create a copy of TeamPlayerName
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamPlayerNameCopyWith<_TeamPlayerName> get copyWith => __$TeamPlayerNameCopyWithImpl<_TeamPlayerName>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamPlayerNameToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamPlayerName&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,playerId,name);
}

@override
String toString() {
    return 'TeamPlayerName(playerId: $playerId, name: $name)';
}


}

/// @nodoc
abstract mixin class _$TeamPlayerNameCopyWith<$Res> implements $TeamPlayerNameCopyWith<$Res> {
  factory _$TeamPlayerNameCopyWith(_TeamPlayerName value, $Res Function(_TeamPlayerName) _then) = __$TeamPlayerNameCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'player_id') String playerId, String name
});




}
/// @nodoc
class __$TeamPlayerNameCopyWithImpl<$Res>
    implements _$TeamPlayerNameCopyWith<$Res> {
  __$TeamPlayerNameCopyWithImpl(this._self, this._then);

  final _TeamPlayerName _self;
  final $Res Function(_TeamPlayerName) _then;

/// Create a copy of TeamPlayerName
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playerId = null,Object? name = null,}) {
  return _then(_TeamPlayerName(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LiveTeam {

 String get id; int get position; List<TeamPlayerName> get players;
/// Create a copy of LiveTeam
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveTeamCopyWith<LiveTeam> get copyWith => _$LiveTeamCopyWithImpl<LiveTeam>(this as LiveTeam, _$identity);

  /// Serializes this LiveTeam to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LiveTeam;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveTeam&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.position, _this.position) || other.position == _this.position)&&const DeepCollectionEquality().equals(other.players, _this.players));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LiveTeam;
  return Object.hash(runtimeType,_this.id,_this.position,const DeepCollectionEquality().hash(_this.players));
}

@override
String toString() {
  final _this = this as LiveTeam;
  return 'LiveTeam(id: ${_this.id}, position: ${_this.position}, players: ${_this.players})';
}


}

/// @nodoc
abstract mixin class $LiveTeamCopyWith<$Res>  {
  factory $LiveTeamCopyWith(LiveTeam value, $Res Function(LiveTeam) _then) = _$LiveTeamCopyWithImpl;
@useResult
$Res call({
 String id, int position, List<TeamPlayerName> players
});




}
/// @nodoc
class _$LiveTeamCopyWithImpl<$Res>
    implements $LiveTeamCopyWith<$Res> {
  _$LiveTeamCopyWithImpl(this._self, this._then);

  final LiveTeam _self;
  final $Res Function(LiveTeam) _then;

/// Create a copy of LiveTeam
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? position = null,Object? players = null,}) {
  return _then(LiveTeam(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<TeamPlayerName>,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveTeam].
extension LiveTeamPatterns on LiveTeam {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveTeam value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveTeam() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveTeam value)  $default,){
final _that = this;
switch (_that) {
case _LiveTeam():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveTeam value)?  $default,){
final _that = this;
switch (_that) {
case _LiveTeam() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int position,  List<TeamPlayerName> players)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveTeam() when $default != null:
return $default(_that.id,_that.position,_that.players);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int position,  List<TeamPlayerName> players)  $default,) {final _that = this;
switch (_that) {
case _LiveTeam():
return $default(_that.id,_that.position,_that.players);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int position,  List<TeamPlayerName> players)?  $default,) {final _that = this;
switch (_that) {
case _LiveTeam() when $default != null:
return $default(_that.id,_that.position,_that.players);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveTeam implements LiveTeam {
  const _LiveTeam({required this.id, required this.position, required  List<TeamPlayerName> players}): _players = players;
  factory _LiveTeam.fromJson(Map<String, dynamic> json) => _$LiveTeamFromJson(json);

@override final  String id;
@override final  int position;
 final  List<TeamPlayerName> _players;
@override List<TeamPlayerName> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}


/// Create a copy of LiveTeam
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveTeamCopyWith<_LiveTeam> get copyWith => __$LiveTeamCopyWithImpl<_LiveTeam>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveTeamToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveTeam&&(identical(other.id, id) || other.id == id)&&(identical(other.position, position) || other.position == position)&&const DeepCollectionEquality().equals(other.players, _players));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,position,const DeepCollectionEquality().hash(_players));
}

@override
String toString() {
    return 'LiveTeam(id: $id, position: $position, players: $players)';
}


}

/// @nodoc
abstract mixin class _$LiveTeamCopyWith<$Res> implements $LiveTeamCopyWith<$Res> {
  factory _$LiveTeamCopyWith(_LiveTeam value, $Res Function(_LiveTeam) _then) = __$LiveTeamCopyWithImpl;
@override @useResult
$Res call({
 String id, int position, List<TeamPlayerName> players
});




}
/// @nodoc
class __$LiveTeamCopyWithImpl<$Res>
    implements _$LiveTeamCopyWith<$Res> {
  __$LiveTeamCopyWithImpl(this._self, this._then);

  final _LiveTeam _self;
  final $Res Function(_LiveTeam) _then;

/// Create a copy of LiveTeam
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? position = null,Object? players = null,}) {
  return _then(_LiveTeam(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<TeamPlayerName>,
  ));
}


}

// dart format on
