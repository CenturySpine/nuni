// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Session {

 String get id; String get code;@JsonKey(name: 'owner_id') String get ownerId; SessionStatus get status; SessionKind get kind;@JsonKey(name: 'scoring_mode') ScoringMode get scoringMode;@JsonKey(name: 'ranking_direction') RankingDirection get rankingDirection; String? get city; String? get zone;@JsonKey(name: 'location_lat') double? get locationLat;@JsonKey(name: 'location_lng') double? get locationLng; Weather? get weather; String? get comment;@JsonKey(name: 'cover_photo_id') String? get coverPhotoId;@JsonKey(name: 'cover_photo_path') String? get coverPhotoPath;@JsonKey(name: 'association_id') String? get associationId;@JsonKey(name: 'is_championship') bool get isChampionship;@JsonKey(name: 'championship_season') String? get championshipSeason;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'started_at') DateTime? get startedAt;@JsonKey(name: 'ended_at') DateTime? get endedAt;
/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionCopyWith<Session> get copyWith => _$SessionCopyWithImpl<Session>(this as Session, _$identity);

  /// Serializes this Session to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Session;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Session&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.ownerId, _this.ownerId) || other.ownerId == _this.ownerId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.scoringMode, _this.scoringMode) || other.scoringMode == _this.scoringMode)&&(identical(other.rankingDirection, _this.rankingDirection) || other.rankingDirection == _this.rankingDirection)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.zone, _this.zone) || other.zone == _this.zone)&&(identical(other.locationLat, _this.locationLat) || other.locationLat == _this.locationLat)&&(identical(other.locationLng, _this.locationLng) || other.locationLng == _this.locationLng)&&(identical(other.weather, _this.weather) || other.weather == _this.weather)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.coverPhotoId, _this.coverPhotoId) || other.coverPhotoId == _this.coverPhotoId)&&(identical(other.coverPhotoPath, _this.coverPhotoPath) || other.coverPhotoPath == _this.coverPhotoPath)&&(identical(other.associationId, _this.associationId) || other.associationId == _this.associationId)&&(identical(other.isChampionship, _this.isChampionship) || other.isChampionship == _this.isChampionship)&&(identical(other.championshipSeason, _this.championshipSeason) || other.championshipSeason == _this.championshipSeason)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Session;
  return Object.hashAll([runtimeType,_this.id,_this.code,_this.ownerId,_this.status,_this.kind,_this.scoringMode,_this.rankingDirection,_this.city,_this.zone,_this.locationLat,_this.locationLng,_this.weather,_this.comment,_this.coverPhotoId,_this.coverPhotoPath,_this.associationId,_this.isChampionship,_this.championshipSeason,_this.createdAt,_this.startedAt,_this.endedAt]);
}

@override
String toString() {
  final _this = this as Session;
  return 'Session(id: ${_this.id}, code: ${_this.code}, ownerId: ${_this.ownerId}, status: ${_this.status}, kind: ${_this.kind}, scoringMode: ${_this.scoringMode}, rankingDirection: ${_this.rankingDirection}, city: ${_this.city}, zone: ${_this.zone}, locationLat: ${_this.locationLat}, locationLng: ${_this.locationLng}, weather: ${_this.weather}, comment: ${_this.comment}, coverPhotoId: ${_this.coverPhotoId}, coverPhotoPath: ${_this.coverPhotoPath}, associationId: ${_this.associationId}, isChampionship: ${_this.isChampionship}, championshipSeason: ${_this.championshipSeason}, createdAt: ${_this.createdAt}, startedAt: ${_this.startedAt}, endedAt: ${_this.endedAt})';
}


}

/// @nodoc
abstract mixin class $SessionCopyWith<$Res>  {
  factory $SessionCopyWith(Session value, $Res Function(Session) _then) = _$SessionCopyWithImpl;
@useResult
$Res call({
 String id, String code,@JsonKey(name: 'owner_id') String ownerId, SessionStatus status, SessionKind kind,@JsonKey(name: 'scoring_mode') ScoringMode scoringMode,@JsonKey(name: 'ranking_direction') RankingDirection rankingDirection, String? city, String? zone,@JsonKey(name: 'location_lat') double? locationLat,@JsonKey(name: 'location_lng') double? locationLng, Weather? weather, String? comment,@JsonKey(name: 'cover_photo_id') String? coverPhotoId,@JsonKey(name: 'cover_photo_path') String? coverPhotoPath,@JsonKey(name: 'association_id') String? associationId,@JsonKey(name: 'is_championship') bool isChampionship,@JsonKey(name: 'championship_season') String? championshipSeason,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'started_at') DateTime? startedAt,@JsonKey(name: 'ended_at') DateTime? endedAt
});


