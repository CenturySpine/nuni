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
  locationLat: (json['location_lat'] as num?)?.toDouble(),
  locationLng: (json['location_lng'] as num?)?.toDouble(),
  weather: json['weather'] == null
      ? null
      : Weather.fromJson(json['weather'] as Map<String, dynamic>),
  comment: json['comment'] as String?,
  coverPhotoId: json['cover_photo_id'] as String?,
  coverPhotoPath: json['cover_photo_path'] as String?,
  isChampionship: json['is_championship'] as bool? ?? false,
  championshipZoneId: json['championship_zone_id'] as String?,
  championshipSeason: json['championship_season'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  startedAt: json['started_at'] == null
      ? null
      : DateTime.parse(json['started_at'] as String),
  endedAt: json['ended_at'] == null
      ? null
      : DateTime.parse(json['ended_at'] as String),
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
  'location_lat': instance.locationLat,
  'location_lng': instance.locationLng,
  'weather': instance.weather,
  'comment': instance.comment,
  'cover_photo_id': instance.coverPhotoId,
  'cover_photo_path': instance.coverPhotoPath,
  'is_championship': instance.isChampionship,
  'championship_zone_id': instance.championshipZoneId,
  'championship_season': instance.championshipSeason,
  'created_at': instance.createdAt.toIso8601String(),
  'started_at': instance.startedAt?.toIso8601String(),
  'ended_at': instance.endedAt?.toIso8601String(),
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
