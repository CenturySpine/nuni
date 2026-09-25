// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'association.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Association {

 String get id; String get name;@JsonKey(name: 'short_name') String? get shortName; String get city;@JsonKey(name: 'location_lat') double get locationLat;@JsonKey(name: 'location_lng') double get locationLng;@JsonKey(name: 'website_url') String? get websiteUrl;@JsonKey(name: 'logo_path') String? get logoPath; List<AssociationPartner> get partners; AssociationStatus get status;@JsonKey(name: 'created_by') String? get createdBy;
/// Create a copy of Association
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssociationCopyWith<Association> get copyWith => _$AssociationCopyWithImpl<Association>(this as Association, _$identity);

  /// Serializes this Association to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Association;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Association&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.shortName, _this.shortName) || other.shortName == _this.shortName)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.locationLat, _this.locationLat) || other.locationLat == _this.locationLat)&&(identical(other.locationLng, _this.locationLng) || other.locationLng == _this.locationLng)&&(identical(other.websiteUrl, _this.websiteUrl) || other.websiteUrl == _this.websiteUrl)&&(identical(other.logoPath, _this.logoPath) || other.logoPath == _this.logoPath)&&const DeepCollectionEquality().equals(other.partners, _this.partners)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Association;
  return Object.hash(runtimeType,_this.id,_this.name,_this.shortName,_this.city,_this.locationLat,_this.locationLng,_this.websiteUrl,_this.logoPath,const DeepCollectionEquality().hash(_this.partners),_this.status,_this.createdBy);
}

@override
String toString() {
  final _this = this as Association;
  return 'Association(id: ${_this.id}, name: ${_this.name}, shortName: ${_this.shortName}, city: ${_this.city}, locationLat: ${_this.locationLat}, locationLng: ${_this.locationLng}, websiteUrl: ${_this.websiteUrl}, logoPath: ${_this.logoPath}, partners: ${_this.partners}, status: ${_this.status}, createdBy: ${_this.createdBy})';
}


}

