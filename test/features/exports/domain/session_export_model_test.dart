import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/exports/domain/session_export_model.dart';
import 'package:nuni/features/history/domain/history_entry.dart';
import 'package:nuni/features/holes/domain/hole.dart';
import 'package:nuni/features/live/domain/game_mode.dart';
import 'package:nuni/features/live/domain/live_session_snapshot.dart';
import 'package:nuni/features/live/domain/live_team.dart';
import 'package:nuni/features/live/domain/played_hole.dart';
import 'package:nuni/features/sessions/domain/ranking_direction.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';
import 'package:nuni/features/sessions/domain/session.dart';
import 'package:nuni/features/sessions/domain/session_kind.dart';

Session _session(
  ScoringMode mode, {
  RankingDirection direction = RankingDirection.asc,
}) => Session(
  id: 's1',
  code: 'ABC123',
  ownerId: 'u1',
  status: SessionStatus.completed,
  kind: SessionKind.team,
  scoringMode: mode,
  rankingDirection: direction,
  createdAt: DateTime(2026, 9, 16),
  startedAt: DateTime(2026, 9, 16, 10),
  endedAt: DateTime(2026, 9, 16, 12),
);

LiveTeam _team(String id, String name) => LiveTeam(
  id: id,
  position: int.parse(id),
  players: [TeamPlayerName(playerId: 'p$id', name: name)],
);

PlayedHole _hole(int position, String name, Map<String, int> valueByTeamId) =>
    PlayedHole(
      id: 'h$position',
      position: position,
      gameMode: GameMode.individual,
      hole: PlayedHoleGeo(
        id: 'hole$position',
        name: name,
        par: 3,
        startLat: 0,
        startLng: 0,
        visibility: HoleVisibility.public,
      ),
      scores: [
        for (final entry in valueByTeamId.entries)
          HoleScore(teamId: entry.key, value: entry.value),
      ],
    );

void main() {
  test('stroke play: strokes only, ordered by standing position', () {
    final entry = HistoryEntry(
      LiveSessionSnapshot(
        session: _session(ScoringMode.strokePlay),
        members: const [],
        teams: [_team('1', 'Alice'), _team('2', 'Bob')],
        playedHoles: [
          _hole(1, 'Radioactive', {'1': 5, '2': 3}),
          _hole(2, 'Le Manoir', {'1': 4, '2': 4}),
        ],
      ),
    );

    final model = buildExportModel(entry);

    expect(model.showStrokes, isTrue);
    expect(model.showPoints, isFalse);
    expect(model.holes.map((h) => h.holeName), ['Radioactive', 'Le Manoir']);
    // Bob (7 strokes) beats Alice (9) -- rows follow the standing, not
    // insertion order.
    expect(model.teams.map((t) => t.teamId), ['2', '1']);
    expect(model.teams[0].playerNames, 'Bob');
    expect(model.teams[0].totalStrokes, 7);
    expect(model.teams[0].totalPoints, isNull);
    expect(model.teams[0].strokesByHoleId, {'h1': 3, 'h2': 4});
    expect(model.teams[0].pointsByHoleId, {'h1': null, 'h2': null});
  });

  test('free mode: the entered value is the points, no strokes column', () {
    final entry = HistoryEntry(
      LiveSessionSnapshot(
        session: _session(ScoringMode.free, direction: RankingDirection.desc),
        members: const [],
        teams: [_team('1', 'Alice'), _team('2', 'Bob')],
        playedHoles: [
          _hole(1, 'Radioactive', {'1': 10, '2': 3}),
        ],
      ),
    );

    final model = buildExportModel(entry);

    expect(model.showStrokes, isFalse);
    expect(model.showPoints, isTrue);
    expect(model.teams[0].playerNames, 'Alice');
    expect(model.teams[0].totalPoints, 10);
    expect(model.teams[0].pointsByHoleId, {'h1': 10});
  });

  test('match play: strokes and computed points both shown', () {
    final entry = HistoryEntry(
      LiveSessionSnapshot(
        session: _session(
          ScoringMode.matchPlay,
          direction: RankingDirection.desc,
        ),
        members: const [],
        teams: [_team('1', 'Alice'), _team('2', 'Bob')],
        playedHoles: [
          _hole(1, 'Radioactive', {'1': 3, '2': 5}), // 1 wins the hole
        ],
      ),
    );

    final model = buildExportModel(entry);

    expect(model.showStrokes, isTrue);
    expect(model.showPoints, isTrue);
    final alice = model.teams.firstWhere((t) => t.teamId == '1');
    expect(alice.strokesByHoleId, {'h1': 3});
    expect(alice.pointsByHoleId, {'h1': 1});
    expect(alice.totalPoints, 1);
  });

  test('a hole a team has no score for shows a null cell, not zero', () {
    final entry = HistoryEntry(
      LiveSessionSnapshot(
        session: _session(ScoringMode.strokePlay),
        members: const [],
        teams: [_team('1', 'Alice'), _team('2', 'Bob')],
        playedHoles: [
          _hole(1, 'Radioactive', {'1': 4}),
        ],
      ),
    );

    final model = buildExportModel(entry);
    final bob = model.teams.firstWhere((t) => t.teamId == '2');
    expect(bob.strokesByHoleId, {'h1': null});
  });
}
