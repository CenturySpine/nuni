import '../../profile/domain/player.dart';
import 'session.dart';
import 'session_member.dart';
import 'team.dart';
import 'team_composition.dart';

/// A combined, live view of one session's waiting room (plan 07): the
/// session itself, its participant pool, its teams, and enough of each
/// participant's linked player to show a name. Built by
/// `SessionsRepository.watchRoom` from three separately-filtered realtime
/// streams (`sessions`, `session_members`, `teams` -- never `team_players`,
/// see `team.dart`).
class SessionRoomSnapshot {
  const SessionRoomSnapshot({
    required this.session,
    required this.members,
    required this.teams,
    required this.playersByUserId,
  });

  final Session session;
  final List<SessionMember> members;
  final List<Team> teams;
  final Map<String, Player> playersByUserId;

  List<SessionMember> membersOf(String teamId) => [
    for (final member in members)
      if (member.teamId == teamId) member,
  ];

  List<SessionMember> get pool => unassignedMembers(members);

  Player? playerFor(SessionMember member) => playersByUserId[member.userId];
}
