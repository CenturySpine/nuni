// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LiveMember {

@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'team_id') String? get teamId; MemberRole get role;@JsonKey(name: 'player_name') String get playerName;
/// Create a copy of LiveMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveMemberCopyWith<LiveMember> get copyWith => _$LiveMemberCopyWithImpl<LiveMember>(this as LiveMember, _$identity);

  /// Serializes this LiveMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LiveMember;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveMember&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.teamId, _this.teamId) || other.teamId == _this.teamId)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.playerName, _this.playerName) || other.playerName == _this.playerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LiveMember;
  return Object.hash(runtimeType,_this.userId,_this.teamId,_this.role,_this.playerName);
}

@override
String toString() {
  final _this = this as LiveMember;
  return 'LiveMember(userId: ${_this.userId}, teamId: ${_this.teamId}, role: ${_this.role}, playerName: ${_this.playerName})';
}


}

/// @nodoc
abstract mixin class $LiveMemberCopyWith<$Res>  {
  factory $LiveMemberCopyWith(LiveMember value, $Res Function(LiveMember) _then) = _$LiveMemberCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'team_id') String? teamId, MemberRole role,@JsonKey(name: 'player_name') String playerName
});




}
/// @nodoc
class _$LiveMemberCopyWithImpl<$Res>
    implements $LiveMemberCopyWith<$Res> {
  _$LiveMemberCopyWithImpl(this._self, this._then);

  final LiveMember _self;
  final $Res Function(LiveMember) _then;

/// Create a copy of LiveMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? teamId = freezed,Object? role = null,Object? playerName = null,}) {
  return _then(LiveMember(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,playerName: null == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveMember].
extension LiveMemberPatterns on LiveMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveMember value)  $default,){
final _that = this;
switch (_that) {
case _LiveMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveMember value)?  $default,){
final _that = this;
switch (_that) {
case _LiveMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'team_id')  String? teamId,  MemberRole role, @JsonKey(name: 'player_name')  String playerName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveMember() when $default != null:
return $default(_that.userId,_that.teamId,_that.role,_that.playerName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'team_id')  String? teamId,  MemberRole role, @JsonKey(name: 'player_name')  String playerName)  $default,) {final _that = this;
switch (_that) {
case _LiveMember():
return $default(_that.userId,_that.teamId,_that.role,_that.playerName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'team_id')  String? teamId,  MemberRole role, @JsonKey(name: 'player_name')  String playerName)?  $default,) {final _that = this;
switch (_that) {
case _LiveMember() when $default != null:
return $default(_that.userId,_that.teamId,_that.role,_that.playerName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveMember implements LiveMember {
  const _LiveMember({@JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'team_id') this.teamId, required this.role, @JsonKey(name: 'player_name') required this.playerName});
  factory _LiveMember.fromJson(Map<String, dynamic> json) => _$LiveMemberFromJson(json);

@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'team_id') final  String? teamId;
@override final  MemberRole role;
@override@JsonKey(name: 'player_name') final  String playerName;

/// Create a copy of LiveMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveMemberCopyWith<_LiveMember> get copyWith => __$LiveMemberCopyWithImpl<_LiveMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveMemberToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveMember&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.role, role) || other.role == role)&&(identical(other.playerName, playerName) || other.playerName == playerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,userId,teamId,role,playerName);
}

@override
String toString() {
    return 'LiveMember(userId: $userId, teamId: $teamId, role: $role, playerName: $playerName)';
}


}

/// @nodoc
abstract mixin class _$LiveMemberCopyWith<$Res> implements $LiveMemberCopyWith<$Res> {
  factory _$LiveMemberCopyWith(_LiveMember value, $Res Function(_LiveMember) _then) = __$LiveMemberCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'team_id') String? teamId, MemberRole role,@JsonKey(name: 'player_name') String playerName
});




}
/// @nodoc
class __$LiveMemberCopyWithImpl<$Res>
    implements _$LiveMemberCopyWith<$Res> {
  __$LiveMemberCopyWithImpl(this._self, this._then);

  final _LiveMember _self;
  final $Res Function(_LiveMember) _then;

/// Create a copy of LiveMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? teamId = freezed,Object? role = null,Object? playerName = null,}) {
  return _then(_LiveMember(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,playerName: null == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
