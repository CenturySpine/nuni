// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionMember _$SessionMemberFromJson(Map<String, dynamic> json) =>
    _SessionMember(
      sessionId: json['session_id'] as String,
      userId: json['user_id'] as String,
      teamId: json['team_id'] as String?,
      role: $enumDecode(_$MemberRoleEnumMap, json['role']),
    );

Map<String, dynamic> _$SessionMemberToJson(_SessionMember instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'user_id': instance.userId,
      'team_id': instance.teamId,
      'role': _$MemberRoleEnumMap[instance.role]!,
    };

const _$MemberRoleEnumMap = {
  MemberRole.owner: 'owner',
  MemberRole.player: 'player',
};
