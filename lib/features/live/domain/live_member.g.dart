// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LiveMember _$LiveMemberFromJson(Map<String, dynamic> json) => _LiveMember(
  userId: json['user_id'] as String,
  teamId: json['team_id'] as String?,
  role: $enumDecode(_$MemberRoleEnumMap, json['role']),
  playerName: json['player_name'] as String,
);

Map<String, dynamic> _$LiveMemberToJson(_LiveMember instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'team_id': instance.teamId,
      'role': _$MemberRoleEnumMap[instance.role]!,
      'player_name': instance.playerName,
    };

const _$MemberRoleEnumMap = {
  MemberRole.owner: 'owner',
  MemberRole.player: 'player',
};
