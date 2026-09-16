// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionMember {

@JsonKey(name: 'session_id') String get sessionId;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'team_id') String? get teamId; MemberRole get role;
/// Create a copy of SessionMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionMemberCopyWith<SessionMember> get copyWith => _$SessionMemberCopyWithImpl<SessionMember>(this as SessionMember, _$identity);

  /// Serializes this SessionMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SessionMember;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionMember&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.teamId, _this.teamId) || other.teamId == _this.teamId)&&(identical(other.role, _this.role) || other.role == _this.role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionMember;
  return Object.hash(runtimeType,_this.sessionId,_this.userId,_this.teamId,_this.role);
}

@override
String toString() {
  final _this = this as SessionMember;
  return 'SessionMember(sessionId: ${_this.sessionId}, userId: ${_this.userId}, teamId: ${_this.teamId}, role: ${_this.role})';
}


}

/// @nodoc
abstract mixin class $SessionMemberCopyWith<$Res>  {
  factory $SessionMemberCopyWith(SessionMember value, $Res Function(SessionMember) _then) = _$SessionMemberCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'team_id') String? teamId, MemberRole role
});




}
/// @nodoc
class _$SessionMemberCopyWithImpl<$Res>
    implements $SessionMemberCopyWith<$Res> {
  _$SessionMemberCopyWithImpl(this._self, this._then);

  final SessionMember _self;
  final $Res Function(SessionMember) _then;

/// Create a copy of SessionMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? userId = null,Object? teamId = freezed,Object? role = null,}) {
  return _then(SessionMember(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionMember].
extension SessionMemberPatterns on SessionMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionMember value)  $default,){
final _that = this;
switch (_that) {
case _SessionMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionMember value)?  $default,){
final _that = this;
switch (_that) {
case _SessionMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'team_id')  String? teamId,  MemberRole role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionMember() when $default != null:
return $default(_that.sessionId,_that.userId,_that.teamId,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'team_id')  String? teamId,  MemberRole role)  $default,) {final _that = this;
switch (_that) {
case _SessionMember():
return $default(_that.sessionId,_that.userId,_that.teamId,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'team_id')  String? teamId,  MemberRole role)?  $default,) {final _that = this;
switch (_that) {
case _SessionMember() when $default != null:
return $default(_that.sessionId,_that.userId,_that.teamId,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionMember implements SessionMember {
  const _SessionMember({@JsonKey(name: 'session_id') required this.sessionId, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'team_id') this.teamId, required this.role});
  factory _SessionMember.fromJson(Map<String, dynamic> json) => _$SessionMemberFromJson(json);

@override@JsonKey(name: 'session_id') final  String sessionId;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'team_id') final  String? teamId;
@override final  MemberRole role;

/// Create a copy of SessionMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionMemberCopyWith<_SessionMember> get copyWith => __$SessionMemberCopyWithImpl<_SessionMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionMemberToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionMember&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sessionId,userId,teamId,role);
}

@override
String toString() {
    return 'SessionMember(sessionId: $sessionId, userId: $userId, teamId: $teamId, role: $role)';
}


}

/// @nodoc
abstract mixin class _$SessionMemberCopyWith<$Res> implements $SessionMemberCopyWith<$Res> {
  factory _$SessionMemberCopyWith(_SessionMember value, $Res Function(_SessionMember) _then) = __$SessionMemberCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'team_id') String? teamId, MemberRole role
});




}
/// @nodoc
class __$SessionMemberCopyWithImpl<$Res>
    implements _$SessionMemberCopyWith<$Res> {
  __$SessionMemberCopyWithImpl(this._self, this._then);

  final _SessionMember _self;
  final $Res Function(_SessionMember) _then;

/// Create a copy of SessionMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? userId = null,Object? teamId = freezed,Object? role = null,}) {
  return _then(_SessionMember(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,
  ));
}


}

// dart format on
