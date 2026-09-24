import '../badge.dart';
import '../badge_facts.dart';
import 'tracker.dart';

/// A score of 10 strokes or more (plan 21, "« X »").
const xStrokes = 10;

typedef StrokeHole = ({int strokes, int par});

/// The player's strokes and each played hole's par, in playing order, null
/// where they have no score.
List<StrokeHole?> strokeHoles(PlayedSession session) => [
  for (var i = 0; i < session.holes.length; i++)
    if (session.values[i] case final strokes?)
      (strokes: strokes, par: session.holes[i].par)
    else
      null,
];

/// The longest run of consecutive holes matching [test]; an unentered hole
/// breaks it (Q117).
int longestRun(List<StrokeHole?> holes, bool Function(StrokeHole) test) {
  var best = 0;
  var run = 0;
  for (final hole in holes) {
    if (hole != null && test(hole)) {
      run++;
      if (run > best) best = run;
    } else {
      run = 0;
    }
  }
  return best;
}

/// C. Strokes, in sessions where values are the player's strokes (Q90):
/// first par, birdie, eagle, albatross and hole in one (C1 to C5, "or
/// better": an eagle is also a birdie), birdies cumulated (C6, C7), and
/// feats within one session (C8 to C13).
List<BadgeResult> strokeBadges(BadgeFacts facts) {
  final onPar = BadgeTracker(BadgeId.onPar);
  final birdie = BadgeTracker(BadgeId.birdie);
  final eagle = BadgeTracker(BadgeId.eagle);
  final albatross = BadgeTracker(BadgeId.albatross);
  final holeInOne = BadgeTracker(BadgeId.holeInOne);
  final flock = BadgeTracker(BadgeId.birdieFlock);
  final swarm = BadgeTracker(BadgeId.birdieSwarm);
  final parStreak = BadgeTracker(BadgeId.parStreak);
  final hotHand = BadgeTracker(BadgeId.hotHand);
  final clean = BadgeTracker(BadgeId.clean);
  final underPar = BadgeTracker(BadgeId.underPar);
  final bounceBack = BadgeTracker(BadgeId.bounceBack);
  final steady = BadgeTracker(BadgeId.steady);

  for (final session in facts.sessions) {
    if (!session.valuesAreStrokes) continue;
    final holes = strokeHoles(session);
    final scored = holes.nonNulls.toList();
    if (scored.isEmpty) continue;

    var birdies = 0;
    for (final h in scored) {
      final toPar = h.strokes - h.par;
      if (toPar <= 0) onPar.hit(session);
      if (toPar <= -1) {
        birdie.hit(session);
        birdies++;
      }
      if (toPar <= -2) eagle.hit(session);
      if (toPar <= -3) albatross.hit(session);
      if (h.strokes == 1) holeInOne.hit(session);
    }
    flock.add(session, birdies);
    swarm.add(session, birdies);

    if (longestRun(holes, (h) => h.strokes <= h.par) >= 3) {
      parStreak.hit(session);
    }
    if (longestRun(holes, (h) => h.strokes <= h.par - 1) >= 3) {
      hotHand.hit(session);
    }
    if (scored.length >= 6 && scored.every((h) => h.strokes <= h.par)) {
      clean.hit(session);
    }
    final toPar = scored.fold(0, (sum, h) => sum + h.strokes - h.par);
    if (toPar < 0) underPar.hit(session);
    for (var i = 1; i < holes.length; i++) {
      final before = holes[i - 1];
      final after = holes[i];
      if (before != null &&
          after != null &&
          before.strokes >= before.par + 2 &&
          after.strokes <= after.par - 1) {
        bounceBack.hit(session);
      }
    }
    if (scored.length >= 6 &&
        scored.every((h) => (h.strokes - h.par).abs() <= 1)) {
      steady.hit(session);
    }
  }

  return [
    onPar,
    birdie,
    eagle,
    albatross,
    holeInOne,
    flock,
    swarm,
    parStreak,
    hotHand,
    clean,
    underPar,
    bounceBack,
    steady,
  ].results();
}