$WeatherCopyWith<$Res>? get weather;

}
/// @nodoc
class _$SessionCopyWithImpl<$Res>
    implements $SessionCopyWith<$Res> {
  _$SessionCopyWithImpl(this._self, this._then);

  final Session _self;
  final $Res Function(Session) _then;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? ownerId = null,Object? status = null,Object? kind = null,Object? scoringMode = null,Object? rankingDirection = null,Object? city = freezed,Object? zone = freezed,Object? locationLat = freezed,Object? locationLng = freezed,Object? weather = freezed,Object? comment = freezed,Object? coverPhotoId = freezed,Object? coverPhotoPath = freezed,Object? associationId = freezed,Object? isChampionship = null,Object? championshipSeason = freezed,Object? createdAt = null,Object? startedAt = freezed,Object? endedAt = freezed,}) {
  return _then(Session(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SessionStatus,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SessionKind,scoringMode: null == scoringMode ? _self.scoringMode : scoringMode // ignore: cast_nullable_to_non_nullable
as ScoringMode,rankingDirection: null == rankingDirection ? _self.rankingDirection : rankingDirection // ignore: cast_nullable_to_non_nullable
as RankingDirection,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,locationLat: freezed == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double?,locationLng: freezed == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double?,weather: freezed == weather ? _self.weather : weather // ignore: cast_nullable_to_non_nullable
as Weather?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,coverPhotoId: freezed == coverPhotoId ? _self.coverPhotoId : coverPhotoId // ignore: cast_nullable_to_non_nullable
as String?,coverPhotoPath: freezed == coverPhotoPath ? _self.coverPhotoPath : coverPhotoPath // ignore: cast_nullable_to_non_nullable
as String?,associationId: freezed == associationId ? _self.associationId : associationId // ignore: cast_nullable_to_non_nullable
as String?,isChampionship: null == isChampionship ? _self.isChampionship : isChampionship // ignore: cast_nullable_to_non_nullable
as bool,championshipSeason: freezed == championshipSeason ? _self.championshipSeason : championshipSeason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeatherCopyWith<$Res>? get weather {
    if (_self.weather == null) {
    return null;
  }

  return $WeatherCopyWith<$Res>(_self.weather!, (value) {
    return _then(_self.copyWith(weather: value));
  });
}
}


/// Adds pattern-matching-related methods to [Session].
extension SessionPatterns on Session {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Session value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Session() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Session value)  $default,){
final _that = this;
switch (_that) {
case _Session():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Session value)?  $default,){
final _that = this;
switch (_that) {
case _Session() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code, @JsonKey(name: 'owner_id')  String ownerId,  SessionStatus status,  SessionKind kind, @JsonKey(name: 'scoring_mode')  ScoringMode scoringMode, @JsonKey(name: 'ranking_direction')  RankingDirection rankingDirection,  String? city,  String? zone, @JsonKey(name: 'location_lat')  double? locationLat, @JsonKey(name: 'location_lng')  double? locationLng,  Weather? weather,  String? comment, @JsonKey(name: 'cover_photo_id')  String? coverPhotoId, @JsonKey(name: 'cover_photo_path')  String? coverPhotoPath, @JsonKey(name: 'association_id')  String? associationId, @JsonKey(name: 'is_championship')  bool isChampionship, @JsonKey(name: 'championship_season')  String? championshipSeason, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'started_at')  DateTime? startedAt, @JsonKey(name: 'ended_at')  DateTime? endedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that.id,_that.code,_that.ownerId,_that.status,_that.kind,_that.scoringMode,_that.rankingDirection,_that.city,_that.zone,_that.locationLat,_that.locationLng,_that.weather,_that.comment,_that.coverPhotoId,_that.coverPhotoPath,_that.associationId,_that.isChampionship,_that.championshipSeason,_that.createdAt,_that.startedAt,_that.endedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code, @JsonKey(name: 'owner_id')  String ownerId,  SessionStatus status,  SessionKind kind, @JsonKey(name: 'scoring_mode')  ScoringMode scoringMode, @JsonKey(name: 'ranking_direction')  RankingDirection rankingDirection,  String? city,  String? zone, @JsonKey(name: 'location_lat')  double? locationLat, @JsonKey(name: 'location_lng')  double? locationLng,  Weather? weather,  String? comment, @JsonKey(name: 'cover_photo_id')  String? coverPhotoId, @JsonKey(name: 'cover_photo_path')  String? coverPhotoPath, @JsonKey(name: 'association_id')  String? associationId, @JsonKey(name: 'is_championship')  bool isChampionship, @JsonKey(name: 'championship_season')  String? championshipSeason, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'started_at')  DateTime? startedAt, @JsonKey(name: 'ended_at')  DateTime? endedAt)  $default,) {final _that = this;
switch (_that) {
case _Session():
return $default(_that.id,_that.code,_that.ownerId,_that.status,_that.kind,_that.scoringMode,_that.rankingDirection,_that.city,_that.zone,_that.locationLat,_that.locationLng,_that.weather,_that.comment,_that.coverPhotoId,_that.coverPhotoPath,_that.associationId,_that.isChampionship,_that.championshipSeason,_that.createdAt,_that.startedAt,_that.endedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code, @JsonKey(name: 'owner_id')  String ownerId,  SessionStatus status,  SessionKind kind, @JsonKey(name: 'scoring_mode')  ScoringMode scoringMode, @JsonKey(name: 'ranking_direction')  RankingDirection rankingDirection,  String? city,  String? zone, @JsonKey(name: 'location_lat')  double? locationLat, @JsonKey(name: 'location_lng')  double? locationLng,  Weather? weather,  String? comment, @JsonKey(name: 'cover_photo_id')  String? coverPhotoId, @JsonKey(name: 'cover_photo_path')  String? coverPhotoPath, @JsonKey(name: 'association_id')  String? associationId, @JsonKey(name: 'is_championship')  bool isChampionship, @JsonKey(name: 'championship_season')  String? championshipSeason, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'started_at')  DateTime? startedAt, @JsonKey(name: 'ended_at')  DateTime? endedAt)?  $default,) {final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that.id,_that.code,_that.ownerId,_that.status,_that.kind,_that.scoringMode,_that.rankingDirection,_that.city,_that.zone,_that.locationLat,_that.locationLng,_that.weather,_that.comment,_that.coverPhotoId,_that.coverPhotoPath,_that.associationId,_that.isChampionship,_that.championshipSeason,_that.createdAt,_that.startedAt,_that.endedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Session implements Session {
  const _Session({required this.id, required this.code, @JsonKey(name: 'owner_id') required this.ownerId, required this.status, required this.kind, @JsonKey(name: 'scoring_mode') required this.scoringMode, @JsonKey(name: 'ranking_direction') required this.rankingDirection, this.city, this.zone, @JsonKey(name: 'location_lat') this.locationLat, @JsonKey(name: 'location_lng') this.locationLng, this.weather, this.comment, @JsonKey(name: 'cover_photo_id') this.coverPhotoId, @JsonKey(name: 'cover_photo_path') this.coverPhotoPath, @JsonKey(name: 'association_id') this.associationId, @JsonKey(name: 'is_championship') this.isChampionship = false, @JsonKey(name: 'championship_season') this.championshipSeason, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'started_at') this.startedAt, @JsonKey(name: 'ended_at') this.endedAt});
  factory _Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);

