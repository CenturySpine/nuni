import 'package:nuni/features/live/domain/game_mode.dart';
import 'package:nuni/features/live/domain/live_session_snapshot.dart';
import 'package:nuni/features/live/domain/live_team.dart';
import 'package:nuni/features/live/domain/played_hole.dart';
import 'package:nuni/features/sessions/domain/ranking_direction.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';
import 'package:nuni/features/sessions/domain/session.dart';
import 'package:nuni/features/sessions/domain/session_kind.dart';

/// A team of [playerIds], named after them ("Player p1").
LiveTeam team(String id, List<String> playerIds) => LiveTeam(
  id: id,
  position: 1,
  players: [
    for (final playerId in playerIds)
      TeamPlayerName(playerId: playerId, name: 'Player $playerId'),
  ],
);

/// A played hole at [position] with [values] per team id. [holeId] null
/// makes it a free hole (plan 17).
PlayedHole hole(
  int position,
  Map<String, int> values, {
  int par = 3,
  String? holeId = 'hole-a',
  String? name,
}) => PlayedHole(
  id: 'ph-$position-${values.hashCode}',
  position: position,
  gameMode: GameMode.individual,
  par: par,
  hole: holeId == null
      ? null
      : PlayedHoleGeo(id: holeId, name: name ?? 'Hole $holeId', par: par),
  scores: [
    for (final entry in values.entries)
      HoleScore(teamId: entry.key, value: entry.value),
  ],
);

/// An individual session with one team per player (`t-` followed by the player id).
LiveSessionSnapshot individualSession({
  String id = 's1',
  required List<String> playerIds,
  required List<PlayedHole> holes,
  DateTime? startedAt,
  SessionStatus status = SessionStatus.completed,
  ScoringMode scoringMode = ScoringMode.strokePlay,
}) => snapshot(
  id: id,
  kind: SessionKind.individual,
  teams: [
    for (final p in playerIds) team('t-$p', [p]),
  ],
  holes: holes,
  startedAt: startedAt,
  status: status,
  scoringMode: scoringMode,
);

LiveSessionSnapshot snapshot({
  String id = 's1',
  required SessionKind kind,
  required List<LiveTeam> teams,
  required List<PlayedHole> holes,
  DateTime? startedAt,
  SessionStatus status = SessionStatus.completed,
  ScoringMode scoringMode = ScoringMode.strokePlay,
}) => LiveSessionSnapshot(
  session: Session(
    id: id,
    code: 'CODE',
    ownerId: 'u1',
    status: status,
    kind: kind,
    scoringMode: scoringMode,
    rankingDirection: scoringMode == ScoringMode.strokePlay
        ? RankingDirection.asc
        : RankingDirection.desc,
    createdAt: DateTime(2026, 1, 1),
    startedAt: startedAt ?? DateTime(2026, 1, 1),
  ),
  members: const [],
  teams: teams,
  playedHoles: holes,
);
