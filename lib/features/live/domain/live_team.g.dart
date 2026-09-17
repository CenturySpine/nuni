// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TeamPlayerName _$TeamPlayerNameFromJson(Map<String, dynamic> json) =>
    _TeamPlayerName(
      playerId: json['player_id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$TeamPlayerNameToJson(_TeamPlayerName instance) =>
    <String, dynamic>{'player_id': instance.playerId, 'name': instance.name};

_LiveTeam _$LiveTeamFromJson(Map<String, dynamic> json) => _LiveTeam(
  id: json['id'] as String,
  position: (json['position'] as num).toInt(),
  players: (json['players'] as List<dynamic>)
      .map((e) => TeamPlayerName.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LiveTeamToJson(_LiveTeam instance) => <String, dynamic>{
  'id': instance.id,
  'position': instance.position,
  'players': instance.players,
};
