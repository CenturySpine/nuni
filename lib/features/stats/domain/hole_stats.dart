import '../../../core/text/compare_names.dart';
import '../../championship/domain/championship_season.dart';
import '../../live/domain/live_session_snapshot.dart';
import '../../live/domain/played_hole.dart';
import 'eligible_session.dart';
import 'player_stats.dart' show minHolePassages;

/// A hole's record (Q94, revised): the fewest strokes in one passage, and
/// who made it most recently.
class HoleRecord {
  const HoleRecord({
    required this.playerId,
    required this.name,
    required this.strokes,
    required this.date,
  });

  final String playerId;
  final String name;
  final int strokes;
  final DateTime date;
}

/// The "roi du trou": the best average difference to par on the hole among
/// players with at least [minHolePassages] passages (Q93, revised).
class HoleKing {
  const HoleKing({
    required this.playerId,
    required this.name,
    required this.passages,
    required this.averageToPar,
  });

  final String playerId;
  final String name;
  final int passages;
  final double averageToPar;
}

/// Everything the "Statistiques" section of a hole's sheet shows (plan 20).
/// [sessions] counts every eligible session the hole was played in, team
/// and Free ones included (how popular it is); everything else only counts
/// passages -- one player's strokes on it, where [countsStrokes] (Q90, Q94).
/// Averages and [record] are null without any passage; [king] is null until
/// a player reaches [minHolePassages].
class HoleStats {
  const HoleStats({
    required this.sessions,
    required this.passages,
    required this.averageStrokes,
    required this.averageToPar,
    required this.record,
    required this.king,
    required this.distribution,
  });

  final int sessions;
  final int passages;
  final double? averageStrokes;
  final double? averageToPar;
  final HoleRecord? record;
  final HoleKing? king;

  /// Passages per number of strokes, in increasing order of strokes.
  final Map<int, int> distribution;
}

/// The eligible sessions [holeId] was played in, oldest first; only those
/// of [season] when given.
List<LiveSessionSnapshot> _playedSessions(
  String holeId,
  List<LiveSessionSnapshot> snapshots,
  String? season,
) => [
  for (final snapshot in snapshots)
    if (isEligibleSession(snapshot) &&
        snapshot.playedHoles.any((h) => h.hole?.id == holeId) &&
        (season == null ||
            championshipSeasonFor(sessionDate(snapshot.session)) == season))
      snapshot,
]..sort((a, b) => sessionDate(a.session).compareTo(sessionDate(b.session)));

/// The seasons [holeId] was played in an eligible session, most recent
/// first: the choices of the season breakdown, next to "all time".
List<String> playedHoleSeasons(
  String holeId,
  List<LiveSessionSnapshot> snapshots,
) => {
  for (final snapshot in _playedSessions(holeId, snapshots, null))
    championshipSeasonFor(sessionDate(snapshot.session)),
}.toList()..sort((a, b) => b.compareTo(a));

class _PlayerTally {
  _PlayerTally(this.name);

  final String name;
  int passages = 0;
  int toPar = 0;

  /// Rank of their latest passage in chronological order (see [HoleReplay]).
  int lastPassage = 0;
}

/// One passage of a hole: a played hole of a session, where every player
/// may have a score.
typedef HolePassage = ({LiveSessionSnapshot snapshot, PlayedHole hole});

/// The passages of [holeId] that count strokes (Q90, Q94), in chronological
/// order: oldest session first, then the order holes were played in it.
/// Only eligible sessions, of [season] when given (Q117, Q123).
List<HolePassage> holePassages(
  String holeId,
  List<LiveSessionSnapshot> snapshots, {
  String? season,
}) => [
  for (final snapshot in _playedSessions(holeId, snapshots, season))
    if (countsStrokes(snapshot.session))
      for (final hole in [
        for (final hole in snapshot.playedHoles)
          if (hole.hole?.id == holeId) hole,
      ]..sort((a, b) => a.position.compareTo(b.position)))
        (snapshot: snapshot, hole: hole),
];

