// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Spot _$SpotFromJson(Map<String, dynamic> json) => _Spot(
  id: json['id'] as String,
  associationId: json['association_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  locationLat: (json['location_lat'] as num?)?.toDouble(),
  locationLng: (json['location_lng'] as num?)?.toDouble(),
  variableLocation: json['variable_location'] as bool? ?? false,
);

Map<String, dynamic> _$SpotToJson(_Spot instance) => <String, dynamic>{
  'id': instance.id,
  'association_id': instance.associationId,
  'name': instance.name,
  'description': instance.description,
  'address': instance.address,
  'city': instance.city,
  'location_lat': instance.locationLat,
  'location_lng': instance.locationLng,
  'variable_location': instance.variableLocation,
};