@override final  String id;
@override final  String code;
@override@JsonKey(name: 'owner_id') final  String ownerId;
@override final  SessionStatus status;
@override final  SessionKind kind;
@override@JsonKey(name: 'scoring_mode') final  ScoringMode scoringMode;
@override@JsonKey(name: 'ranking_direction') final  RankingDirection rankingDirection;
@override final  String? city;
@override final  String? zone;
@override@JsonKey(name: 'location_lat') final  double? locationLat;
@override@JsonKey(name: 'location_lng') final  double? locationLng;
@override final  Weather? weather;
@override final  String? comment;
@override@JsonKey(name: 'cover_photo_id') final  String? coverPhotoId;
@override@JsonKey(name: 'cover_photo_path') final  String? coverPhotoPath;
@override@JsonKey(name: 'association_id') final  String? associationId;
@override@JsonKey(name: 'is_championship') final  bool isChampionship;
@override@JsonKey(name: 'championship_season') final  String? championshipSeason;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'started_at') final  DateTime? startedAt;
@override@JsonKey(name: 'ended_at') final  DateTime? endedAt;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionCopyWith<_Session> get copyWith => __$SessionCopyWithImpl<_Session>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Session&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.status, status) || other.status == status)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.scoringMode, scoringMode) || other.scoringMode == scoringMode)&&(identical(other.rankingDirection, rankingDirection) || other.rankingDirection == rankingDirection)&&(identical(other.city, city) || other.city == city)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.locationLat, locationLat) || other.locationLat == locationLat)&&(identical(other.locationLng, locationLng) || other.locationLng == locationLng)&&(identical(other.weather, weather) || other.weather == weather)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.coverPhotoId, coverPhotoId) || other.coverPhotoId == coverPhotoId)&&(identical(other.coverPhotoPath, coverPhotoPath) || other.coverPhotoPath == coverPhotoPath)&&(identical(other.associationId, associationId) || other.associationId == associationId)&&(identical(other.isChampionship, isChampionship) || other.isChampionship == isChampionship)&&(identical(other.championshipSeason, championshipSeason) || other.championshipSeason == championshipSeason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,code,ownerId,status,kind,scoringMode,rankingDirection,city,zone,locationLat,locationLng,weather,comment,coverPhotoId,coverPhotoPath,associationId,isChampionship,championshipSeason,createdAt,startedAt,endedAt]);
}