/// Replays one hole's passages in chronological order ([holePassages]),
/// applying the record and "roi du trou" rules after each one. The hole's
/// sheet reads the final state (plan 20), the "Records" badges every state
/// in between (plan 21, J1 to J3): both apply the same rules.
class HoleReplay {
  var passages = 0;
  var totalStrokes = 0;
  var totalToPar = 0;
  HoleRecord? _record;
  String? _recordPassageId;
  final _players = <String, _PlayerTally>{};

  /// Passages per number of strokes.
  final distribution = <int, int>{};

  // Chronological rank of each passage, for "most recent" ties.
  var _passageRank = 0;

  HoleRecord? get record => _record;

  /// Plays [passage], which must come after every passage played so far.
  void play(HolePassage passage) {
    final (:snapshot, :hole) = passage;
    final date = sessionDate(snapshot.session);
    _passageRank++;
    // Individual sessions: one player per team. Same hole, same strokes:
    // alphabetical order decides who is shown -- nothing tells who holed
    // out first.
    final entries = [
      for (final team in snapshot.teams)
        if (team.players.isNotEmpty)
          if (hole.scoreFor(team.id) case final score?)
            (team.players.first, score.value),
    ]..sort((a, b) => compareNames(a.$1.name, b.$1.name));
    for (final (player, strokes) in entries) {
      passages++;
      totalStrokes += strokes;
      totalToPar += strokes - hole.par;
      distribution[strokes] = (distribution[strokes] ?? 0) + 1;
      _players.putIfAbsent(player.playerId, () => _PlayerTally(player.name))
        ..passages += 1
        ..toPar += strokes - hole.par
        ..lastPassage = _passageRank;
      // A later passage that equals the record takes it (Q94, revised
      // 2026-09-24), so a lucky birdie never locks it for good.
      final record = _record;
      if (record == null ||
          strokes < record.strokes ||
          (strokes == record.strokes && hole.id != _recordPassageId)) {
        _recordPassageId = hole.id;
        _record = HoleRecord(
          playerId: player.playerId,
          name: player.name,
          strokes: strokes,
          date: date,
        );
      }
    }
  }

  /// The "roi du trou" now. Ties: the one who played the hole most
  /// recently takes the title (PO, 2026-09-24, like the record: it rewards
  /// playing), then alphabetical order within one passage. Averages
  /// compared by cross-multiplying, exactly.
  HoleKing? get king {
    _PlayerTally? best;
    String? bestId;
    for (final MapEntry(key: id, value: x) in _players.entries) {
      if (x.passages < minHolePassages) continue;
      final y = best;
      if (y != null) {
        final byAverage = (x.toPar * y.passages).compareTo(
          y.toPar * x.passages,
        );
        if (byAverage > 0) continue;
        if (byAverage == 0) {
          final byRecency = y.lastPassage.compareTo(x.lastPassage);
          if (byRecency > 0) continue;
          if (byRecency == 0 && compareNames(x.name, y.name) >= 0) continue;
        }
      }
      best = x;
      bestId = id;
    }
    if (best == null) return null;
    return HoleKing(
      playerId: bestId!,
      name: best.name,
      passages: best.passages,
      averageToPar: best.toPar / best.passages,
    );
  }
}

/// Computes [holeId]'s statistics from its sessions ([snapshots], any
/// order, as `holes_history` returns them), over all time or one [season].
/// Only eligible sessions count (Q117, Q123); the difference to par uses
/// each passage's own par (`played_holes.par`, plan 26).
HoleStats computeHoleStats(
  String holeId,
  List<LiveSessionSnapshot> snapshots, {
  String? season,
}) {
  final replay = HoleReplay();
  for (final passage in holePassages(holeId, snapshots, season: season)) {
    replay.play(passage);
  }
  final passages = replay.passages;
  final sortedStrokes = replay.distribution.keys.toList()..sort();
  return HoleStats(
    sessions: _playedSessions(holeId, snapshots, season).length,
    passages: passages,
    averageStrokes: passages == 0 ? null : replay.totalStrokes / passages,
    averageToPar: passages == 0 ? null : replay.totalToPar / passages,
    record: replay.record,
    king: replay.king,
    distribution: {for (final s in sortedStrokes) s: replay.distribution[s]!},
  );
}
