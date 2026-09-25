// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'association.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Association _$AssociationFromJson(Map<String, dynamic> json) => _Association(
  id: json['id'] as String,
  name: json['name'] as String,
  shortName: json['short_name'] as String?,
  city: json['city'] as String,
  locationLat: (json['location_lat'] as num).toDouble(),
  locationLng: (json['location_lng'] as num).toDouble(),
  websiteUrl: json['website_url'] as String?,
  logoPath: json['logo_path'] as String?,
  partners:
      (json['partners'] as List<dynamic>?)
          ?.map((e) => AssociationPartner.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AssociationPartner>[],
  status: $enumDecode(_$AssociationStatusEnumMap, json['status']),
  createdBy: json['created_by'] as String?,
);

Map<String, dynamic> _$AssociationToJson(_Association instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'short_name': instance.shortName,
      'city': instance.city,
      'location_lat': instance.locationLat,
      'location_lng': instance.locationLng,
      'website_url': instance.websiteUrl,
      'logo_path': instance.logoPath,
      'partners': instance.partners,
      'status': _$AssociationStatusEnumMap[instance.status]!,
      'created_by': instance.createdBy,
    };

const _$AssociationStatusEnumMap = {
  AssociationStatus.pending: 'pending',
  AssociationStatus.approved: 'approved',
  AssociationStatus.rejected: 'rejected',
};

_AssociationPartner _$AssociationPartnerFromJson(Map<String, dynamic> json) =>
    _AssociationPartner(
      label: json['label'] as String,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$AssociationPartnerToJson(_AssociationPartner instance) =>
    <String, dynamic>{'label': instance.label, 'url': instance.url};

_AssociationManager _$AssociationManagerFromJson(Map<String, dynamic> json) =>
    _AssociationManager(
      id: json['id'] as String,
      associationId: json['association_id'] as String,
      userId: json['user_id'] as String,
      status: $enumDecode(_$AssociationManagerStatusEnumMap, json['status']),
      requestedAt: DateTime.parse(json['requested_at'] as String),
    );

Map<String, dynamic> _$AssociationManagerToJson(_AssociationManager instance) =>
    <String, dynamic>{
      'id': instance.id,
      'association_id': instance.associationId,
      'user_id': instance.userId,
      'status': _$AssociationManagerStatusEnumMap[instance.status]!,
      'requested_at': instance.requestedAt.toIso8601String(),
    };

const _$AssociationManagerStatusEnumMap = {
  AssociationManagerStatus.pending: 'pending',
  AssociationManagerStatus.approved: 'approved',
  AssociationManagerStatus.rejected: 'rejected',
  AssociationManagerStatus.revoked: 'revoked',
};

_ManagerContact _$ManagerContactFromJson(Map<String, dynamic> json) =>
    _ManagerContact(
      managerId: json['manager_id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      requestMessage: json['request_message'] as String?,
    );

Map<String, dynamic> _$ManagerContactToJson(_ManagerContact instance) =>
    <String, dynamic>{
      'manager_id': instance.managerId,
      'email': instance.email,
      'phone': instance.phone,
      'request_message': instance.requestMessage,
    };
