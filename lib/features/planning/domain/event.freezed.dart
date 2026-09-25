// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventAnswer {

@JsonKey(name: 'player_id') String get playerId; EventResponse get response;
/// Create a copy of EventAnswer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventAnswerCopyWith<EventAnswer> get copyWith => _$EventAnswerCopyWithImpl<EventAnswer>(this as EventAnswer, _$identity);

  /// Serializes this EventAnswer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EventAnswer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventAnswer&&(identical(other.playerId, _this.playerId) || other.playerId == _this.playerId)&&(identical(other.response, _this.response) || other.response == _this.response));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EventAnswer;
  return Object.hash(runtimeType,_this.playerId,_this.response);
}

@override
String toString() {
  final _this = this as EventAnswer;
  return 'EventAnswer(playerId: ${_this.playerId}, response: ${_this.response})';
}


}

/// @nodoc
abstract mixin class $EventAnswerCopyWith<$Res>  {
  factory $EventAnswerCopyWith(EventAnswer value, $Res Function(EventAnswer) _then) = _$EventAnswerCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'player_id') String playerId, EventResponse response
});




}
/// @nodoc
class _$EventAnswerCopyWithImpl<$Res>
    implements $EventAnswerCopyWith<$Res> {
  _$EventAnswerCopyWithImpl(this._self, this._then);

  final EventAnswer _self;
  final $Res Function(EventAnswer) _then;

/// Create a copy of EventAnswer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playerId = null,Object? response = null,}) {
  return _then(EventAnswer(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,response: null == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as EventResponse,
  ));
}

}


/// Adds pattern-matching-related methods to [EventAnswer].
extension EventAnswerPatterns on EventAnswer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventAnswer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventAnswer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventAnswer value)  $default,){
final _that = this;
switch (_that) {
case _EventAnswer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventAnswer value)?  $default,){
final _that = this;
switch (_that) {
case _EventAnswer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'player_id')  String playerId,  EventResponse response)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventAnswer() when $default != null:
return $default(_that.playerId,_that.response);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'player_id')  String playerId,  EventResponse response)  $default,) {final _that = this;
switch (_that) {
case _EventAnswer():
return $default(_that.playerId,_that.response);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'player_id')  String playerId,  EventResponse response)?  $default,) {final _that = this;
switch (_that) {
case _EventAnswer() when $default != null:
return $default(_that.playerId,_that.response);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventAnswer implements EventAnswer {
  const _EventAnswer({@JsonKey(name: 'player_id') required this.playerId, required this.response});
  factory _EventAnswer.fromJson(Map<String, dynamic> json) => _$EventAnswerFromJson(json);

@override@JsonKey(name: 'player_id') final  String playerId;
@override final  EventResponse response;

/// Create a copy of EventAnswer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventAnswerCopyWith<_EventAnswer> get copyWith => __$EventAnswerCopyWithImpl<_EventAnswer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventAnswerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventAnswer&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.response, response) || other.response == response));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,playerId,response);
}

@override
String toString() {
    return 'EventAnswer(playerId: $playerId, response: $response)';
}


}

/// @nodoc
abstract mixin class _$EventAnswerCopyWith<$Res> implements $EventAnswerCopyWith<$Res> {
  factory _$EventAnswerCopyWith(_EventAnswer value, $Res Function(_EventAnswer) _then) = __$EventAnswerCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'player_id') String playerId, EventResponse response
});




}
/// @nodoc
class __$EventAnswerCopyWithImpl<$Res>
    implements _$EventAnswerCopyWith<$Res> {
  __$EventAnswerCopyWithImpl(this._self, this._then);

  final _EventAnswer _self;
  final $Res Function(_EventAnswer) _then;

/// Create a copy of EventAnswer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playerId = null,Object? response = null,}) {
  return _then(_EventAnswer(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,response: null == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as EventResponse,
  ));
}


}


