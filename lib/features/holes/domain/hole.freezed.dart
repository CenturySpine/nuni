// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hole.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HolePathPoint {

 double get lat; double get lng;
/// Create a copy of HolePathPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HolePathPointCopyWith<HolePathPoint> get copyWith => _$HolePathPointCopyWithImpl<HolePathPoint>(this as HolePathPoint, _$identity);

  /// Serializes this HolePathPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HolePathPoint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HolePathPoint&&(identical(other.lat, _this.lat) || other.lat == _this.lat)&&(identical(other.lng, _this.lng) || other.lng == _this.lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HolePathPoint;
  return Object.hash(runtimeType,_this.lat,_this.lng);
}

@override
String toString() {
  final _this = this as HolePathPoint;
  return 'HolePathPoint(lat: ${_this.lat}, lng: ${_this.lng})';
}


}

/// @nodoc
abstract mixin class $HolePathPointCopyWith<$Res>  {
  factory $HolePathPointCopyWith(HolePathPoint value, $Res Function(HolePathPoint) _then) = _$HolePathPointCopyWithImpl;
@useResult
$Res call({
 double lat, double lng
});




}
/// @nodoc
class _$HolePathPointCopyWithImpl<$Res>
    implements $HolePathPointCopyWith<$Res> {
  _$HolePathPointCopyWithImpl(this._self, this._then);

  final HolePathPoint _self;
  final $Res Function(HolePathPoint) _then;

/// Create a copy of HolePathPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lat = null,Object? lng = null,}) {
  return _then(HolePathPoint(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [HolePathPoint].
extension HolePathPointPatterns on HolePathPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HolePathPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HolePathPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HolePathPoint value)  $default,){
final _that = this;
switch (_that) {
case _HolePathPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HolePathPoint value)?  $default,){
final _that = this;
switch (_that) {
case _HolePathPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double lat,  double lng)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HolePathPoint() when $default != null:
return $default(_that.lat,_that.lng);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double lat,  double lng)  $default,) {final _that = this;
switch (_that) {
case _HolePathPoint():
return $default(_that.lat,_that.lng);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double lat,  double lng)?  $default,) {final _that = this;
switch (_that) {
case _HolePathPoint() when $default != null:
return $default(_that.lat,_that.lng);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HolePathPoint implements HolePathPoint {
  const _HolePathPoint({required this.lat, required this.lng});
  factory _HolePathPoint.fromJson(Map<String, dynamic> json) => _$HolePathPointFromJson(json);

@override final  double lat;
@override final  double lng;

/// Create a copy of HolePathPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HolePathPointCopyWith<_HolePathPoint> get copyWith => __$HolePathPointCopyWithImpl<_HolePathPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HolePathPointToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HolePathPoint&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lat,lng);
}

@override
String toString() {
    return 'HolePathPoint(lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class _$HolePathPointCopyWith<$Res> implements $HolePathPointCopyWith<$Res> {
  factory _$HolePathPointCopyWith(_HolePathPoint value, $Res Function(_HolePathPoint) _then) = __$HolePathPointCopyWithImpl;
@override @useResult
$Res call({
 double lat, double lng
});




}
/// @nodoc
class __$HolePathPointCopyWithImpl<$Res>
    implements _$HolePathPointCopyWith<$Res> {
  __$HolePathPointCopyWithImpl(this._self, this._then);

  final _HolePathPoint _self;
  final $Res Function(_HolePathPoint) _then;

/// Create a copy of HolePathPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lat = null,Object? lng = null,}) {
  return _then(_HolePathPoint(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$Hole {

 String get id; String get name; String? get description; int get par;@JsonKey(name: 'distance_m') int? get distanceM;@JsonKey(name: 'start_lat') double? get startLat;@JsonKey(name: 'start_lng') double? get startLng;@JsonKey(name: 'end_lat') double? get endLat;@JsonKey(name: 'end_lng') double? get endLng; List<HolePathPoint>? get path;@JsonKey(name: 'photo_start_path') String? get photoStartPath;@JsonKey(name: 'photo_end_path') String? get photoEndPath; HoleVisibility get visibility;@JsonKey(name: 'owner_id') String get ownerId; double? get distance;
/// Create a copy of Hole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HoleCopyWith<Hole> get copyWith => _$HoleCopyWithImpl<Hole>(this as Hole, _$identity);

  /// Serializes this Hole to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Hole;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Hole&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.par, _this.par) || other.par == _this.par)&&(identical(other.distanceM, _this.distanceM) || other.distanceM == _this.distanceM)&&(identical(other.startLat, _this.startLat) || other.startLat == _this.startLat)&&(identical(other.startLng, _this.startLng) || other.startLng == _this.startLng)&&(identical(other.endLat, _this.endLat) || other.endLat == _this.endLat)&&(identical(other.endLng, _this.endLng) || other.endLng == _this.endLng)&&const DeepCollectionEquality().equals(other.path, _this.path)&&(identical(other.photoStartPath, _this.photoStartPath) || other.photoStartPath == _this.photoStartPath)&&(identical(other.photoEndPath, _this.photoEndPath) || other.photoEndPath == _this.photoEndPath)&&(identical(other.visibility, _this.visibility) || other.visibility == _this.visibility)&&(identical(other.ownerId, _this.ownerId) || other.ownerId == _this.ownerId)&&(identical(other.distance, _this.distance) || other.distance == _this.distance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Hole;
  return Object.hash(runtimeType,_this.id,_this.name,_this.description,_this.par,_this.distanceM,_this.startLat,_this.startLng,_this.endLat,_this.endLng,const DeepCollectionEquality().hash(_this.path),_this.photoStartPath,_this.photoEndPath,_this.visibility,_this.ownerId,_this.distance);
}

@override
String toString() {
  final _this = this as Hole;
  return 'Hole(id: ${_this.id}, name: ${_this.name}, description: ${_this.description}, par: ${_this.par}, distanceM: ${_this.distanceM}, startLat: ${_this.startLat}, startLng: ${_this.startLng}, endLat: ${_this.endLat}, endLng: ${_this.endLng}, path: ${_this.path}, photoStartPath: ${_this.photoStartPath}, photoEndPath: ${_this.photoEndPath}, visibility: ${_this.visibility}, ownerId: ${_this.ownerId}, distance: ${_this.distance})';
}


}

/// @nodoc
abstract mixin class $HoleCopyWith<$Res>  {
  factory $HoleCopyWith(Hole value, $Res Function(Hole) _then) = _$HoleCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, int par,@JsonKey(name: 'distance_m') int? distanceM,@JsonKey(name: 'start_lat') double? startLat,@JsonKey(name: 'start_lng') double? startLng,@JsonKey(name: 'end_lat') double? endLat,@JsonKey(name: 'end_lng') double? endLng, List<HolePathPoint>? path,@JsonKey(name: 'photo_start_path') String? photoStartPath,@JsonKey(name: 'photo_end_path') String? photoEndPath, HoleVisibility visibility,@JsonKey(name: 'owner_id') String ownerId, double? distance
});




}
/// @nodoc
class _$HoleCopyWithImpl<$Res>
    implements $HoleCopyWith<$Res> {
  _$HoleCopyWithImpl(this._self, this._then);

  final Hole _self;
  final $Res Function(Hole) _then;

/// Create a copy of Hole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? par = null,Object? distanceM = freezed,Object? startLat = freezed,Object? startLng = freezed,Object? endLat = freezed,Object? endLng = freezed,Object? path = freezed,Object? photoStartPath = freezed,Object? photoEndPath = freezed,Object? visibility = null,Object? ownerId = null,Object? distance = freezed,}) {
  return _then(Hole(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,par: null == par ? _self.par : par // ignore: cast_nullable_to_non_nullable
as int,distanceM: freezed == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as int?,startLat: freezed == startLat ? _self.startLat : startLat // ignore: cast_nullable_to_non_nullable
as double?,startLng: freezed == startLng ? _self.startLng : startLng // ignore: cast_nullable_to_non_nullable
as double?,endLat: freezed == endLat ? _self.endLat : endLat // ignore: cast_nullable_to_non_nullable
as double?,endLng: freezed == endLng ? _self.endLng : endLng // ignore: cast_nullable_to_non_nullable
as double?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as List<HolePathPoint>?,photoStartPath: freezed == photoStartPath ? _self.photoStartPath : photoStartPath // ignore: cast_nullable_to_non_nullable
as String?,photoEndPath: freezed == photoEndPath ? _self.photoEndPath : photoEndPath // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as HoleVisibility,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,distance: freezed == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [Hole].
extension HolePatterns on Hole {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Hole value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Hole() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Hole value)  $default,){
final _that = this;
switch (_that) {
case _Hole():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Hole value)?  $default,){
final _that = this;
switch (_that) {
case _Hole() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  int par, @JsonKey(name: 'distance_m')  int? distanceM, @JsonKey(name: 'start_lat')  double? startLat, @JsonKey(name: 'start_lng')  double? startLng, @JsonKey(name: 'end_lat')  double? endLat, @JsonKey(name: 'end_lng')  double? endLng,  List<HolePathPoint>? path, @JsonKey(name: 'photo_start_path')  String? photoStartPath, @JsonKey(name: 'photo_end_path')  String? photoEndPath,  HoleVisibility visibility, @JsonKey(name: 'owner_id')  String ownerId,  double? distance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Hole() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.par,_that.distanceM,_that.startLat,_that.startLng,_that.endLat,_that.endLng,_that.path,_that.photoStartPath,_that.photoEndPath,_that.visibility,_that.ownerId,_that.distance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  int par, @JsonKey(name: 'distance_m')  int? distanceM, @JsonKey(name: 'start_lat')  double? startLat, @JsonKey(name: 'start_lng')  double? startLng, @JsonKey(name: 'end_lat')  double? endLat, @JsonKey(name: 'end_lng')  double? endLng,  List<HolePathPoint>? path, @JsonKey(name: 'photo_start_path')  String? photoStartPath, @JsonKey(name: 'photo_end_path')  String? photoEndPath,  HoleVisibility visibility, @JsonKey(name: 'owner_id')  String ownerId,  double? distance)  $default,) {final _that = this;
switch (_that) {
case _Hole():
return $default(_that.id,_that.name,_that.description,_that.par,_that.distanceM,_that.startLat,_that.startLng,_that.endLat,_that.endLng,_that.path,_that.photoStartPath,_that.photoEndPath,_that.visibility,_that.ownerId,_that.distance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  int par, @JsonKey(name: 'distance_m')  int? distanceM, @JsonKey(name: 'start_lat')  double? startLat, @JsonKey(name: 'start_lng')  double? startLng, @JsonKey(name: 'end_lat')  double? endLat, @JsonKey(name: 'end_lng')  double? endLng,  List<HolePathPoint>? path, @JsonKey(name: 'photo_start_path')  String? photoStartPath, @JsonKey(name: 'photo_end_path')  String? photoEndPath,  HoleVisibility visibility, @JsonKey(name: 'owner_id')  String ownerId,  double? distance)?  $default,) {final _that = this;
switch (_that) {
case _Hole() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.par,_that.distanceM,_that.startLat,_that.startLng,_that.endLat,_that.endLng,_that.path,_that.photoStartPath,_that.photoEndPath,_that.visibility,_that.ownerId,_that.distance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Hole implements Hole {
  const _Hole({required this.id, required this.name, this.description, required this.par, @JsonKey(name: 'distance_m') this.distanceM, @JsonKey(name: 'start_lat') this.startLat, @JsonKey(name: 'start_lng') this.startLng, @JsonKey(name: 'end_lat') this.endLat, @JsonKey(name: 'end_lng') this.endLng,  List<HolePathPoint>? path, @JsonKey(name: 'photo_start_path') this.photoStartPath, @JsonKey(name: 'photo_end_path') this.photoEndPath, required this.visibility, @JsonKey(name: 'owner_id') required this.ownerId, this.distance}): _path = path;
  factory _Hole.fromJson(Map<String, dynamic> json) => _$HoleFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  int par;
@override@JsonKey(name: 'distance_m') final  int? distanceM;
@override@JsonKey(name: 'start_lat') final  double? startLat;
@override@JsonKey(name: 'start_lng') final  double? startLng;
@override@JsonKey(name: 'end_lat') final  double? endLat;
@override@JsonKey(name: 'end_lng') final  double? endLng;
 final  List<HolePathPoint>? _path;
@override List<HolePathPoint>? get path {
  final value = _path;
  if (value == null) return null;
  if (_path is EqualUnmodifiableListView) return _path;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'photo_start_path') final  String? photoStartPath;
@override@JsonKey(name: 'photo_end_path') final  String? photoEndPath;
@override final  HoleVisibility visibility;
@override@JsonKey(name: 'owner_id') final  String ownerId;
@override final  double? distance;

/// Create a copy of Hole
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HoleCopyWith<_Hole> get copyWith => __$HoleCopyWithImpl<_Hole>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HoleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Hole&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.par, par) || other.par == par)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.startLat, startLat) || other.startLat == startLat)&&(identical(other.startLng, startLng) || other.startLng == startLng)&&(identical(other.endLat, endLat) || other.endLat == endLat)&&(identical(other.endLng, endLng) || other.endLng == endLng)&&const DeepCollectionEquality().equals(other.path, _path)&&(identical(other.photoStartPath, photoStartPath) || other.photoStartPath == photoStartPath)&&(identical(other.photoEndPath, photoEndPath) || other.photoEndPath == photoEndPath)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.distance, distance) || other.distance == distance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,description,par,distanceM,startLat,startLng,endLat,endLng,const DeepCollectionEquality().hash(_path),photoStartPath,photoEndPath,visibility,ownerId,distance);
}

@override
String toString() {
    return 'Hole(id: $id, name: $name, description: $description, par: $par, distanceM: $distanceM, startLat: $startLat, startLng: $startLng, endLat: $endLat, endLng: $endLng, path: $path, photoStartPath: $photoStartPath, photoEndPath: $photoEndPath, visibility: $visibility, ownerId: $ownerId, distance: $distance)';
}


}

