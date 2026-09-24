import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/championship/domain/championship_session_result.dart';
import 'package:nuni/features/live/domain/game_mode.dart';
import 'package:nuni/features/live/domain/live_session_snapshot.dart';
import 'package:nuni/features/live/domain/live_team.dart';
import 'package:nuni/features/live/domain/played_hole.dart';
import 'package:nuni/features/live/domain/team_standing.dart';
import 'package:nuni/features/sessions/domain/ranking_direction.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';
import 'package:nuni/features/sessions/domain/session.dart';
import 'package:nuni/features/sessions/domain/session_kind.dart';

TeamStanding _standing(String teamId, int position) => TeamStanding(
  teamId: teamId,
  position: position,
  totalStrokes: 0,
  totalPoints: null,
  holesScored: 0,
  holesTotal: 0,
);

Session _session({
  ScoringMode mode = ScoringMode.strokePlay,
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
);

LiveTeam _team(String id, List<String> playerIds) => LiveTeam(
  id: id,
  position: int.parse(id),
  players: [
    for (final playerId in playerIds)
      TeamPlayerName(playerId: playerId, name: 'Player $playerId'),
  ],
);

PlayedHole _hole(int position, Map<String, int> valueByTeamId) => PlayedHole(
  id: 'h$position',
  position: position,
  gameMode: GameMode.individual,
  par: 3,
  hole: const PlayedHoleGeo(
    id: 'hole',
    name: 'Hole',
    par: 3,
    startLat: 0,
    startLng: 0,
  ),
  scores: [
    for (final entry in valueByTeamId.entries)
      HoleScore(teamId: entry.key, value: entry.value),
  ],
);

void main() {
  group('sessionRankingPoints', () {
    test('a team at position p among n teams scores n - p + 1', () {
      final points = sessionRankingPoints([
        _standing('a', 1),
        _standing('b', 2),
        _standing('c', 3),
      ]);
      expect(points, {'a': 3, 'b': 2, 'c': 1});
    });

    test('last place never scores zero', () {
      final points = sessionRankingPoints([
        _standing('a', 1),
        _standing('b', 2),
      ]);
      expect(points['b'], 1);
    });

    test('tied teams (Q40) score the better shared position', () {
      final points = sessionRankingPoints([
        _standing('a', 1),
        _standing('b', 1),
        _standing('c', 3),
      ]);
      expect(points, {'a': 3, 'b': 3, 'c': 1});
    });
  });

  group('ChampionshipSessionResult.fromSnapshot', () {
    test('ranking points plus the fixed attendance point, per player', () {
      final result = ChampionshipSessionResult.fromSnapshot(
        LiveSessionSnapshot(
          session: _session(mode: ScoringMode.strokePlay),
          members: const [],
          teams: [
            _team('1', ['p1']),
            _team('2', ['p2']),
          ],
          playedHoles: [
            _hole(1, {'1': 3, '2': 5}),
          ],
        ),
      );

      // Stroke play, ascending: team 1 (fewer strokes) is 1st of 2 -> 2
      // ranking points + 1 attendance = 3. Team 2 is 2nd -> 1 + 1 = 2.
      expect(result.pointsByPlayerId, {'p1': 3, 'p2': 2});
      expect(result.sessionId, 's1');
    });

    test('Team mode (Q43): every teammate scores identically', () {
      final result = ChampionshipSessionResult.fromSnapshot(
        LiveSessionSnapshot(
          session: _session(mode: ScoringMode.strokePlay),
          members: const [],
          teams: [
            _team('1', ['p1', 'p2']),
            _team('2', ['p3']),
          ],
          playedHoles: [
            _hole(1, {'1': 3, '2': 5}),
          ],
        ),
      );

      expect(result.pointsByPlayerId['p1'], result.pointsByPlayerId['p2']);
      expect(result.pointsByPlayerId['p1'], 3);
      expect(result.pointsByPlayerId['p3'], 2);
    });
  });
}