/// @nodoc
mixin _$Event {

 String get id;@JsonKey(name: 'association_id') String get associationId;@JsonKey(name: 'created_by') String get createdBy;@JsonKey(name: 'manager_player_id') String? get managerPlayerId;@JsonKey(name: 'starts_at') DateTime get startsAt; String get label; String? get spot;@JsonKey(name: 'spot_id') String? get spotId;@JsonKey(name: 'location_lat') double? get locationLat;@JsonKey(name: 'location_lng') double? get locationLng; String? get description; EventColor? get color; EventOrigin get origin;@JsonKey(name: 'event_responses') List<EventAnswer> get answers;@JsonKey(name: 'event_comments', readValue: _readCount) int get commentCount;
/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventCopyWith<Event> get copyWith => _$EventCopyWithImpl<Event>(this as Event, _$identity);

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Event;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Event&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.associationId, _this.associationId) || other.associationId == _this.associationId)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.managerPlayerId, _this.managerPlayerId) || other.managerPlayerId == _this.managerPlayerId)&&(identical(other.startsAt, _this.startsAt) || other.startsAt == _this.startsAt)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.spot, _this.spot) || other.spot == _this.spot)&&(identical(other.spotId, _this.spotId) || other.spotId == _this.spotId)&&(identical(other.locationLat, _this.locationLat) || other.locationLat == _this.locationLat)&&(identical(other.locationLng, _this.locationLng) || other.locationLng == _this.locationLng)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.origin, _this.origin) || other.origin == _this.origin)&&const DeepCollectionEquality().equals(other.answers, _this.answers)&&(identical(other.commentCount, _this.commentCount) || other.commentCount == _this.commentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Event;
  return Object.hash(runtimeType,_this.id,_this.associationId,_this.createdBy,_this.managerPlayerId,_this.startsAt,_this.label,_this.spot,_this.spotId,_this.locationLat,_this.locationLng,_this.description,_this.color,_this.origin,const DeepCollectionEquality().hash(_this.answers),_this.commentCount);
}

@override
String toString() {
  final _this = this as Event;
  return 'Event(id: ${_this.id}, associationId: ${_this.associationId}, createdBy: ${_this.createdBy}, managerPlayerId: ${_this.managerPlayerId}, startsAt: ${_this.startsAt}, label: ${_this.label}, spot: ${_this.spot}, spotId: ${_this.spotId}, locationLat: ${_this.locationLat}, locationLng: ${_this.locationLng}, description: ${_this.description}, color: ${_this.color}, origin: ${_this.origin}, answers: ${_this.answers}, commentCount: ${_this.commentCount})';
}


}

