// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'played_hole.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayedHoleGeo _$PlayedHoleGeoFromJson(Map<String, dynamic> json) =>
    _PlayedHoleGeo(
      id: json['id'] as String,
      name: json['name'] as String,
      par: (json['par'] as num).toInt(),
      startLat: (json['start_lat'] as num?)?.toDouble(),
      startLng: (json['start_lng'] as num?)?.toDouble(),
      visibility: $enumDecode(_$HoleVisibilityEnumMap, json['visibility']),
    );

Map<String, dynamic> _$PlayedHoleGeoToJson(_PlayedHoleGeo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'par': instance.par,
      'start_lat': instance.startLat,
      'start_lng': instance.startLng,
      'visibility': _$HoleVisibilityEnumMap[instance.visibility]!,
    };

const _$HoleVisibilityEnumMap = {
  HoleVisibility.public: 'public',
  HoleVisibility.private: 'private',
};

_HoleScore _$HoleScoreFromJson(Map<String, dynamic> json) => _HoleScore(
  teamId: json['team_id'] as String,
  value: (json['value'] as num).toInt(),
  updatedBy: json['updated_by'] as String?,
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$HoleScoreToJson(_HoleScore instance) =>
    <String, dynamic>{
      'team_id': instance.teamId,
      'value': instance.value,
      'updated_by': instance.updatedBy,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_PlayedHole _$PlayedHoleFromJson(Map<String, dynamic> json) => _PlayedHole(
  id: json['id'] as String,
  position: (json['position'] as num).toInt(),
  gameMode: $enumDecode(_$GameModeEnumMap, json['game_mode']),
  hole: json['hole'] == null
      ? null
      : PlayedHoleGeo.fromJson(json['hole'] as Map<String, dynamic>),
  label: json['label'] as String?,
  scores: (json['scores'] as List<dynamic>)
      .map((e) => HoleScore.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PlayedHoleToJson(_PlayedHole instance) =>
    <String, dynamic>{
      'id': instance.id,
      'position': instance.position,
      'game_mode': _$GameModeEnumMap[instance.gameMode]!,
      'hole': instance.hole,
      'label': instance.label,
      'scores': instance.scores,
    };

const _$GameModeEnumMap = {
  GameMode.individual: 'individual',
  GameMode.scramble: 'scramble',
  GameMode.greensome: 'greensome',
  GameMode.bestBall: 'best_ball',
};
