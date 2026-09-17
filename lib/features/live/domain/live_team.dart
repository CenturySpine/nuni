import 'package:freezed_annotation/freezed_annotation.dart';

part 'live_team.freezed.dart';
part 'live_team.g.dart';

/// One player's name within a [LiveTeam]'s roster.
@freezed
abstract class TeamPlayerName with _$TeamPlayerName {
  const factory TeamPlayerName({
    @JsonKey(name: 'player_id') required String playerId,
    required String name,
  }) = _TeamPlayerName;

  factory TeamPlayerName.fromJson(Map<String, Object?> json) =>
      _$TeamPlayerNameFromJson(json);
}

/// Mirrors one entry of `session_snapshot`'s `teams` array (plan 08): a
/// `teams` row plus its roster read from `team_players` -- the frozen-after-
/// draft source of truth for who's on the team (Q15), unlike the waiting
/// room's [Team], which reads the roster off `session_members` instead
/// (see `team.dart`).
@freezed
abstract class LiveTeam with _$LiveTeam {
  const factory LiveTeam({
    required String id,
    required int position,
    required List<TeamPlayerName> players,
  }) = _LiveTeam;

  factory LiveTeam.fromJson(Map<String, Object?> json) =>
      _$LiveTeamFromJson(json);
}

extension LiveTeamDisplay on LiveTeam {
  String playerNames() => players.map((p) => p.name).join(' / ');
}