/// @nodoc
abstract mixin class $EventCopyWith<$Res>  {
  factory $EventCopyWith(Event value, $Res Function(Event) _then) = _$EventCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'association_id') String associationId,@JsonKey(name: 'created_by') String createdBy,@JsonKey(name: 'manager_player_id') String? managerPlayerId,@JsonKey(name: 'starts_at') DateTime startsAt, String label, String? spot,@JsonKey(name: 'spot_id') String? spotId,@JsonKey(name: 'location_lat') double? locationLat,@JsonKey(name: 'location_lng') double? locationLng, String? description, EventColor? color, EventOrigin origin,@JsonKey(name: 'event_responses') List<EventAnswer> answers,@JsonKey(name: 'event_comments', readValue: _readCount) int commentCount
});




}
/// @nodoc
class _$EventCopyWithImpl<$Res>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._self, this._then);

  final Event _self;
  final $Res Function(Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? associationId = null,Object? createdBy = null,Object? managerPlayerId = freezed,Object? startsAt = null,Object? label = null,Object? spot = freezed,Object? spotId = freezed,Object? locationLat = freezed,Object? locationLng = freezed,Object? description = freezed,Object? color = freezed,Object? origin = null,Object? answers = null,Object? commentCount = null,}) {
  return _then(Event(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,associationId: null == associationId ? _self.associationId : associationId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,managerPlayerId: freezed == managerPlayerId ? _self.managerPlayerId : managerPlayerId // ignore: cast_nullable_to_non_nullable
as String?,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,spot: freezed == spot ? _self.spot : spot // ignore: cast_nullable_to_non_nullable
as String?,spotId: freezed == spotId ? _self.spotId : spotId // ignore: cast_nullable_to_non_nullable
as String?,locationLat: freezed == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double?,locationLng: freezed == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as EventColor?,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as EventOrigin,answers: null == answers ? _self.answers : answers // ignore: cast_nullable_to_non_nullable
as List<EventAnswer>,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Event].
extension EventPatterns on Event {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Event value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Event() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Event value)  $default,){
final _that = this;
switch (_that) {
case _Event():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Event value)?  $default,){
final _that = this;
switch (_that) {
case _Event() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'association_id')  String associationId, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'manager_player_id')  String? managerPlayerId, @JsonKey(name: 'starts_at')  DateTime startsAt,  String label,  String? spot, @JsonKey(name: 'spot_id')  String? spotId, @JsonKey(name: 'location_lat')  double? locationLat, @JsonKey(name: 'location_lng')  double? locationLng,  String? description,  EventColor? color,  EventOrigin origin, @JsonKey(name: 'event_responses')  List<EventAnswer> answers, @JsonKey(name: 'event_comments', readValue: _readCount)  int commentCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.associationId,_that.createdBy,_that.managerPlayerId,_that.startsAt,_that.label,_that.spot,_that.spotId,_that.locationLat,_that.locationLng,_that.description,_that.color,_that.origin,_that.answers,_that.commentCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'association_id')  String associationId, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'manager_player_id')  String? managerPlayerId, @JsonKey(name: 'starts_at')  DateTime startsAt,  String label,  String? spot, @JsonKey(name: 'spot_id')  String? spotId, @JsonKey(name: 'location_lat')  double? locationLat, @JsonKey(name: 'location_lng')  double? locationLng,  String? description,  EventColor? color,  EventOrigin origin, @JsonKey(name: 'event_responses')  List<EventAnswer> answers, @JsonKey(name: 'event_comments', readValue: _readCount)  int commentCount)  $default,) {final _that = this;
switch (_that) {
case _Event():
return $default(_that.id,_that.associationId,_that.createdBy,_that.managerPlayerId,_that.startsAt,_that.label,_that.spot,_that.spotId,_that.locationLat,_that.locationLng,_that.description,_that.color,_that.origin,_that.answers,_that.commentCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'association_id')  String associationId, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'manager_player_id')  String? managerPlayerId, @JsonKey(name: 'starts_at')  DateTime startsAt,  String label,  String? spot, @JsonKey(name: 'spot_id')  String? spotId, @JsonKey(name: 'location_lat')  double? locationLat, @JsonKey(name: 'location_lng')  double? locationLng,  String? description,  EventColor? color,  EventOrigin origin, @JsonKey(name: 'event_responses')  List<EventAnswer> answers, @JsonKey(name: 'event_comments', readValue: _readCount)  int commentCount)?  $default,) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.associationId,_that.createdBy,_that.managerPlayerId,_that.startsAt,_that.label,_that.spot,_that.spotId,_that.locationLat,_that.locationLng,_that.description,_that.color,_that.origin,_that.answers,_that.commentCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Event extends Event {
  const _Event({required this.id, @JsonKey(name: 'association_id') required this.associationId, @JsonKey(name: 'created_by') required this.createdBy, @JsonKey(name: 'manager_player_id') this.managerPlayerId, @JsonKey(name: 'starts_at') required this.startsAt, required this.label, this.spot, @JsonKey(name: 'spot_id') this.spotId, @JsonKey(name: 'location_lat') this.locationLat, @JsonKey(name: 'location_lng') this.locationLng, this.description, this.color, this.origin = EventOrigin.manual, @JsonKey(name: 'event_responses')  List<EventAnswer> answers = const [], @JsonKey(name: 'event_comments', readValue: _readCount) this.commentCount = 0}): _answers = answers,super._();
  factory _Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

@override final  String id;
@override@JsonKey(name: 'association_id') final  String associationId;
@override@JsonKey(name: 'created_by') final  String createdBy;
@override@JsonKey(name: 'manager_player_id') final  String? managerPlayerId;
@override@JsonKey(name: 'starts_at') final  DateTime startsAt;
@override final  String label;
@override final  String? spot;
@override@JsonKey(name: 'spot_id') final  String? spotId;
@override@JsonKey(name: 'location_lat') final  double? locationLat;
@override@JsonKey(name: 'location_lng') final  double? locationLng;
@override final  String? description;
@override final  EventColor? color;
@override@JsonKey() final  EventOrigin origin;
 final  List<EventAnswer> _answers;
@override@JsonKey(name: 'event_responses') List<EventAnswer> get answers {
  if (_answers is EqualUnmodifiableListView) return _answers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_answers);
}

