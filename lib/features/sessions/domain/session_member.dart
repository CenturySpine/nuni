import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_member.freezed.dart';
part 'session_member.g.dart';

/// Mirrors the `member_role` Postgres enum (plan 03).
enum MemberRole {
  @JsonValue('owner')
  owner,
  @JsonValue('player')
  player,
}

/// Parses a plain `role` column value read outside a [SessionMember] row
/// (e.g. joined manually alongside a [Session] for "Mes sessions", plan 09)
/// -- the generated json_serializable map for [MemberRole] is private to
/// `session_member.g.dart`.
MemberRole memberRoleFromPostgresValue(String value) =>
    value == 'owner' ? MemberRole.owner : MemberRole.player;

/// Mirrors the `session_members` table (plan 03): the waiting-room pool.
/// `teamId == null` means "not assigned to a team yet" (Q25).
/// `checkedInAt == null` means added by the organizer or from an event, not
/// joined by the code or the QR code yet (PO, 2026-09-28).
@freezed
abstract class SessionMember with _$SessionMember {
  const factory SessionMember({
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'team_id') String? teamId,
    required MemberRole role,
    @JsonKey(name: 'checked_in_at') DateTime? checkedInAt,
  }) = _SessionMember;

  const SessionMember._();

  /// Joined the session themselves (code, QR code, or its creator).
  bool get hasJoined => checkedInAt != null;

  factory SessionMember.fromJson(Map<String, Object?> json) =>
      _$SessionMemberFromJson(json);
}
