// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Player _$PlayerFromJson(Map<String, dynamic> json) => _Player(
  id: json['id'] as String,
  name: json['name'] as String,
  avatarUrl: json['avatar_url'] as String?,
  locale: json['locale'] as String,
  userId: json['user_id'] as String?,
);

Map<String, dynamic> _$PlayerToJson(_Player instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatar_url': instance.avatarUrl,
  'locale': instance.locale,
  'user_id': instance.userId,
};
