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

  /// Rank of their latest passage in chronological order (see [computeHoleStats]).
  int lastPassage = 0;
}

/// Computes [holeId]'s statistics from its sessions ([snapshots], any
/// order, as `hole_history` returns them), over all time or one [season].
/// Only eligible sessions count (Q117, Q123); the difference to par uses
/// each passage's own par (`played_holes.par`, plan 26).
HoleStats computeHoleStats(
  String holeId,
  List<LiveSessionSnapshot> snapshots, {
  String? season,
}) {
  final played = _playedSessions(holeId, snapshots, season);

  var passages = 0;
  var totalStrokes = 0;
  var totalToPar = 0;
  HoleRecord? record;
  final players = <String, _PlayerTally>{};
  final distribution = <int, int>{};

  // Oldest session first, then the order holes were played in it: a later
  // passage that equals the record takes it (Q94, revised 2026-09-24), so a
  // lucky birdie never locks it for good. Within one passage, alphabetical
  // order decides: nothing tells who holed out first.
  String? recordPassageId;
  // Chronological rank of each passage (a played hole of a session), for
  // "most recent" ties.
  var passageRank = 0;
  for (final snapshot in played) {
    if (!countsStrokes(snapshot.session)) continue;
    final date = sessionDate(snapshot.session);
    final holes = [
      for (final hole in snapshot.playedHoles)
        if (hole.hole?.id == holeId) hole,
    ]..sort((a, b) => a.position.compareTo(b.position));
    for (final hole in holes) {
      passageRank++;
      // Individual sessions: one player per team. Same hole, same strokes:
      // alphabetical order decides who is shown.
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
        players.putIfAbsent(player.playerId, () => _PlayerTally(player.name))
          ..passages += 1
          ..toPar += strokes - hole.par
          ..lastPassage = passageRank;
        if (record == null ||
            strokes < record.strokes ||
            (strokes == record.strokes && hole.id != recordPassageId)) {
          recordPassageId = hole.id;
          record = HoleRecord(
            playerId: player.playerId,
            name: player.name,
            strokes: strokes,
            date: date,
          );
        }
      }
    }
  }

  // Ties: the one who played the hole most recently takes the title (PO,
  // 2026-09-24, like the record: it rewards playing), then alphabetical order
  // within one passage. Averages compared by cross-multiplying, exactly.
  final contenders =
      [
        for (final entry in players.entries)
          if (entry.value.passages >= minHolePassages) entry,
      ]..sort((a, b) {
        final x = a.value;
        final y = b.value;
        final byAverage = (x.toPar * y.passages).compareTo(
          y.toPar * x.passages,
        );
        if (byAverage != 0) return byAverage;
        final byRecency = y.lastPassage.compareTo(x.lastPassage);
        return byRecency != 0 ? byRecency : compareNames(x.name, y.name);
      });
  final king = contenders.isEmpty
      ? null
      : HoleKing(
          playerId: contenders.first.key,
          name: contenders.first.value.name,
          passages: contenders.first.value.passages,
          averageToPar:
              contenders.first.value.toPar / contenders.first.value.passages,
        );

  final sortedStrokes = distribution.keys.toList()..sort();
  return HoleStats(
    sessions: played.length,
    passages: passages,
    averageStrokes: passages == 0 ? null : totalStrokes / passages,
    averageToPar: passages == 0 ? null : totalToPar / passages,
    record: record,
    king: king,
    distribution: {for (final s in sortedStrokes) s: distribution[s]!},
  );
}
