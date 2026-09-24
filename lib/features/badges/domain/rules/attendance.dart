import '../badge.dart';
import '../badge_facts.dart';
import 'tracker.dart';

/// A. Attendance: sessions played (A1 to A6) and holes played (A7, A8).
List<BadgeResult> attendanceBadges(BadgeFacts facts) {
  final sessions = [
    for (final id in const [
      BadgeId.firstStart,
      BadgeId.regular,
      BadgeId.pillar,
      BadgeId.addict,
      BadgeId.streetLegend,
      BadgeId.centurion,
    ])
      BadgeTracker(id),
  ];
  final holes = [
    BadgeTracker(BadgeId.fiftyHoles),
    BadgeTracker(BadgeId.hundredHoles),
  ];
  for (final session in facts.sessions) {
    for (final t in sessions) {
      t.add(session);
    }
    for (final t in holes) {
      t.add(session, session.holesPlayed);
    }
  }
  return [...sessions.results(), ...holes.results()];
}
