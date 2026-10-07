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
  kind: $enumDecodeNullable(_$SessionKindEnumMap, json['kind']),
  scoringMode: $enumDecodeNullable(_$ScoringModeEnumMap, json['scoring_mode']),
  rankingDirection: $enumDecodeNullable(
    _$RankingDirectionEnumMap,
    json['ranking_direction'],
  ),
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$SessionTagEnumMap, e))
          .toList() ??
      const <SessionTag>[],
  title: json['title'] as String?,
  city: json['city'] as String?,
  zone: json['zone'] as String?,
  spotId: json['spot_id'] as String?,
  locationLat: (json['location_lat'] as num?)?.toDouble(),
  locationLng: (json['location_lng'] as num?)?.toDouble(),
  weather: json['weather'] == null
      ? null
      : Weather.fromJson(json['weather'] as Map<String, dynamic>),
  comment: json['comment'] as String?,
  coverPhotoId: json['cover_photo_id'] as String?,
  coverPhotoPath: json['cover_photo_path'] as String?,
  associationId: json['association_id'] as String?,
  isChampionship: json['is_championship'] as bool? ?? false,
  championshipSeason: json['championship_season'] as String?,
  published: json['published'] as bool? ?? true,
  eventId: json['event_id'] as String?,
  holesAscending: json['holes_ascending'] as bool? ?? false,
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
  'kind': _$SessionKindEnumMap[instance.kind],
  'scoring_mode': _$ScoringModeEnumMap[instance.scoringMode],
  'ranking_direction': _$RankingDirectionEnumMap[instance.rankingDirection],
  'tags': instance.tags.map((e) => _$SessionTagEnumMap[e]!).toList(),
  'title': instance.title,
  'city': instance.city,
  'zone': instance.zone,
  'spot_id': instance.spotId,
  'location_lat': instance.locationLat,
  'location_lng': instance.locationLng,
  'weather': instance.weather,
  'comment': instance.comment,
  'cover_photo_id': instance.coverPhotoId,
  'cover_photo_path': instance.coverPhotoPath,
  'association_id': instance.associationId,
  'is_championship': instance.isChampionship,
  'championship_season': instance.championshipSeason,
  'published': instance.published,
  'event_id': instance.eventId,
  'holes_ascending': instance.holesAscending,
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

const _$SessionTagEnumMap = {
  SessionTag.training: 'training',
  SessionTag.simulator: 'simulator',
  SessionTag.associationLife: 'association_life',
};
