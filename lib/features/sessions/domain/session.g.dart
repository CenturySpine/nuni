// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Session _$SessionFromJson(Map<String, dynamic> json) => _Session(
  id: json['id'] as String,
  code: json['code'] as String,
  ownerId: json['owner_id'] as String,
  status: $enumDecode(_$SessionStatusEnumMap, json['status']),
  kind: $enumDecode(_$SessionKindEnumMap, json['kind']),
  scoringMode: $enumDecode(_$ScoringModeEnumMap, json['scoring_mode']),
  rankingDirection: $enumDecode(
    _$RankingDirectionEnumMap,
    json['ranking_direction'],
  ),
  city: json['city'] as String?,
  zone: json['zone'] as String?,
);

Map<String, dynamic> _$SessionToJson(_Session instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'owner_id': instance.ownerId,
  'status': _$SessionStatusEnumMap[instance.status]!,
  'kind': _$SessionKindEnumMap[instance.kind]!,
  'scoring_mode': _$ScoringModeEnumMap[instance.scoringMode]!,
  'ranking_direction': _$RankingDirectionEnumMap[instance.rankingDirection]!,
  'city': instance.city,
  'zone': instance.zone,
};

const _$SessionStatusEnumMap = {
  SessionStatus.draft: 'draft',
  SessionStatus.live: 'live',
  SessionStatus.completed: 'completed',
};

const _$SessionKindEnumMap = {
  SessionKind.individual: 'individual',
  SessionKind.team: 'team',
};

const _$ScoringModeEnumMap = {
  ScoringMode.strokePlay: 'stroke_play',
  ScoringMode.matchPlay: 'match_play',
  ScoringMode.redistribution: 'redistribution',
  ScoringMode.free: 'free',
};

const _$RankingDirectionEnumMap = {
  RankingDirection.asc: 'asc',
  RankingDirection.desc: 'desc',
};
