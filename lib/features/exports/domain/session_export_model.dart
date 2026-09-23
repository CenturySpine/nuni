import '../../history/domain/history_entry.dart';
import '../../live/domain/game_mode.dart';
import '../../live/domain/live_team.dart';
import '../../live/domain/played_hole.dart';
import '../../live/domain/score_calculator.dart';
import '../../sessions/domain/scoring_mode.dart';

/// One played hole's column header in an export (plan 10).
class ExportHoleColumn {
  const ExportHoleColumn({
    required this.id,
    required this.position,
    this.holeName,
    required this.gameMode,
  });

  final String id;
  final int position;
  // Null for an unlabelled free hole (plan 17).
  final String? holeName;
  final GameMode gameMode;
}

/// One team's row in an export: its raw strokes and, where the scoring
/// mode has a points concept, its computed points, per played hole --
/// `null` for a hole it has no score on yet (shouldn't happen for a
/// completed session, but not assumed).
class ExportTeamRow {
  const ExportTeamRow({
    required this.teamId,
    required this.playerNames,
    required this.position,
    required this.totalStrokes,
    required this.totalPoints,
    required this.strokesByHoleId,
    required this.pointsByHoleId,
  });

  final String teamId;
  final String playerNames;
  final int position;
  final int totalStrokes;
  final int? totalPoints;
  final Map<String, int?> strokesByHoleId;
  final Map<String, int?> pointsByHoleId;
}

/// Pure data shaping for the PDF and image exports (plan 10): pulls a
/// [HistoryEntry]'s already-computed standings and played holes into a
/// table-ready shape, rows ordered by standing position. Rendering (PDF
/// layout, "carte de résultats" widget) is the caller's job -- this only
/// decides *what* goes where, so it can be unit-tested without touching the
/// `pdf` package or Flutter widgets.
class SessionExportModel {
  const SessionExportModel({
    required this.holes,
    required this.teams,
    required this.showStrokes,
    required this.showPoints,
  });

  final List<ExportHoleColumn> holes;
  final List<ExportTeamRow> teams;

  /// Stroke Play only has a strokes column (Q7, plan 08's precedent, "coups
  /// masqués en Stroke Play" -- there's no separate points concept to
  /// duplicate it against). Free has no strokes at all (Q7b: the entered
  /// value already is points).
  final bool showStrokes;
  final bool showPoints;
}

SessionExportModel buildExportModel(HistoryEntry entry) {
  final snapshot = entry.snapshot;
  final mode = snapshot.session.scoringMode;
  final showStrokes = mode != ScoringMode.free;
  final showPoints = mode != ScoringMode.strokePlay;

  final holes = [
    for (final ph in snapshot.playedHoles)
      ExportHoleColumn(
        id: ph.id,
        position: ph.position,
        holeName: ph.customName,
        gameMode: ph.gameMode,
      ),
  ];

  final teamById = {for (final t in snapshot.teams) t.id: t};
  final standingByTeamId = {for (final s in entry.standings) s.teamId: s};

  final teamRows = [
    for (final team in snapshot.teams)
      if (standingByTeamId[team.id] case final standing?)
        ExportTeamRow(
          teamId: team.id,
          playerNames: teamById[team.id]!.playerNames(),
          position: standing.position,
          totalStrokes: standing.totalStrokes,
          totalPoints: standing.totalPoints,
          strokesByHoleId: {
            for (final ph in snapshot.playedHoles)
              ph.id: ph.scoreFor(team.id)?.value,
          },
          pointsByHoleId: {
            for (final ph in snapshot.playedHoles)
              ph.id: _pointsFor(mode, ph, team.id),
          },
        ),
  ]..sort((a, b) => a.position.compareTo(b.position));

  return SessionExportModel(
    holes: holes,
    teams: teamRows,
    showStrokes: showStrokes,
    showPoints: showPoints,
  );
}

int? _pointsFor(ScoringMode mode, PlayedHole hole, String teamId) {
  final score = hole.scoreFor(teamId);
  if (score == null) return null;
  if (mode == ScoringMode.free) return score.value;
  if (mode != ScoringMode.matchPlay && mode != ScoringMode.redistribution) {
    return null;
  }
  return calculateHolePoints(mode, hole.valueByTeamId)[teamId];
}
