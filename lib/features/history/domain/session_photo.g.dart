// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionPhoto _$SessionPhotoFromJson(Map<String, dynamic> json) =>
    _SessionPhoto(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      storagePath: json['storage_path'] as String,
      uploadedBy: json['uploaded_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$SessionPhotoToJson(_SessionPhoto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'session_id': instance.sessionId,
      'storage_path': instance.storagePath,
      'uploaded_by': instance.uploadedBy,
      'created_at': instance.createdAt.toIso8601String(),
    };
