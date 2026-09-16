import 'package:freezed_annotation/freezed_annotation.dart';

part 'team.freezed.dart';
part 'team.g.dart';

/// Mirrors the `teams` table (plan 03): just enough to order and identify a
/// team in the waiting room -- its roster comes from the matching
/// [SessionMember]s (`teamId`), not from `team_players` (plan 07 never reads
/// that table back, it only writes to it to keep the schema's roster
/// consistent for plan 08's scoring).
@freezed
abstract class Team with _$Team {
  const factory Team({
    required String id,
    @JsonKey(name: 'session_id') required String sessionId,
    required int position,
  }) = _Team;

  factory Team.fromJson(Map<String, Object?> json) => _$TeamFromJson(json);
}