@override
String toString() {
    return 'Session(id: $id, code: $code, ownerId: $ownerId, status: $status, kind: $kind, scoringMode: $scoringMode, rankingDirection: $rankingDirection, city: $city, zone: $zone, locationLat: $locationLat, locationLng: $locationLng, weather: $weather, comment: $comment, coverPhotoId: $coverPhotoId, coverPhotoPath: $coverPhotoPath, associationId: $associationId, isChampionship: $isChampionship, championshipSeason: $championshipSeason, createdAt: $createdAt, startedAt: $startedAt, endedAt: $endedAt)';
}


}

/// @nodoc
abstract mixin class _$SessionCopyWith<$Res> implements $SessionCopyWith<$Res> {
  factory _$SessionCopyWith(_Session value, $Res Function(_Session) _then) = __$SessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String code,@JsonKey(name: 'owner_id') String ownerId, SessionStatus status, SessionKind kind,@JsonKey(name: 'scoring_mode') ScoringMode scoringMode,@JsonKey(name: 'ranking_direction') RankingDirection rankingDirection, String? city, String? zone,@JsonKey(name: 'location_lat') double? locationLat,@JsonKey(name: 'location_lng') double? locationLng, Weather? weather, String? comment,@JsonKey(name: 'cover_photo_id') String? coverPhotoId,@JsonKey(name: 'cover_photo_path') String? coverPhotoPath,@JsonKey(name: 'association_id') String? associationId,@JsonKey(name: 'is_championship') bool isChampionship,@JsonKey(name: 'championship_season') String? championshipSeason,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'started_at') DateTime? startedAt,@JsonKey(name: 'ended_at') DateTime? endedAt
});


@override $WeatherCopyWith<$Res>? get weather;

}
/// @nodoc
class __$SessionCopyWithImpl<$Res>
    implements _$SessionCopyWith<$Res> {
  __$SessionCopyWithImpl(this._self, this._then);

  final _Session _self;
  final $Res Function(_Session) _then;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? ownerId = null,Object? status = null,Object? kind = null,Object? scoringMode = null,Object? rankingDirection = null,Object? city = freezed,Object? zone = freezed,Object? locationLat = freezed,Object? locationLng = freezed,Object? weather = freezed,Object? comment = freezed,Object? coverPhotoId = freezed,Object? coverPhotoPath = freezed,Object? associationId = freezed,Object? isChampionship = null,Object? championshipSeason = freezed,Object? createdAt = null,Object? startedAt = freezed,Object? endedAt = freezed,}) {
  return _then(_Session(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SessionStatus,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SessionKind,scoringMode: null == scoringMode ? _self.scoringMode : scoringMode // ignore: cast_nullable_to_non_nullable
as ScoringMode,rankingDirection: null == rankingDirection ? _self.rankingDirection : rankingDirection // ignore: cast_nullable_to_non_nullable
as RankingDirection,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,locationLat: freezed == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double?,locationLng: freezed == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double?,weather: freezed == weather ? _self.weather : weather // ignore: cast_nullable_to_non_nullable
as Weather?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,coverPhotoId: freezed == coverPhotoId ? _self.coverPhotoId : coverPhotoId // ignore: cast_nullable_to_non_nullable
as String?,coverPhotoPath: freezed == coverPhotoPath ? _self.coverPhotoPath : coverPhotoPath // ignore: cast_nullable_to_non_nullable
as String?,associationId: freezed == associationId ? _self.associationId : associationId // ignore: cast_nullable_to_non_nullable
as String?,isChampionship: null == isChampionship ? _self.isChampionship : isChampionship // ignore: cast_nullable_to_non_nullable
as bool,championshipSeason: freezed == championshipSeason ? _self.championshipSeason : championshipSeason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeatherCopyWith<$Res>? get weather {
    if (_self.weather == null) {
    return null;
  }

  return $WeatherCopyWith<$Res>(_self.weather!, (value) {
    return _then(_self.copyWith(weather: value));
  });
}
}

// dart format on
