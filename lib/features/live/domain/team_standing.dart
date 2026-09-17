import '../../sessions/domain/ranking_direction.dart';
import '../../sessions/domain/scoring_mode.dart';
import 'live_team.dart';
import 'played_hole.dart';
import 'score_calculator.dart';

/// One team's accumulated result across every played hole (plan 08),
/// ranked against the others. [totalPoints] is null for Stroke Play, which
/// has no points concept -- ranking there uses [totalStrokes] alone.
class TeamStanding {
  const TeamStanding({
    required this.teamId,
    required this.position,
    required this.totalStrokes,
    required this.totalPoints,
    required this.holesScored,
    required this.holesTotal,
  });

  final String teamId;
  final int position;
  final int totalStrokes;
  final int? totalPoints;
  final int holesScored;
  final int holesTotal;

  bool get isComplete => holesScored == holesTotal;
}

typedef _Raw = ({
  String teamId,
  int totalStrokes,
  int? totalPoints,
  int holesScored,
});

/// Computes and ranks every team's standing from the session's played
/// holes (plan 08). The per-hole point split is transposed from LsgScores'
/// `SessionViewModel` standings logic (`calculateHolePoints`), with one
/// deliberate change: exactly-tied teams share a position ("positions ex
/// æquo affichées à égalité", plan 08) instead of each taking the next
/// consecutive number the way the old app did.
List<TeamStanding> computeStandings({
  required ScoringMode scoringMode,
  required RankingDirection rankingDirection,
  required List<LiveTeam> teams,
  required List<PlayedHole> playedHoles,
}) {
  final totalStrokes = {for (final t in teams) t.id: 0};
  final totalPoints = {for (final t in teams) t.id: 0};
  final holesScored = {for (final t in teams) t.id: 0};
  final needsPoints =
      scoringMode == ScoringMode.matchPlay ||
      scoringMode == ScoringMode.redistribution;

  for (final hole in playedHoles) {
    final values = hole.valueByTeamId;
    final points = needsPoints
        ? calculateHolePoints(scoringMode, values)
        : null;
    for (final entry in values.entries) {
      final teamId = entry.key;
      if (!totalStrokes.containsKey(teamId)) continue;
      totalStrokes[teamId] = totalStrokes[teamId]! + entry.value;
      holesScored[teamId] = holesScored[teamId]! + 1;
      if (scoringMode == ScoringMode.free) {
        totalPoints[teamId] = totalPoints[teamId]! + entry.value;
      } else if (points != null) {
        totalPoints[teamId] = totalPoints[teamId]! + (points[teamId] ?? 0);
      }
    }
  }

  final hasPoints = scoringMode != ScoringMode.strokePlay;
  final raw = [
    for (final team in teams)
      (
        teamId: team.id,
        totalStrokes: totalStrokes[team.id]!,
        totalPoints: hasPoints ? totalPoints[team.id] : null,
        holesScored: holesScored[team.id]!,
      ),
  ];

  return _rank(
    raw,
    holesTotal: playedHoles.length,
    scoringMode: scoringMode,
    rankingDirection: rankingDirection,
  );
}

List<TeamStanding> _rank(
  List<_Raw> raw, {
  required int holesTotal,
  required ScoringMode scoringMode,
  required RankingDirection rankingDirection,
}) {
  int primaryKey(_Raw r) =>
      scoringMode == ScoringMode.strokePlay ? r.totalStrokes : r.totalPoints!;

  // Stroke Play and Free (Q7b) rank on a direction of their own; Match Play
  // and Redistribution always rank highest-points-first (Q34).
  final ascending = switch (scoringMode) {
    ScoringMode.strokePlay => true,
    ScoringMode.free => rankingDirection == RankingDirection.asc,
    ScoringMode.matchPlay || ScoringMode.redistribution => false,
  };

  final sorted = [...raw]
    ..sort((a, b) {
      final primaryCompare = ascending
          ? primaryKey(a).compareTo(primaryKey(b))
          : primaryKey(b).compareTo(primaryKey(a));
      // Secondary key only orders the display among exactly-tied teams
      // (fewer strokes first, as LsgScores did) -- it never splits their
      // shared position, assigned below from the primary key alone.
      if (primaryCompare != 0) return primaryCompare;
      return a.totalStrokes.compareTo(b.totalStrokes);
    });

  final result = <TeamStanding>[];
  for (var i = 0; i < sorted.length; i++) {
    final r = sorted[i];
    final position = i == 0
        ? 1
        : (primaryKey(r) == primaryKey(sorted[i - 1])
              ? result[i - 1].position
              : i + 1);
    result.add(
      TeamStanding(
        teamId: r.teamId,
        position: position,
        totalStrokes: r.totalStrokes,
        totalPoints: r.totalPoints,
        holesScored: r.holesScored,
        holesTotal: holesTotal,
      ),
    );
  }
  return result;
}
