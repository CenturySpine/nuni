// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventAnswer _$EventAnswerFromJson(Map<String, dynamic> json) => _EventAnswer(
  playerId: json['player_id'] as String,
  response: $enumDecode(_$EventResponseEnumMap, json['response']),
);

Map<String, dynamic> _$EventAnswerToJson(_EventAnswer instance) =>
    <String, dynamic>{
      'player_id': instance.playerId,
      'response': _$EventResponseEnumMap[instance.response]!,
    };

const _$EventResponseEnumMap = {
  EventResponse.yes: 'yes',
  EventResponse.no: 'no',
  EventResponse.maybe: 'maybe',
};

_Event _$EventFromJson(Map<String, dynamic> json) => _Event(
  id: json['id'] as String,
  associationId: json['association_id'] as String,
  createdBy: json['created_by'] as String,
  managerPlayerId: json['manager_player_id'] as String?,
  startsAt: DateTime.parse(json['starts_at'] as String),
  label: json['label'] as String,
  spot: json['spot'] as String?,
  spotId: json['spot_id'] as String?,
  locationLat: (json['location_lat'] as num?)?.toDouble(),
  locationLng: (json['location_lng'] as num?)?.toDouble(),
  description: json['description'] as String?,
  color: $enumDecodeNullable(_$EventColorEnumMap, json['color']),
  origin:
      $enumDecodeNullable(_$EventOriginEnumMap, json['origin']) ??
      EventOrigin.manual,
  answers:
      (json['event_responses'] as List<dynamic>?)
          ?.map((e) => EventAnswer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  commentCount: (_readCount(json, 'event_comments') as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$EventToJson(_Event instance) => <String, dynamic>{
  'id': instance.id,
  'association_id': instance.associationId,
  'created_by': instance.createdBy,
  'manager_player_id': instance.managerPlayerId,
  'starts_at': instance.startsAt.toIso8601String(),
  'label': instance.label,
  'spot': instance.spot,
  'spot_id': instance.spotId,
  'location_lat': instance.locationLat,
  'location_lng': instance.locationLng,
  'description': instance.description,
  'color': _$EventColorEnumMap[instance.color],
  'origin': _$EventOriginEnumMap[instance.origin]!,
  'event_responses': instance.answers,
  'event_comments': instance.commentCount,
};

const _$EventColorEnumMap = {
  EventColor.red: 'red',
  EventColor.orange: 'orange',
  EventColor.yellow: 'yellow',
  EventColor.green: 'green',
  EventColor.teal: 'teal',
  EventColor.blue: 'blue',
  EventColor.purple: 'purple',
  EventColor.pink: 'pink',
};

const _$EventOriginEnumMap = {
  EventOrigin.manual: 'manual',
  EventOrigin.imported: 'imported',
};

_EventComment _$EventCommentFromJson(Map<String, dynamic> json) =>
    _EventComment(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      authorPlayerId: json['author_player_id'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      editedAt: json['edited_at'] == null
          ? null
          : DateTime.parse(json['edited_at'] as String),
    );

Map<String, dynamic> _$EventCommentToJson(_EventComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_id': instance.eventId,
      'author_player_id': instance.authorPlayerId,
      'body': instance.body,
      'created_at': instance.createdAt.toIso8601String(),
      'edited_at': instance.editedAt?.toIso8601String(),
    };