/// @nodoc
abstract mixin class _$HoleCopyWith<$Res> implements $HoleCopyWith<$Res> {
  factory _$HoleCopyWith(_Hole value, $Res Function(_Hole) _then) = __$HoleCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, int par,@JsonKey(name: 'distance_m') int? distanceM,@JsonKey(name: 'start_lat') double? startLat,@JsonKey(name: 'start_lng') double? startLng,@JsonKey(name: 'end_lat') double? endLat,@JsonKey(name: 'end_lng') double? endLng, List<HolePathPoint>? path,@JsonKey(name: 'photo_start_path') String? photoStartPath,@JsonKey(name: 'photo_end_path') String? photoEndPath, HoleVisibility visibility,@JsonKey(name: 'owner_id') String ownerId, double? distance
});




}
/// @nodoc
class __$HoleCopyWithImpl<$Res>
    implements _$HoleCopyWith<$Res> {
  __$HoleCopyWithImpl(this._self, this._then);

  final _Hole _self;
  final $Res Function(_Hole) _then;

/// Create a copy of Hole
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? par = null,Object? distanceM = freezed,Object? startLat = freezed,Object? startLng = freezed,Object? endLat = freezed,Object? endLng = freezed,Object? path = freezed,Object? photoStartPath = freezed,Object? photoEndPath = freezed,Object? visibility = null,Object? ownerId = null,Object? distance = freezed,}) {
  return _then(_Hole(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,par: null == par ? _self.par : par // ignore: cast_nullable_to_non_nullable
as int,distanceM: freezed == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as int?,startLat: freezed == startLat ? _self.startLat : startLat // ignore: cast_nullable_to_non_nullable
as double?,startLng: freezed == startLng ? _self.startLng : startLng // ignore: cast_nullable_to_non_nullable
as double?,endLat: freezed == endLat ? _self.endLat : endLat // ignore: cast_nullable_to_non_nullable
as double?,endLng: freezed == endLng ? _self.endLng : endLng // ignore: cast_nullable_to_non_nullable
as double?,path: freezed == path ? _self._path : path // ignore: cast_nullable_to_non_nullable
as List<HolePathPoint>?,photoStartPath: freezed == photoStartPath ? _self.photoStartPath : photoStartPath // ignore: cast_nullable_to_non_nullable
as String?,photoEndPath: freezed == photoEndPath ? _self.photoEndPath : photoEndPath // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as HoleVisibility,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,distance: freezed == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
