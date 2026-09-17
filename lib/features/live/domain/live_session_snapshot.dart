import '../../sessions/domain/session.dart';
import '../../sessions/domain/session_member.dart';
import 'live_member.dart';
import 'live_team.dart';
import 'played_hole.dart';

/// One `session_snapshot` RPC call's result (plan 08, Q36): reloaded whole
/// on every realtime "something changed" event on any of the tables it's
/// built from, never patched locally -- same approach as the waiting
/// room's `SessionRoomSnapshot`.
class LiveSessionSnapshot {
  const LiveSessionSnapshot({
    required this.session,
    required this.members,
    required this.teams,
    required this.playedHoles,
  });

  factory LiveSessionSnapshot.fromJson(Map<String, Object?> json) =>
      LiveSessionSnapshot(
        session: Session.fromJson(json['session'] as Map<String, Object?>),
        members: [
          for (final row in json['members'] as List<dynamic>)
            LiveMember.fromJson(row as Map<String, Object?>),
        ],
        teams: [
          for (final row in json['teams'] as List<dynamic>)
            LiveTeam.fromJson(row as Map<String, Object?>),
        ],
        playedHoles: [
          for (final row in json['played_holes'] as List<dynamic>)
            PlayedHole.fromJson(row as Map<String, Object?>),
        ],
      );

  final Session session;
  final List<LiveMember> members;
  final List<LiveTeam> teams;
  final List<PlayedHole> playedHoles;

  LiveMember? memberFor(String? userId) {
    if (userId == null) return null;
    for (final member in members) {
      if (member.userId == userId) return member;
    }
    return null;
  }

  bool isOwner(String? userId) => memberFor(userId)?.role == MemberRole.owner;

  /// Q8: a member scores only their own team; the owner (and any
  /// co-organizer) scores every team. `null` when the caller isn't a
  /// member -- but they never reach this screen without RLS letting them
  /// read the session in the first place.
  String? myTeamId(String? userId) => memberFor(userId)?.teamId;

  /// Played holes, most recently added first ("dernier en tête", plan 08).
  List<PlayedHole> get playedHolesRecentFirst => playedHoles.reversed.toList();
}