@override@JsonKey(name: 'event_comments', readValue: _readCount) final  int commentCount;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventCopyWith<_Event> get copyWith => __$EventCopyWithImpl<_Event>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Event&&(identical(other.id, id) || other.id == id)&&(identical(other.associationId, associationId) || other.associationId == associationId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.managerPlayerId, managerPlayerId) || other.managerPlayerId == managerPlayerId)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.label, label) || other.label == label)&&(identical(other.spot, spot) || other.spot == spot)&&(identical(other.spotId, spotId) || other.spotId == spotId)&&(identical(other.locationLat, locationLat) || other.locationLat == locationLat)&&(identical(other.locationLng, locationLng) || other.locationLng == locationLng)&&(identical(other.description, description) || other.description == description)&&(identical(other.color, color) || other.color == color)&&(identical(other.origin, origin) || other.origin == origin)&&const DeepCollectionEquality().equals(other.answers, _answers)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,associationId,createdBy,managerPlayerId,startsAt,label,spot,spotId,locationLat,locationLng,description,color,origin,const DeepCollectionEquality().hash(_answers),commentCount);
}

@override
String toString() {
    return 'Event(id: $id, associationId: $associationId, createdBy: $createdBy, managerPlayerId: $managerPlayerId, startsAt: $startsAt, label: $label, spot: $spot, spotId: $spotId, locationLat: $locationLat, locationLng: $locationLng, description: $description, color: $color, origin: $origin, answers: $answers, commentCount: $commentCount)';
}


}