/// @nodoc
abstract mixin class $AssociationCopyWith<$Res>  {
  factory $AssociationCopyWith(Association value, $Res Function(Association) _then) = _$AssociationCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'short_name') String? shortName, String city,@JsonKey(name: 'location_lat') double locationLat,@JsonKey(name: 'location_lng') double locationLng,@JsonKey(name: 'website_url') String? websiteUrl,@JsonKey(name: 'logo_path') String? logoPath, List<AssociationPartner> partners, AssociationStatus status,@JsonKey(name: 'created_by') String? createdBy
});




}
/// @nodoc
class _$AssociationCopyWithImpl<$Res>
    implements $AssociationCopyWith<$Res> {
  _$AssociationCopyWithImpl(this._self, this._then);

  final Association _self;
  final $Res Function(Association) _then;

/// Create a copy of Association
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? shortName = freezed,Object? city = null,Object? locationLat = null,Object? locationLng = null,Object? websiteUrl = freezed,Object? logoPath = freezed,Object? partners = null,Object? status = null,Object? createdBy = freezed,}) {
  return _then(Association(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,locationLat: null == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double,locationLng: null == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double,websiteUrl: freezed == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String?,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,partners: null == partners ? _self.partners : partners // ignore: cast_nullable_to_non_nullable
as List<AssociationPartner>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AssociationStatus,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Association].
extension AssociationPatterns on Association {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Association value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Association() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Association value)  $default,){
final _that = this;
switch (_that) {
case _Association():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Association value)?  $default,){
final _that = this;
switch (_that) {
case _Association() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'short_name')  String? shortName,  String city, @JsonKey(name: 'location_lat')  double locationLat, @JsonKey(name: 'location_lng')  double locationLng, @JsonKey(name: 'website_url')  String? websiteUrl, @JsonKey(name: 'logo_path')  String? logoPath,  List<AssociationPartner> partners,  AssociationStatus status, @JsonKey(name: 'created_by')  String? createdBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Association() when $default != null:
return $default(_that.id,_that.name,_that.shortName,_that.city,_that.locationLat,_that.locationLng,_that.websiteUrl,_that.logoPath,_that.partners,_that.status,_that.createdBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'short_name')  String? shortName,  String city, @JsonKey(name: 'location_lat')  double locationLat, @JsonKey(name: 'location_lng')  double locationLng, @JsonKey(name: 'website_url')  String? websiteUrl, @JsonKey(name: 'logo_path')  String? logoPath,  List<AssociationPartner> partners,  AssociationStatus status, @JsonKey(name: 'created_by')  String? createdBy)  $default,) {final _that = this;
switch (_that) {
case _Association():
return $default(_that.id,_that.name,_that.shortName,_that.city,_that.locationLat,_that.locationLng,_that.websiteUrl,_that.logoPath,_that.partners,_that.status,_that.createdBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'short_name')  String? shortName,  String city, @JsonKey(name: 'location_lat')  double locationLat, @JsonKey(name: 'location_lng')  double locationLng, @JsonKey(name: 'website_url')  String? websiteUrl, @JsonKey(name: 'logo_path')  String? logoPath,  List<AssociationPartner> partners,  AssociationStatus status, @JsonKey(name: 'created_by')  String? createdBy)?  $default,) {final _that = this;
switch (_that) {
case _Association() when $default != null:
return $default(_that.id,_that.name,_that.shortName,_that.city,_that.locationLat,_that.locationLng,_that.websiteUrl,_that.logoPath,_that.partners,_that.status,_that.createdBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Association extends Association {
  const _Association({required this.id, required this.name, @JsonKey(name: 'short_name') this.shortName, required this.city, @JsonKey(name: 'location_lat') required this.locationLat, @JsonKey(name: 'location_lng') required this.locationLng, @JsonKey(name: 'website_url') this.websiteUrl, @JsonKey(name: 'logo_path') this.logoPath,  List<AssociationPartner> partners = const <AssociationPartner>[], required this.status, @JsonKey(name: 'created_by') this.createdBy}): _partners = partners,super._();
  factory _Association.fromJson(Map<String, dynamic> json) => _$AssociationFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'short_name') final  String? shortName;
@override final  String city;
@override@JsonKey(name: 'location_lat') final  double locationLat;
@override@JsonKey(name: 'location_lng') final  double locationLng;
@override@JsonKey(name: 'website_url') final  String? websiteUrl;
@override@JsonKey(name: 'logo_path') final  String? logoPath;
 final  List<AssociationPartner> _partners;
@override@JsonKey() List<AssociationPartner> get partners {
  if (_partners is EqualUnmodifiableListView) return _partners;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_partners);
}

@override final  AssociationStatus status;
@override@JsonKey(name: 'created_by') final  String? createdBy;

/// Create a copy of Association
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssociationCopyWith<_Association> get copyWith => __$AssociationCopyWithImpl<_Association>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssociationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Association&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.city, city) || other.city == city)&&(identical(other.locationLat, locationLat) || other.locationLat == locationLat)&&(identical(other.locationLng, locationLng) || other.locationLng == locationLng)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath)&&const DeepCollectionEquality().equals(other.partners, _partners)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,shortName,city,locationLat,locationLng,websiteUrl,logoPath,const DeepCollectionEquality().hash(_partners),status,createdBy);
}

