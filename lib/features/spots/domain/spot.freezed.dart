// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Spot {

 String get id;@JsonKey(name: 'association_id') String get associationId; String get name; String? get description; String? get address; String? get city;@JsonKey(name: 'location_lat') double? get locationLat;@JsonKey(name: 'location_lng') double? get locationLng;@JsonKey(name: 'variable_location') bool get variableLocation;
/// Create a copy of Spot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpotCopyWith<Spot> get copyWith => _$SpotCopyWithImpl<Spot>(this as Spot, _$identity);

  /// Serializes this Spot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Spot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Spot&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.associationId, _this.associationId) || other.associationId == _this.associationId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.locationLat, _this.locationLat) || other.locationLat == _this.locationLat)&&(identical(other.locationLng, _this.locationLng) || other.locationLng == _this.locationLng)&&(identical(other.variableLocation, _this.variableLocation) || other.variableLocation == _this.variableLocation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Spot;
  return Object.hash(runtimeType,_this.id,_this.associationId,_this.name,_this.description,_this.address,_this.city,_this.locationLat,_this.locationLng,_this.variableLocation);
}

@override
String toString() {
  final _this = this as Spot;
  return 'Spot(id: ${_this.id}, associationId: ${_this.associationId}, name: ${_this.name}, description: ${_this.description}, address: ${_this.address}, city: ${_this.city}, locationLat: ${_this.locationLat}, locationLng: ${_this.locationLng}, variableLocation: ${_this.variableLocation})';
}


}

/// @nodoc
abstract mixin class $SpotCopyWith<$Res>  {
  factory $SpotCopyWith(Spot value, $Res Function(Spot) _then) = _$SpotCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'association_id') String associationId, String name, String? description, String? address, String? city,@JsonKey(name: 'location_lat') double? locationLat,@JsonKey(name: 'location_lng') double? locationLng,@JsonKey(name: 'variable_location') bool variableLocation
});




}
/// @nodoc
class _$SpotCopyWithImpl<$Res>
    implements $SpotCopyWith<$Res> {
  _$SpotCopyWithImpl(this._self, this._then);

  final Spot _self;
  final $Res Function(Spot) _then;

/// Create a copy of Spot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? associationId = null,Object? name = null,Object? description = freezed,Object? address = freezed,Object? city = freezed,Object? locationLat = freezed,Object? locationLng = freezed,Object? variableLocation = null,}) {
  return _then(Spot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,associationId: null == associationId ? _self.associationId : associationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,locationLat: freezed == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double?,locationLng: freezed == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double?,variableLocation: null == variableLocation ? _self.variableLocation : variableLocation // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Spot].
extension SpotPatterns on Spot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Spot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Spot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Spot value)  $default,){
final _that = this;
switch (_that) {
case _Spot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Spot value)?  $default,){
final _that = this;
switch (_that) {
case _Spot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'association_id')  String associationId,  String name,  String? description,  String? address,  String? city, @JsonKey(name: 'location_lat')  double? locationLat, @JsonKey(name: 'location_lng')  double? locationLng, @JsonKey(name: 'variable_location')  bool variableLocation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Spot() when $default != null:
return $default(_that.id,_that.associationId,_that.name,_that.description,_that.address,_that.city,_that.locationLat,_that.locationLng,_that.variableLocation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'association_id')  String associationId,  String name,  String? description,  String? address,  String? city, @JsonKey(name: 'location_lat')  double? locationLat, @JsonKey(name: 'location_lng')  double? locationLng, @JsonKey(name: 'variable_location')  bool variableLocation)  $default,) {final _that = this;
switch (_that) {
case _Spot():
return $default(_that.id,_that.associationId,_that.name,_that.description,_that.address,_that.city,_that.locationLat,_that.locationLng,_that.variableLocation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'association_id')  String associationId,  String name,  String? description,  String? address,  String? city, @JsonKey(name: 'location_lat')  double? locationLat, @JsonKey(name: 'location_lng')  double? locationLng, @JsonKey(name: 'variable_location')  bool variableLocation)?  $default,) {final _that = this;
switch (_that) {
case _Spot() when $default != null:
return $default(_that.id,_that.associationId,_that.name,_that.description,_that.address,_that.city,_that.locationLat,_that.locationLng,_that.variableLocation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Spot extends Spot {
  const _Spot({required this.id, @JsonKey(name: 'association_id') required this.associationId, required this.name, this.description, this.address, this.city, @JsonKey(name: 'location_lat') this.locationLat, @JsonKey(name: 'location_lng') this.locationLng, @JsonKey(name: 'variable_location') this.variableLocation = false}): super._();
  factory _Spot.fromJson(Map<String, dynamic> json) => _$SpotFromJson(json);

@override final  String id;
@override@JsonKey(name: 'association_id') final  String associationId;
@override final  String name;
@override final  String? description;
@override final  String? address;
@override final  String? city;
@override@JsonKey(name: 'location_lat') final  double? locationLat;
@override@JsonKey(name: 'location_lng') final  double? locationLng;
@override@JsonKey(name: 'variable_location') final  bool variableLocation;

/// Create a copy of Spot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpotCopyWith<_Spot> get copyWith => __$SpotCopyWithImpl<_Spot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Spot&&(identical(other.id, id) || other.id == id)&&(identical(other.associationId, associationId) || other.associationId == associationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.locationLat, locationLat) || other.locationLat == locationLat)&&(identical(other.locationLng, locationLng) || other.locationLng == locationLng)&&(identical(other.variableLocation, variableLocation) || other.variableLocation == variableLocation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,associationId,name,description,address,city,locationLat,locationLng,variableLocation);
}

@override
String toString() {
    return 'Spot(id: $id, associationId: $associationId, name: $name, description: $description, address: $address, city: $city, locationLat: $locationLat, locationLng: $locationLng, variableLocation: $variableLocation)';
}


}

/// @nodoc
abstract mixin class _$SpotCopyWith<$Res> implements $SpotCopyWith<$Res> {
  factory _$SpotCopyWith(_Spot value, $Res Function(_Spot) _then) = __$SpotCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'association_id') String associationId, String name, String? description, String? address, String? city,@JsonKey(name: 'location_lat') double? locationLat,@JsonKey(name: 'location_lng') double? locationLng,@JsonKey(name: 'variable_location') bool variableLocation
});




}
/// @nodoc
class __$SpotCopyWithImpl<$Res>
    implements _$SpotCopyWith<$Res> {
  __$SpotCopyWithImpl(this._self, this._then);

  final _Spot _self;
  final $Res Function(_Spot) _then;

/// Create a copy of Spot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? associationId = null,Object? name = null,Object? description = freezed,Object? address = freezed,Object? city = freezed,Object? locationLat = freezed,Object? locationLng = freezed,Object? variableLocation = null,}) {
  return _then(_Spot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,associationId: null == associationId ? _self.associationId : associationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,locationLat: freezed == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double?,locationLng: freezed == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double?,variableLocation: null == variableLocation ? _self.variableLocation : variableLocation // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