/// @nodoc
abstract mixin class _$EventCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$EventCopyWith(_Event value, $Res Function(_Event) _then) = __$EventCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'association_id') String associationId,@JsonKey(name: 'created_by') String createdBy,@JsonKey(name: 'manager_player_id') String? managerPlayerId,@JsonKey(name: 'starts_at') DateTime startsAt, String label, String? spot,@JsonKey(name: 'spot_id') String? spotId,@JsonKey(name: 'location_lat') double? locationLat,@JsonKey(name: 'location_lng') double? locationLng, String? description, EventColor? color, EventOrigin origin,@JsonKey(name: 'event_responses') List<EventAnswer> answers,@JsonKey(name: 'event_comments', readValue: _readCount) int commentCount
});




}
/// @nodoc
class __$EventCopyWithImpl<$Res>
    implements _$EventCopyWith<$Res> {
  __$EventCopyWithImpl(this._self, this._then);

  final _Event _self;
  final $Res Function(_Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? associationId = null,Object? createdBy = null,Object? managerPlayerId = freezed,Object? startsAt = null,Object? label = null,Object? spot = freezed,Object? spotId = freezed,Object? locationLat = freezed,Object? locationLng = freezed,Object? description = freezed,Object? color = freezed,Object? origin = null,Object? answers = null,Object? commentCount = null,}) {
  return _then(_Event(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,associationId: null == associationId ? _self.associationId : associationId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,managerPlayerId: freezed == managerPlayerId ? _self.managerPlayerId : managerPlayerId // ignore: cast_nullable_to_non_nullable
as String?,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,spot: freezed == spot ? _self.spot : spot // ignore: cast_nullable_to_non_nullable
as String?,spotId: freezed == spotId ? _self.spotId : spotId // ignore: cast_nullable_to_non_nullable
as String?,locationLat: freezed == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double?,locationLng: freezed == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as EventColor?,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as EventOrigin,answers: null == answers ? _self._answers : answers // ignore: cast_nullable_to_non_nullable
as List<EventAnswer>,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$EventComment {

 String get id;@JsonKey(name: 'event_id') String get eventId;@JsonKey(name: 'author_player_id') String get authorPlayerId; String get body;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'edited_at') DateTime? get editedAt;
/// Create a copy of EventComment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventCommentCopyWith<EventComment> get copyWith => _$EventCommentCopyWithImpl<EventComment>(this as EventComment, _$identity);

  /// Serializes this EventComment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EventComment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventComment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.authorPlayerId, _this.authorPlayerId) || other.authorPlayerId == _this.authorPlayerId)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.editedAt, _this.editedAt) || other.editedAt == _this.editedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EventComment;
  return Object.hash(runtimeType,_this.id,_this.eventId,_this.authorPlayerId,_this.body,_this.createdAt,_this.editedAt);
}

@override
String toString() {
  final _this = this as EventComment;
  return 'EventComment(id: ${_this.id}, eventId: ${_this.eventId}, authorPlayerId: ${_this.authorPlayerId}, body: ${_this.body}, createdAt: ${_this.createdAt}, editedAt: ${_this.editedAt})';
}


}

/// @nodoc
abstract mixin class $EventCommentCopyWith<$Res>  {
  factory $EventCommentCopyWith(EventComment value, $Res Function(EventComment) _then) = _$EventCommentCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'event_id') String eventId,@JsonKey(name: 'author_player_id') String authorPlayerId, String body,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'edited_at') DateTime? editedAt
});




}
/// @nodoc
class _$EventCommentCopyWithImpl<$Res>
    implements $EventCommentCopyWith<$Res> {
  _$EventCommentCopyWithImpl(this._self, this._then);

  final EventComment _self;
  final $Res Function(EventComment) _then;

/// Create a copy of EventComment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = null,Object? authorPlayerId = null,Object? body = null,Object? createdAt = null,Object? editedAt = freezed,}) {
  return _then(EventComment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,authorPlayerId: null == authorPlayerId ? _self.authorPlayerId : authorPlayerId // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventComment].
extension EventCommentPatterns on EventComment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventComment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventComment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventComment value)  $default,){
final _that = this;
switch (_that) {
case _EventComment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventComment value)?  $default,){
final _that = this;
switch (_that) {
case _EventComment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_id')  String eventId, @JsonKey(name: 'author_player_id')  String authorPlayerId,  String body, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'edited_at')  DateTime? editedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventComment() when $default != null:
return $default(_that.id,_that.eventId,_that.authorPlayerId,_that.body,_that.createdAt,_that.editedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_id')  String eventId, @JsonKey(name: 'author_player_id')  String authorPlayerId,  String body, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'edited_at')  DateTime? editedAt)  $default,) {final _that = this;
switch (_that) {
case _EventComment():
return $default(_that.id,_that.eventId,_that.authorPlayerId,_that.body,_that.createdAt,_that.editedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'event_id')  String eventId, @JsonKey(name: 'author_player_id')  String authorPlayerId,  String body, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'edited_at')  DateTime? editedAt)?  $default,) {final _that = this;
switch (_that) {
case _EventComment() when $default != null:
return $default(_that.id,_that.eventId,_that.authorPlayerId,_that.body,_that.createdAt,_that.editedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventComment implements EventComment {
  const _EventComment({required this.id, @JsonKey(name: 'event_id') required this.eventId, @JsonKey(name: 'author_player_id') required this.authorPlayerId, required this.body, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'edited_at') this.editedAt});
  factory _EventComment.fromJson(Map<String, dynamic> json) => _$EventCommentFromJson(json);

@override final  String id;
@override@JsonKey(name: 'event_id') final  String eventId;
@override@JsonKey(name: 'author_player_id') final  String authorPlayerId;
@override final  String body;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'edited_at') final  DateTime? editedAt;

/// Create a copy of EventComment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventCommentCopyWith<_EventComment> get copyWith => __$EventCommentCopyWithImpl<_EventComment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventCommentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventComment&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.authorPlayerId, authorPlayerId) || other.authorPlayerId == authorPlayerId)&&(identical(other.body, body) || other.body == body)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,eventId,authorPlayerId,body,createdAt,editedAt);
}

@override
String toString() {
    return 'EventComment(id: $id, eventId: $eventId, authorPlayerId: $authorPlayerId, body: $body, createdAt: $createdAt, editedAt: $editedAt)';
}


}

/// @nodoc
abstract mixin class _$EventCommentCopyWith<$Res> implements $EventCommentCopyWith<$Res> {
  factory _$EventCommentCopyWith(_EventComment value, $Res Function(_EventComment) _then) = __$EventCommentCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'event_id') String eventId,@JsonKey(name: 'author_player_id') String authorPlayerId, String body,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'edited_at') DateTime? editedAt
});




}
/// @nodoc
class __$EventCommentCopyWithImpl<$Res>
    implements _$EventCommentCopyWith<$Res> {
  __$EventCommentCopyWithImpl(this._self, this._then);

  final _EventComment _self;
  final $Res Function(_EventComment) _then;

/// Create a copy of EventComment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = null,Object? authorPlayerId = null,Object? body = null,Object? createdAt = null,Object? editedAt = freezed,}) {
  return _then(_EventComment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,authorPlayerId: null == authorPlayerId ? _self.authorPlayerId : authorPlayerId // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$EventDraft {

 DateTime get startsAt; String get label; String? get spot; String? get spotId; double? get lat; double? get lng; String? get managerPlayerId; String? get description; EventColor? get color;
/// Create a copy of EventDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventDraftCopyWith<EventDraft> get copyWith => _$EventDraftCopyWithImpl<EventDraft>(this as EventDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EventDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventDraft&&(identical(other.startsAt, _this.startsAt) || other.startsAt == _this.startsAt)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.spot, _this.spot) || other.spot == _this.spot)&&(identical(other.spotId, _this.spotId) || other.spotId == _this.spotId)&&(identical(other.lat, _this.lat) || other.lat == _this.lat)&&(identical(other.lng, _this.lng) || other.lng == _this.lng)&&(identical(other.managerPlayerId, _this.managerPlayerId) || other.managerPlayerId == _this.managerPlayerId)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.color, _this.color) || other.color == _this.color));
}


@override
int get hashCode {
  final _this = this as EventDraft;
  return Object.hash(runtimeType,_this.startsAt,_this.label,_this.spot,_this.spotId,_this.lat,_this.lng,_this.managerPlayerId,_this.description,_this.color);
}

@override
String toString() {
  final _this = this as EventDraft;
  return 'EventDraft(startsAt: ${_this.startsAt}, label: ${_this.label}, spot: ${_this.spot}, spotId: ${_this.spotId}, lat: ${_this.lat}, lng: ${_this.lng}, managerPlayerId: ${_this.managerPlayerId}, description: ${_this.description}, color: ${_this.color})';
}


}

