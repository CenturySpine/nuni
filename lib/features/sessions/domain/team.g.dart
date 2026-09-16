// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Team _$TeamFromJson(Map<String, dynamic> json) => _Team(
  id: json['id'] as String,
  sessionId: json['session_id'] as String,
  position: (json['position'] as num).toInt(),
);

Map<String, dynamic> _$TeamToJson(_Team instance) => <String, dynamic>{
  'id': instance.id,
  'session_id': instance.sessionId,
  'position': instance.position,
};