@override
String toString() {
    return 'Association(id: $id, name: $name, shortName: $shortName, city: $city, locationLat: $locationLat, locationLng: $locationLng, websiteUrl: $websiteUrl, logoPath: $logoPath, partners: $partners, status: $status, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class _$AssociationCopyWith<$Res> implements $AssociationCopyWith<$Res> {
  factory _$AssociationCopyWith(_Association value, $Res Function(_Association) _then) = __$AssociationCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'short_name') String? shortName, String city,@JsonKey(name: 'location_lat') double locationLat,@JsonKey(name: 'location_lng') double locationLng,@JsonKey(name: 'website_url') String? websiteUrl,@JsonKey(name: 'logo_path') String? logoPath, List<AssociationPartner> partners, AssociationStatus status,@JsonKey(name: 'created_by') String? createdBy
});




}
/// @nodoc
class __$AssociationCopyWithImpl<$Res>
    implements _$AssociationCopyWith<$Res> {
  __$AssociationCopyWithImpl(this._self, this._then);

  final _Association _self;
  final $Res Function(_Association) _then;

/// Create a copy of Association
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? shortName = freezed,Object? city = null,Object? locationLat = null,Object? locationLng = null,Object? websiteUrl = freezed,Object? logoPath = freezed,Object? partners = null,Object? status = null,Object? createdBy = freezed,}) {
  return _then(_Association(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,locationLat: null == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double,locationLng: null == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double,websiteUrl: freezed == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String?,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,partners: null == partners ? _self._partners : partners // ignore: cast_nullable_to_non_nullable
as List<AssociationPartner>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AssociationStatus,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AssociationPartner {

 String get label; String? get url;
/// Create a copy of AssociationPartner
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssociationPartnerCopyWith<AssociationPartner> get copyWith => _$AssociationPartnerCopyWithImpl<AssociationPartner>(this as AssociationPartner, _$identity);

  /// Serializes this AssociationPartner to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AssociationPartner;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssociationPartner&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AssociationPartner;
  return Object.hash(runtimeType,_this.label,_this.url);
}

@override
String toString() {
  final _this = this as AssociationPartner;
  return 'AssociationPartner(label: ${_this.label}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $AssociationPartnerCopyWith<$Res>  {
  factory $AssociationPartnerCopyWith(AssociationPartner value, $Res Function(AssociationPartner) _then) = _$AssociationPartnerCopyWithImpl;
@useResult
$Res call({
 String label, String? url
});




}
/// @nodoc
class _$AssociationPartnerCopyWithImpl<$Res>
    implements $AssociationPartnerCopyWith<$Res> {
  _$AssociationPartnerCopyWithImpl(this._self, this._then);

  final AssociationPartner _self;
  final $Res Function(AssociationPartner) _then;

/// Create a copy of AssociationPartner
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? url = freezed,}) {
  return _then(AssociationPartner(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AssociationPartner].
extension AssociationPartnerPatterns on AssociationPartner {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssociationPartner value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssociationPartner() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssociationPartner value)  $default,){
final _that = this;
switch (_that) {
case _AssociationPartner():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssociationPartner value)?  $default,){
final _that = this;
switch (_that) {
case _AssociationPartner() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String? url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssociationPartner() when $default != null:
return $default(_that.label,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String? url)  $default,) {final _that = this;
switch (_that) {
case _AssociationPartner():
return $default(_that.label,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String? url)?  $default,) {final _that = this;
switch (_that) {
case _AssociationPartner() when $default != null:
return $default(_that.label,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssociationPartner implements AssociationPartner {
  const _AssociationPartner({required this.label, this.url});
  factory _AssociationPartner.fromJson(Map<String, dynamic> json) => _$AssociationPartnerFromJson(json);

@override final  String label;
@override final  String? url;

/// Create a copy of AssociationPartner
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssociationPartnerCopyWith<_AssociationPartner> get copyWith => __$AssociationPartnerCopyWithImpl<_AssociationPartner>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssociationPartnerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssociationPartner&&(identical(other.label, label) || other.label == label)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,label,url);
}

@override
String toString() {
    return 'AssociationPartner(label: $label, url: $url)';
}


}

/// @nodoc
abstract mixin class _$AssociationPartnerCopyWith<$Res> implements $AssociationPartnerCopyWith<$Res> {
  factory _$AssociationPartnerCopyWith(_AssociationPartner value, $Res Function(_AssociationPartner) _then) = __$AssociationPartnerCopyWithImpl;
@override @useResult
$Res call({
 String label, String? url
});




}
/// @nodoc
class __$AssociationPartnerCopyWithImpl<$Res>
    implements _$AssociationPartnerCopyWith<$Res> {
  __$AssociationPartnerCopyWithImpl(this._self, this._then);

  final _AssociationPartner _self;
  final $Res Function(_AssociationPartner) _then;

/// Create a copy of AssociationPartner
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? url = freezed,}) {
  return _then(_AssociationPartner(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AssociationManager {

 String get id;@JsonKey(name: 'association_id') String get associationId;@JsonKey(name: 'user_id') String get userId; AssociationManagerStatus get status;@JsonKey(name: 'requested_at') DateTime get requestedAt;
/// Create a copy of AssociationManager
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssociationManagerCopyWith<AssociationManager> get copyWith => _$AssociationManagerCopyWithImpl<AssociationManager>(this as AssociationManager, _$identity);

  /// Serializes this AssociationManager to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AssociationManager;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssociationManager&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.associationId, _this.associationId) || other.associationId == _this.associationId)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.requestedAt, _this.requestedAt) || other.requestedAt == _this.requestedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AssociationManager;
  return Object.hash(runtimeType,_this.id,_this.associationId,_this.userId,_this.status,_this.requestedAt);
}

@override
String toString() {
  final _this = this as AssociationManager;
  return 'AssociationManager(id: ${_this.id}, associationId: ${_this.associationId}, userId: ${_this.userId}, status: ${_this.status}, requestedAt: ${_this.requestedAt})';
}


}

/// @nodoc
abstract mixin class $AssociationManagerCopyWith<$Res>  {
  factory $AssociationManagerCopyWith(AssociationManager value, $Res Function(AssociationManager) _then) = _$AssociationManagerCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'association_id') String associationId,@JsonKey(name: 'user_id') String userId, AssociationManagerStatus status,@JsonKey(name: 'requested_at') DateTime requestedAt
});




}
/// @nodoc
class _$AssociationManagerCopyWithImpl<$Res>
    implements $AssociationManagerCopyWith<$Res> {
  _$AssociationManagerCopyWithImpl(this._self, this._then);

  final AssociationManager _self;
  final $Res Function(AssociationManager) _then;

/// Create a copy of AssociationManager
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? associationId = null,Object? userId = null,Object? status = null,Object? requestedAt = null,}) {
  return _then(AssociationManager(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,associationId: null == associationId ? _self.associationId : associationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AssociationManagerStatus,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AssociationManager].
extension AssociationManagerPatterns on AssociationManager {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssociationManager value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssociationManager() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssociationManager value)  $default,){
final _that = this;
switch (_that) {
case _AssociationManager():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssociationManager value)?  $default,){
final _that = this;
switch (_that) {
case _AssociationManager() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'association_id')  String associationId, @JsonKey(name: 'user_id')  String userId,  AssociationManagerStatus status, @JsonKey(name: 'requested_at')  DateTime requestedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssociationManager() when $default != null:
return $default(_that.id,_that.associationId,_that.userId,_that.status,_that.requestedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'association_id')  String associationId, @JsonKey(name: 'user_id')  String userId,  AssociationManagerStatus status, @JsonKey(name: 'requested_at')  DateTime requestedAt)  $default,) {final _that = this;
switch (_that) {
case _AssociationManager():
return $default(_that.id,_that.associationId,_that.userId,_that.status,_that.requestedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'association_id')  String associationId, @JsonKey(name: 'user_id')  String userId,  AssociationManagerStatus status, @JsonKey(name: 'requested_at')  DateTime requestedAt)?  $default,) {final _that = this;
switch (_that) {
case _AssociationManager() when $default != null:
return $default(_that.id,_that.associationId,_that.userId,_that.status,_that.requestedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssociationManager implements AssociationManager {
  const _AssociationManager({required this.id, @JsonKey(name: 'association_id') required this.associationId, @JsonKey(name: 'user_id') required this.userId, required this.status, @JsonKey(name: 'requested_at') required this.requestedAt});
  factory _AssociationManager.fromJson(Map<String, dynamic> json) => _$AssociationManagerFromJson(json);

@override final  String id;
@override@JsonKey(name: 'association_id') final  String associationId;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  AssociationManagerStatus status;
@override@JsonKey(name: 'requested_at') final  DateTime requestedAt;

/// Create a copy of AssociationManager
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssociationManagerCopyWith<_AssociationManager> get copyWith => __$AssociationManagerCopyWithImpl<_AssociationManager>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssociationManagerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssociationManager&&(identical(other.id, id) || other.id == id)&&(identical(other.associationId, associationId) || other.associationId == associationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,associationId,userId,status,requestedAt);
}

@override
String toString() {
    return 'AssociationManager(id: $id, associationId: $associationId, userId: $userId, status: $status, requestedAt: $requestedAt)';
}


}

/// @nodoc
abstract mixin class _$AssociationManagerCopyWith<$Res> implements $AssociationManagerCopyWith<$Res> {
  factory _$AssociationManagerCopyWith(_AssociationManager value, $Res Function(_AssociationManager) _then) = __$AssociationManagerCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'association_id') String associationId,@JsonKey(name: 'user_id') String userId, AssociationManagerStatus status,@JsonKey(name: 'requested_at') DateTime requestedAt
});




}
/// @nodoc
class __$AssociationManagerCopyWithImpl<$Res>
    implements _$AssociationManagerCopyWith<$Res> {
  __$AssociationManagerCopyWithImpl(this._self, this._then);

  final _AssociationManager _self;
  final $Res Function(_AssociationManager) _then;

/// Create a copy of AssociationManager
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? associationId = null,Object? userId = null,Object? status = null,Object? requestedAt = null,}) {
  return _then(_AssociationManager(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,associationId: null == associationId ? _self.associationId : associationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AssociationManagerStatus,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ManagerContact {

@JsonKey(name: 'manager_id') String get managerId; String get email; String get phone;@JsonKey(name: 'request_message') String? get requestMessage;
/// Create a copy of ManagerContact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManagerContactCopyWith<ManagerContact> get copyWith => _$ManagerContactCopyWithImpl<ManagerContact>(this as ManagerContact, _$identity);

  /// Serializes this ManagerContact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ManagerContact;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManagerContact&&(identical(other.managerId, _this.managerId) || other.managerId == _this.managerId)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.requestMessage, _this.requestMessage) || other.requestMessage == _this.requestMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ManagerContact;
  return Object.hash(runtimeType,_this.managerId,_this.email,_this.phone,_this.requestMessage);
}

@override
String toString() {
  final _this = this as ManagerContact;
  return 'ManagerContact(managerId: ${_this.managerId}, email: ${_this.email}, phone: ${_this.phone}, requestMessage: ${_this.requestMessage})';
}


}

/// @nodoc
abstract mixin class $ManagerContactCopyWith<$Res>  {
  factory $ManagerContactCopyWith(ManagerContact value, $Res Function(ManagerContact) _then) = _$ManagerContactCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'manager_id') String managerId, String email, String phone,@JsonKey(name: 'request_message') String? requestMessage
});




}
/// @nodoc
class _$ManagerContactCopyWithImpl<$Res>
    implements $ManagerContactCopyWith<$Res> {
  _$ManagerContactCopyWithImpl(this._self, this._then);

  final ManagerContact _self;
  final $Res Function(ManagerContact) _then;

/// Create a copy of ManagerContact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? managerId = null,Object? email = null,Object? phone = null,Object? requestMessage = freezed,}) {
  return _then(ManagerContact(
managerId: null == managerId ? _self.managerId : managerId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,requestMessage: freezed == requestMessage ? _self.requestMessage : requestMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ManagerContact].
extension ManagerContactPatterns on ManagerContact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManagerContact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManagerContact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManagerContact value)  $default,){
final _that = this;
switch (_that) {
case _ManagerContact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManagerContact value)?  $default,){
final _that = this;
switch (_that) {
case _ManagerContact() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'manager_id')  String managerId,  String email,  String phone, @JsonKey(name: 'request_message')  String? requestMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManagerContact() when $default != null:
return $default(_that.managerId,_that.email,_that.phone,_that.requestMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'manager_id')  String managerId,  String email,  String phone, @JsonKey(name: 'request_message')  String? requestMessage)  $default,) {final _that = this;
switch (_that) {
case _ManagerContact():
return $default(_that.managerId,_that.email,_that.phone,_that.requestMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'manager_id')  String managerId,  String email,  String phone, @JsonKey(name: 'request_message')  String? requestMessage)?  $default,) {final _that = this;
switch (_that) {
case _ManagerContact() when $default != null:
return $default(_that.managerId,_that.email,_that.phone,_that.requestMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ManagerContact implements ManagerContact {
  const _ManagerContact({@JsonKey(name: 'manager_id') required this.managerId, required this.email, required this.phone, @JsonKey(name: 'request_message') this.requestMessage});
  factory _ManagerContact.fromJson(Map<String, dynamic> json) => _$ManagerContactFromJson(json);

@override@JsonKey(name: 'manager_id') final  String managerId;
@override final  String email;
@override final  String phone;
@override@JsonKey(name: 'request_message') final  String? requestMessage;

/// Create a copy of ManagerContact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManagerContactCopyWith<_ManagerContact> get copyWith => __$ManagerContactCopyWithImpl<_ManagerContact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ManagerContactToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManagerContact&&(identical(other.managerId, managerId) || other.managerId == managerId)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.requestMessage, requestMessage) || other.requestMessage == requestMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,managerId,email,phone,requestMessage);
}

@override
String toString() {
    return 'ManagerContact(managerId: $managerId, email: $email, phone: $phone, requestMessage: $requestMessage)';
}


}

/// @nodoc
abstract mixin class _$ManagerContactCopyWith<$Res> implements $ManagerContactCopyWith<$Res> {
  factory _$ManagerContactCopyWith(_ManagerContact value, $Res Function(_ManagerContact) _then) = __$ManagerContactCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'manager_id') String managerId, String email, String phone,@JsonKey(name: 'request_message') String? requestMessage
});




}
/// @nodoc
class __$ManagerContactCopyWithImpl<$Res>
    implements _$ManagerContactCopyWith<$Res> {
  __$ManagerContactCopyWithImpl(this._self, this._then);

  final _ManagerContact _self;
  final $Res Function(_ManagerContact) _then;

/// Create a copy of ManagerContact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? managerId = null,Object? email = null,Object? phone = null,Object? requestMessage = freezed,}) {
  return _then(_ManagerContact(
managerId: null == managerId ? _self.managerId : managerId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,requestMessage: freezed == requestMessage ? _self.requestMessage : requestMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
