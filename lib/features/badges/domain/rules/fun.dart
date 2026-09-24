import '../badge.dart';
import '../badge_facts.dart';
import 'strokes.dart';
import 'tracker.dart';

/// K. Fun, in individual sessions (Q138): alone in last place (K1, K3), a first
/// "X" (K2, 10 strokes or more) and a birdie with an "X" in one session
/// (K4), strokes only where they are the player's own (Q90).
List<BadgeResult> funBadges(BadgeFacts facts) {
  final redLantern = BadgeTracker(BadgeId.redLantern);
  final adultsOnly = BadgeTracker(BadgeId.adultsOnly);
  final persistent = BadgeTracker(BadgeId.persistent);
  final rollerCoaster = BadgeTracker(BadgeId.rollerCoaster);
  final teamRedLantern = BadgeTracker(BadgeId.teamRedLantern);
  final teamPersistent = BadgeTracker(BadgeId.teamPersistent);

  // K1 and K3 in team sessions (Q141).
  for (final session in facts.teamSessions) {
    if (session.isLast) {
      teamRedLantern.hit(session);
      teamPersistent.add(session);
    }
  }

  for (final session in facts.individualSessions) {
    if (session.isLast) {
      redLantern.hit(session);
      persistent.add(session);
    }
    if (!session.valuesAreStrokes) continue;
    final scored = strokeHoles(session).nonNulls;
    final hasX = scored.any((h) => h.strokes >= xStrokes);
    if (hasX) adultsOnly.hit(session);
    if (hasX && scored.any((h) => h.strokes <= h.par - 1)) {
      rollerCoaster.hit(session);
    }
  }

  return [
    redLantern,
    adultsOnly,
    persistent,
    rollerCoaster,
    teamRedLantern,
    teamPersistent,
  ].results();
}
