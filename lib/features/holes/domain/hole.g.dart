// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hole.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HolePathPoint _$HolePathPointFromJson(Map<String, dynamic> json) =>
    _HolePathPoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$HolePathPointToJson(_HolePathPoint instance) =>
    <String, dynamic>{'lat': instance.lat, 'lng': instance.lng};

_Hole _$HoleFromJson(Map<String, dynamic> json) => _Hole(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  par: (json['par'] as num).toInt(),
  distanceM: (json['distance_m'] as num?)?.toInt(),
  startLat: (json['start_lat'] as num).toDouble(),
  startLng: (json['start_lng'] as num).toDouble(),
  endLat: (json['end_lat'] as num?)?.toDouble(),
  endLng: (json['end_lng'] as num?)?.toDouble(),
  path: (json['path'] as List<dynamic>?)
      ?.map((e) => HolePathPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  photoStartPath: json['photo_start_path'] as String?,
  photoEndPath: json['photo_end_path'] as String?,
  visibility: $enumDecode(_$HoleVisibilityEnumMap, json['visibility']),
  ownerId: json['owner_id'] as String,
  distance: (json['distance'] as num?)?.toDouble(),
);

Map<String, dynamic> _$HoleToJson(_Hole instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'par': instance.par,
  'distance_m': instance.distanceM,
  'start_lat': instance.startLat,
  'start_lng': instance.startLng,
  'end_lat': instance.endLat,
  'end_lng': instance.endLng,
  'path': instance.path,
  'photo_start_path': instance.photoStartPath,
  'photo_end_path': instance.photoEndPath,
  'visibility': _$HoleVisibilityEnumMap[instance.visibility]!,
  'owner_id': instance.ownerId,
  'distance': instance.distance,
};

const _$HoleVisibilityEnumMap = {
  HoleVisibility.public: 'public',
  HoleVisibility.private: 'private',
};
