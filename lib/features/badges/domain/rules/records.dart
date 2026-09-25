import '../../../live/domain/live_session_snapshot.dart';
import '../../../stats/domain/eligible_session.dart';
import '../../../stats/domain/hole_stats.dart';
import '../badge.dart';
import '../badge_facts.dart';
import 'tracker.dart';

/// The record holder and king of one hole right after one of its passages.
typedef _HoleState = ({
  LiveSessionSnapshot snapshot,
  int position,
  String holeId,
  String? recordHolder,
  String? king,
});

/// One more session where I kept my record on a hole, and the series
/// reached there (Rampart, Q144).
typedef _Defence = ({LiveSessionSnapshot snapshot, int series});

/// J. Hole records, all time only (Q136): every hole the player played is
/// replayed with the rules of its sheet ([HoleReplay], plan 20), and a
/// title held once -- or lost once (Q142) -- is a badge kept for life
/// (Q111).
List<BadgeResult> recordBadges(BadgeFacts facts) {
  final recordHolder = BadgeTracker(BadgeId.recordHolder);
  final recordCollector = BadgeTracker(BadgeId.recordCollector);
  final recordHunter = BadgeTracker(BadgeId.recordHunter);
  var recordsTaken = 0;
  final holeKing = BadgeTracker(BadgeId.holeKing);
  final fallenRecord = BadgeTracker(BadgeId.fallenRecord);
  final dethroned = BadgeTracker(BadgeId.dethroned);
  final regicide = BadgeTracker(BadgeId.regicide);
  final rampart = BadgeTracker(BadgeId.rampart);
  final confidence = BadgeTracker(BadgeId.confidence);
  // Sessions without me where my record held (Q145).
  final withstood = <LiveSessionSnapshot>[];
  final me = facts.playerId;

  final states = <_HoleState>[];
  final defences = <_Defence>[];
  for (final holeId in facts.playedHoleIds) {
    final replay = HoleReplay();
    final passages = holePassages(holeId, facts.holesHistory);
    // Rampart (Q144): my record kept at the end of consecutive sessions
    // where the hole is played, counted after the one that took it. A
    // session without me breaks the series (any association's, Q95);
    // team and Free sessions set no record and are skipped (Q90).
    String? holderBefore;
    var series = 0;
    var passagesBefore = 0;
    for (final (i, passage) in passages.indexed) {
      replay.play(passage);
      final snapshot = passage.snapshot;
      states.add((
        snapshot: snapshot,
        position: passage.hole.position,
        holeId: holeId,
        recordHolder: replay.record?.playerId,
        king: replay.king?.playerId,
      ));
      final sessionEnds =
          i == passages.length - 1 ||
          passages[i + 1].snapshot.session.id != snapshot.session.id;
      if (!sessionEnds) continue;
      final holder = replay.record?.playerId;
      final withMe = teamOf(snapshot, me) != null;
      if (holder == me && holderBefore == me && withMe) {
        series++;
        defences.add((snapshot: snapshot, series: series));
      } else {
        series = 0;
      }
      // Confidence (Q145): my record held through a session without me
      // where someone scored on the hole.
      if (holder == me &&
          holderBefore == me &&
          !withMe &&
          replay.passages > passagesBefore) {
        withstood.add(snapshot);
      }
      holderBefore = holder;
      passagesBefore = replay.passages;
    }
  }
  // Oldest first, so the badge is earned on the first series to reach 3,
  // whatever the hole.
  defences.sort(
    (a, b) =>
        sessionDate(a.snapshot.session)
            .compareTo(sessionDate(b.snapshot.session)),
  );
  // No link to the session: I wasn't in it, it may be another
  // association's.
  withstood.sort(
    (a, b) => sessionDate(a.session).compareTo(sessionDate(b.session)),
  );
  for (final snapshot in withstood) {
    confidence.reach(1, null, at: sessionDate(snapshot.session));
  }
  for (final (:snapshot, :series) in defences) {
    rampart.reach(
      series,
      null,
      at: sessionDate(snapshot.session),
      sessionId: snapshot.session.id,
    );
  }
  // Every hole's passages merged in chronological order, for the records
  // held at the same time (J2).
  states.sort((a, b) {
    final byDate = sessionDate(a.snapshot.session)
        .compareTo(sessionDate(b.snapshot.session));
    if (byDate != 0) return byDate;
    final bySession = a.snapshot.session.id.compareTo(b.snapshot.session.id);
    return bySession != 0 ? bySession : a.position.compareTo(b.position);
  });

  final held = <String>{};
  final reigning = <String>{};
  // Each hole's king before the current state.
  final kings = <String, String?>{};
  for (final state in states) {
    final at = sessionDate(state.snapshot.session);
    // A title can change hands in a session the player wasn't in (another
    // player's bad passage makes them king): no link to it then.
    final sessionId = teamOf(state.snapshot, me) != null
        ? state.snapshot.session.id
        : null;
    if (state.recordHolder == me) {
      // A record taken (Q143): the hole's first, one equalled later or one
      // beaten -- not my own record improved or equalled again.
      if (held.add(state.holeId)) {
        recordsTaken++;
        recordHunter.reach(recordsTaken, null, at: at, sessionId: sessionId);
      }
      recordHolder.reach(1, null, at: at, sessionId: sessionId);
    } else if (held.remove(state.holeId)) {
      fallenRecord.reach(1, null, at: at, sessionId: sessionId);
    }
    recordCollector.reach(held.length, null, at: at, sessionId: sessionId);
    final previousKing = kings[state.holeId];
    kings[state.holeId] = state.king;
    if (state.king == me) {
      reigning.add(state.holeId);
      holeKing.reach(1, null, at: at, sessionId: sessionId);
      // The title taken from another king -- not a first king (Q142).
      if (previousKing != null && previousKing != me) {
        regicide.reach(1, null, at: at, sessionId: sessionId);
      }
    } else if (reigning.remove(state.holeId)) {
      dethroned.reach(1, null, at: at, sessionId: sessionId);
    }
  }
  return [
    recordHolder,
    recordCollector,
    recordHunter,
    rampart,
    confidence,
    holeKing,
    fallenRecord,
    dethroned,
    regicide,
  ].results();
}
