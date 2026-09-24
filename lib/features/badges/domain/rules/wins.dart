import '../badge.dart';
import '../badge_facts.dart';
import 'tracker.dart';

/// The badges of one ranking series (D1 to D10, or their team version,
/// Q141), in that order.
typedef RankingIds = ({
  BadgeId firstWin,
  BadgeId winner,
  BadgeId dominator,
  BadgeId hatTrick,
  BadgeId onTheBox,
  BadgeId podiumRegular,
  BadgeId wireToWire,
  BadgeId comeback,
  BadgeId photoFinish,
  BadgeId holdUp,
});

/// D. Wins and session standings, read from the session's own ranking
/// (`computeStandings`): in individual sessions for D1 to D10, in team
/// sessions for their team version (Q141). Every place must be held alone
/// -- a win, a podium, a last place (Q138, Q139).
List<BadgeResult> winBadges(BadgeFacts facts) => [
  ..._ranking(facts.individualSessions, (
    firstWin: BadgeId.firstWin,
    winner: BadgeId.winner,
    dominator: BadgeId.dominator,
    hatTrick: BadgeId.hatTrick,
    onTheBox: BadgeId.onTheBox,
    podiumRegular: BadgeId.podiumRegular,
    wireToWire: BadgeId.wireToWire,
    comeback: BadgeId.comeback,
    photoFinish: BadgeId.photoFinish,
    holdUp: BadgeId.holdUp,
  )),
  ..._ranking(facts.teamSessions, (
    firstWin: BadgeId.teamFirstWin,
    winner: BadgeId.teamWinner,
    dominator: BadgeId.teamDominator,
    hatTrick: BadgeId.teamHatTrick,
    onTheBox: BadgeId.teamOnTheBox,
    podiumRegular: BadgeId.teamPodiumRegular,
    wireToWire: BadgeId.teamWireToWire,
    comeback: BadgeId.teamComeback,
    photoFinish: BadgeId.teamPhotoFinish,
    holdUp: BadgeId.teamHoldUp,
  )),
];

List<BadgeResult> _ranking(List<PlayedSession> sessions, RankingIds ids) {
  final firstWin = BadgeTracker(ids.firstWin);
  final winner = BadgeTracker(ids.winner);
  final dominator = BadgeTracker(ids.dominator);
  final hatTrick = BadgeTracker(ids.hatTrick);
  final onTheBox = BadgeTracker(ids.onTheBox);
  final podiumRegular = BadgeTracker(ids.podiumRegular);
  final wireToWire = BadgeTracker(ids.wireToWire);
  final comeback = BadgeTracker(ids.comeback);
  final photoFinish = BadgeTracker(ids.photoFinish);
  final holdUp = BadgeTracker(ids.holdUp);

  var streak = 0;
  for (final session in sessions) {
    if (session.podium) {
      onTheBox.add(session);
      podiumRegular.add(session);
    }
    if (!session.won) {
      streak = 0;
      continue;
    }
    firstWin.add(session);
    winner.add(session);
    dominator.add(session);
    streak++;
    hatTrick.reach(streak, session);

    final holeCount = session.holes.length;
    // D7: alone in the lead after every hole.
    if ([
      for (var n = 1; n <= holeCount; n++)
        session.soleFirstIn(session.standingsAfter(n)),
    ].every((alone) => alone)) {
      wireToWire.hit(session);
    }
    // D8: alone in last place at half-time (after hole n / 2 rounded down).
    if (session.soleLastIn(session.standingsAfter(holeCount ~/ 2))) {
      comeback.hit(session);
    }
    // D9: one stroke or one point ahead of the best other team.
    if (session.gapToRunnerUp() == 1) photoFinish.hit(session);
    // D10 (Q113): strictly behind the leader before the last hole.
    if (holeCount >= 2 &&
        session.positionIn(session.standingsAfter(holeCount - 1)) > 1) {
      holdUp.hit(session);
    }
  }

  return [
    firstWin,
    winner,
    dominator,
    hatTrick,
    onTheBox,
    podiumRegular,
    wireToWire,
    comeback,
    photoFinish,
    holdUp,
  ].results();
}
