import 'package:freezed_annotation/freezed_annotation.dart';

import '../../sessions/domain/session_member.dart';

part 'live_member.freezed.dart';
part 'live_member.g.dart';

/// Mirrors one entry of `session_snapshot`'s `members` array (plan 08): a
/// `session_members` row plus the linked player's name, for "who is the
/// owner", "which team is mine" and the co-organizer promotion sheet.
@freezed
abstract class LiveMember with _$LiveMember {
  const factory LiveMember({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'team_id') String? teamId,
    required MemberRole role,
    @JsonKey(name: 'player_name') required String playerName,
  }) = _LiveMember;

  factory LiveMember.fromJson(Map<String, Object?> json) =>
      _$LiveMemberFromJson(json);
}