/// @nodoc
abstract mixin class $EventDraftCopyWith<$Res>  {
  factory $EventDraftCopyWith(EventDraft value, $Res Function(EventDraft) _then) = _$EventDraftCopyWithImpl;
@useResult
$Res call({
 DateTime startsAt, String label, String? spot, String? spotId, double? lat, double? lng, String? managerPlayerId, String? description, EventColor? color
});




}
/// @nodoc
class _$EventDraftCopyWithImpl<$Res>
    implements $EventDraftCopyWith<$Res> {
  _$EventDraftCopyWithImpl(this._self, this._then);

  final EventDraft _self;
  final $Res Function(EventDraft) _then;

/// Create a copy of EventDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startsAt = null,Object? label = null,Object? spot = freezed,Object? spotId = freezed,Object? lat = freezed,Object? lng = freezed,Object? managerPlayerId = freezed,Object? description = freezed,Object? color = freezed,}) {
  return _then(EventDraft(
startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,spot: freezed == spot ? _self.spot : spot // ignore: cast_nullable_to_non_nullable
as String?,spotId: freezed == spotId ? _self.spotId : spotId // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,managerPlayerId: freezed == managerPlayerId ? _self.managerPlayerId : managerPlayerId // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as EventColor?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventDraft].
extension EventDraftPatterns on EventDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventDraft value)  $default,){
final _that = this;
switch (_that) {
case _EventDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventDraft value)?  $default,){
final _that = this;
switch (_that) {
case _EventDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime startsAt,  String label,  String? spot,  String? spotId,  double? lat,  double? lng,  String? managerPlayerId,  String? description,  EventColor? color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventDraft() when $default != null:
return $default(_that.startsAt,_that.label,_that.spot,_that.spotId,_that.lat,_that.lng,_that.managerPlayerId,_that.description,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime startsAt,  String label,  String? spot,  String? spotId,  double? lat,  double? lng,  String? managerPlayerId,  String? description,  EventColor? color)  $default,) {final _that = this;
switch (_that) {
case _EventDraft():
return $default(_that.startsAt,_that.label,_that.spot,_that.spotId,_that.lat,_that.lng,_that.managerPlayerId,_that.description,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime startsAt,  String label,  String? spot,  String? spotId,  double? lat,  double? lng,  String? managerPlayerId,  String? description,  EventColor? color)?  $default,) {final _that = this;
switch (_that) {
case _EventDraft() when $default != null:
return $default(_that.startsAt,_that.label,_that.spot,_that.spotId,_that.lat,_that.lng,_that.managerPlayerId,_that.description,_that.color);case _:
  return null;

}
}

}

/// @nodoc


class _EventDraft extends EventDraft {
  const _EventDraft({required this.startsAt, required this.label, this.spot, this.spotId, this.lat, this.lng, this.managerPlayerId, this.description, this.color}): super._();
  

@override final  DateTime startsAt;
@override final  String label;
@override final  String? spot;
@override final  String? spotId;
@override final  double? lat;
@override final  double? lng;
@override final  String? managerPlayerId;
@override final  String? description;
@override final  EventColor? color;

/// Create a copy of EventDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventDraftCopyWith<_EventDraft> get copyWith => __$EventDraftCopyWithImpl<_EventDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventDraft&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.label, label) || other.label == label)&&(identical(other.spot, spot) || other.spot == spot)&&(identical(other.spotId, spotId) || other.spotId == spotId)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.managerPlayerId, managerPlayerId) || other.managerPlayerId == managerPlayerId)&&(identical(other.description, description) || other.description == description)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode {
    return Object.hash(runtimeType,startsAt,label,spot,spotId,lat,lng,managerPlayerId,description,color);
}

@override
String toString() {
    return 'EventDraft(startsAt: $startsAt, label: $label, spot: $spot, spotId: $spotId, lat: $lat, lng: $lng, managerPlayerId: $managerPlayerId, description: $description, color: $color)';
}


}

/// @nodoc
abstract mixin class _$EventDraftCopyWith<$Res> implements $EventDraftCopyWith<$Res> {
  factory _$EventDraftCopyWith(_EventDraft value, $Res Function(_EventDraft) _then) = __$EventDraftCopyWithImpl;
@override @useResult
$Res call({
 DateTime startsAt, String label, String? spot, String? spotId, double? lat, double? lng, String? managerPlayerId, String? description, EventColor? color
});




}
/// @nodoc
class __$EventDraftCopyWithImpl<$Res>
    implements _$EventDraftCopyWith<$Res> {
  __$EventDraftCopyWithImpl(this._self, this._then);

  final _EventDraft _self;
  final $Res Function(_EventDraft) _then;

/// Create a copy of EventDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startsAt = null,Object? label = null,Object? spot = freezed,Object? spotId = freezed,Object? lat = freezed,Object? lng = freezed,Object? managerPlayerId = freezed,Object? description = freezed,Object? color = freezed,}) {
  return _then(_EventDraft(
startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,spot: freezed == spot ? _self.spot : spot // ignore: cast_nullable_to_non_nullable
as String?,spotId: freezed == spotId ? _self.spotId : spotId // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,managerPlayerId: freezed == managerPlayerId ? _self.managerPlayerId : managerPlayerId // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as EventColor?,
  ));
}


}

// dart format on
