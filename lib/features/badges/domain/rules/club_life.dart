import '../../../live/domain/live_session_snapshot.dart';
import '../../../sessions/domain/session_tag.dart';
import '../../../stats/domain/eligible_session.dart';
import '../badge.dart';
import '../badge_facts.dart';
import 'tracker.dart';

/// L. Club life (plan 29): activity sessions attended -- completed, with at
/// least 3 attendees, whatever their natures (Q190) -- and trainings
/// organized (Q200). A training in the simulator counts for both L1 to L3
/// and L7; a game counts for L6 only when it's a game session (Q188).
List<BadgeResult> clubLifeBadges(BadgeFacts facts) {
  final training = [
    BadgeTracker(BadgeId.warmUp),
    BadgeTracker(BadgeId.studious),
    BadgeTracker(BadgeId.hardWorker),
  ];
  final clubEvents = [
    BadgeTracker(BadgeId.partyAnimal),
    BadgeTracker(BadgeId.clubSoul),
  ];
  final allRounder = BadgeTracker(BadgeId.allRounder);
  final virtualPlayer = BadgeTracker(BadgeId.virtualPlayer);
  final organized = [
    BadgeTracker(BadgeId.instructor),
    BadgeTracker(BadgeId.coach),
    BadgeTracker(BadgeId.headCoach),
  ];

  void reach(List<BadgeTracker> trackers, int count, LiveSessionSnapshot s) {
    for (final t in trackers) {
      t.reach(count, null, at: sessionDate(s.session), sessionId: s.session.id);
    }
  }

  var trainings = 0;
  var events = 0;
  final kinds = <Object>{};
  for (final snapshot in facts.activitySessions) {
    final session = snapshot.session;
    if (session.hasTag(SessionTag.training)) {
      reach(training, ++trainings, snapshot);
      kinds.add(SessionTag.training);
    }
    if (session.hasTag(SessionTag.associationLife)) {
      reach(clubEvents, ++events, snapshot);
      kinds.add(SessionTag.associationLife);
    }
    if (session.hasTag(SessionTag.simulator)) {
      reach([virtualPlayer], 1, snapshot);
    }
    if (isGameSession(session)) kinds.add(#game);
    reach([allRounder], kinds.length, snapshot);
  }

  var organizedTrainings = 0;
  for (final snapshot in facts.organizedSessions) {
    if (snapshot.session.hasTag(SessionTag.training)) {
      reach(organized, ++organizedTrainings, snapshot);
    }
  }

  return [
    ...training.results(),
    ...clubEvents.results(),
    allRounder.result(),
    virtualPlayer.result(),
    ...organized.results(),
  ];
}
