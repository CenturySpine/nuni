// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionPhoto {

 String get id;@JsonKey(name: 'session_id') String get sessionId;@JsonKey(name: 'storage_path') String get storagePath;@JsonKey(name: 'uploaded_by') String? get uploadedBy;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of SessionPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionPhotoCopyWith<SessionPhoto> get copyWith => _$SessionPhotoCopyWithImpl<SessionPhoto>(this as SessionPhoto, _$identity);

  /// Serializes this SessionPhoto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SessionPhoto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionPhoto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.storagePath, _this.storagePath) || other.storagePath == _this.storagePath)&&(identical(other.uploadedBy, _this.uploadedBy) || other.uploadedBy == _this.uploadedBy)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionPhoto;
  return Object.hash(runtimeType,_this.id,_this.sessionId,_this.storagePath,_this.uploadedBy,_this.createdAt);
}

@override
String toString() {
  final _this = this as SessionPhoto;
  return 'SessionPhoto(id: ${_this.id}, sessionId: ${_this.sessionId}, storagePath: ${_this.storagePath}, uploadedBy: ${_this.uploadedBy}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $SessionPhotoCopyWith<$Res>  {
  factory $SessionPhotoCopyWith(SessionPhoto value, $Res Function(SessionPhoto) _then) = _$SessionPhotoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'storage_path') String storagePath,@JsonKey(name: 'uploaded_by') String? uploadedBy,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$SessionPhotoCopyWithImpl<$Res>
    implements $SessionPhotoCopyWith<$Res> {
  _$SessionPhotoCopyWithImpl(this._self, this._then);

  final SessionPhoto _self;
  final $Res Function(SessionPhoto) _then;

/// Create a copy of SessionPhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = null,Object? storagePath = null,Object? uploadedBy = freezed,Object? createdAt = null,}) {
  return _then(SessionPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,uploadedBy: freezed == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionPhoto].
extension SessionPhotoPatterns on SessionPhoto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionPhoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionPhoto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionPhoto value)  $default,){
final _that = this;
switch (_that) {
case _SessionPhoto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionPhoto value)?  $default,){
final _that = this;
switch (_that) {
case _SessionPhoto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'storage_path')  String storagePath, @JsonKey(name: 'uploaded_by')  String? uploadedBy, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionPhoto() when $default != null:
return $default(_that.id,_that.sessionId,_that.storagePath,_that.uploadedBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'storage_path')  String storagePath, @JsonKey(name: 'uploaded_by')  String? uploadedBy, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _SessionPhoto():
return $default(_that.id,_that.sessionId,_that.storagePath,_that.uploadedBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'storage_path')  String storagePath, @JsonKey(name: 'uploaded_by')  String? uploadedBy, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SessionPhoto() when $default != null:
return $default(_that.id,_that.sessionId,_that.storagePath,_that.uploadedBy,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionPhoto implements SessionPhoto {
  const _SessionPhoto({required this.id, @JsonKey(name: 'session_id') required this.sessionId, @JsonKey(name: 'storage_path') required this.storagePath, @JsonKey(name: 'uploaded_by') this.uploadedBy, @JsonKey(name: 'created_at') required this.createdAt});
  factory _SessionPhoto.fromJson(Map<String, dynamic> json) => _$SessionPhotoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'session_id') final  String sessionId;
@override@JsonKey(name: 'storage_path') final  String storagePath;
@override@JsonKey(name: 'uploaded_by') final  String? uploadedBy;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of SessionPhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionPhotoCopyWith<_SessionPhoto> get copyWith => __$SessionPhotoCopyWithImpl<_SessionPhoto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionPhotoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,sessionId,storagePath,uploadedBy,createdAt);
}

@override
String toString() {
    return 'SessionPhoto(id: $id, sessionId: $sessionId, storagePath: $storagePath, uploadedBy: $uploadedBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SessionPhotoCopyWith<$Res> implements $SessionPhotoCopyWith<$Res> {
  factory _$SessionPhotoCopyWith(_SessionPhoto value, $Res Function(_SessionPhoto) _then) = __$SessionPhotoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'storage_path') String storagePath,@JsonKey(name: 'uploaded_by') String? uploadedBy,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$SessionPhotoCopyWithImpl<$Res>
    implements _$SessionPhotoCopyWith<$Res> {
  __$SessionPhotoCopyWithImpl(this._self, this._then);

  final _SessionPhoto _self;
  final $Res Function(_SessionPhoto) _then;

/// Create a copy of SessionPhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? storagePath = null,Object? uploadedBy = freezed,Object? createdAt = null,}) {
  return _then(_SessionPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,uploadedBy: freezed == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
