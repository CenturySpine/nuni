import '../badge.dart';
import '../badge_facts.dart';
import 'tracker.dart';

/// F. Team play (Q107): team sessions (F1), different teammates (F2), and
/// sessions with the same teammate (F3). A teammate is another player of
/// the same team in a team session.
List<BadgeResult> teamBadges(BadgeFacts facts) {
  final teammate = BadgeTracker(BadgeId.teammate);
  final gatherer = BadgeTracker(BadgeId.gatherer);
  final dreamTeam = BadgeTracker(BadgeId.dreamTeam);

  final together = <String, int>{};
  for (final session in facts.teamSessions) {
    teammate.add(session);
    for (final mate in session.team.players) {
      if (mate.playerId == facts.playerId) continue;
      together[mate.playerId] = (together[mate.playerId] ?? 0) + 1;
      dreamTeam.reach(together[mate.playerId]!, session);
    }
    gatherer.reach(together.length, session);
  }

  return [teammate, gatherer, dreamTeam].results();
}
