import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/holes/domain/hole.dart';
import 'package:nuni/features/live/domain/game_mode.dart';
import 'package:nuni/features/live/domain/live_team.dart';
import 'package:nuni/features/live/domain/played_hole.dart';
import 'package:nuni/features/live/domain/team_standing.dart';
import 'package:nuni/features/sessions/domain/ranking_direction.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';

LiveTeam _team(String id) =>
    LiveTeam(id: id, position: int.parse(id), players: const []);

PlayedHole _hole(int position, Map<String, int> valueByTeamId) => PlayedHole(
  id: 'h$position',
  position: position,
  gameMode: GameMode.individual,
  hole: const PlayedHoleGeo(
    id: 'hole',
    name: 'Hole',
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

TeamStanding _standingFor(List<TeamStanding> standings, String teamId) =>
    standings.firstWhere((s) => s.teamId == teamId);

void main() {
  group('computeStandings - stroke play', () {
    test('ranks ascending by total strokes', () {
      final standings = computeStandings(
        scoringMode: ScoringMode.strokePlay,
        rankingDirection: RankingDirection.asc,
        teams: [_team('1'), _team('2'), _team('3')],
        playedHoles: [
          _hole(1, {'1': 4, '2': 5, '3': 4}),
          _hole(2, {'1': 3, '2': 3, '3': 5}),
        ],
      );

      expect(_standingFor(standings, '1').totalStrokes, 7);
      expect(_standingFor(standings, '1').totalPoints, isNull);
      expect(_standingFor(standings, '1').position, 1);
      expect(_standingFor(standings, '2').position, 2);
      expect(_standingFor(standings, '3').position, 3);
    });

    test('exactly tied teams share a position', () {
      final standings = computeStandings(
        scoringMode: ScoringMode.strokePlay,
        rankingDirection: RankingDirection.asc,
        teams: [_team('1'), _team('2')],
        playedHoles: [
          _hole(1, {'1': 4, '2': 4}),
          _hole(2, {'1': 4, '2': 4}),
        ],
      );

      expect(_standingFor(standings, '1').position, 1);
      expect(_standingFor(standings, '2').position, 1);
    });
  });

  group('computeStandings - match play', () {
    test('ranks descending by total points, strokes as tie-break order', () {
      final standings = computeStandings(
        scoringMode: ScoringMode.matchPlay,
        rankingDirection: RankingDirection.desc,
        teams: [_team('1'), _team('2'), _team('3')],
        playedHoles: [
          _hole(1, {'1': 2, '2': 5, '3': 4}), // 1 -> 1pt
          _hole(2, {'1': 3, '2': 3, '3': 4}), // tie -> 0pt all
        ],
      );

      expect(_standingFor(standings, '1').totalPoints, 1);
      expect(_standingFor(standings, '1').position, 1);
      // 2 and 3 both scored 0 points -- tied for 2nd regardless of strokes.
      expect(_standingFor(standings, '2').totalPoints, 0);
      expect(_standingFor(standings, '3').totalPoints, 0);
      expect(_standingFor(standings, '2').position, 2);
      expect(_standingFor(standings, '3').position, 2);
    });
  });

  group('computeStandings - free', () {
    test('highest wins when ranking_direction is desc', () {
      final standings = computeStandings(
        scoringMode: ScoringMode.free,
        rankingDirection: RankingDirection.desc,
        teams: [_team('1'), _team('2')],
        playedHoles: [
          _hole(1, {'1': 10, '2': 3}),
        ],
      );

      expect(_standingFor(standings, '1').totalPoints, 10);
      expect(_standingFor(standings, '1').position, 1);
      expect(_standingFor(standings, '2').position, 2);
    });

    test('lowest wins when ranking_direction is asc', () {
      final standings = computeStandings(
        scoringMode: ScoringMode.free,
        rankingDirection: RankingDirection.asc,
        teams: [_team('1'), _team('2')],
        playedHoles: [
          _hole(1, {'1': 10, '2': 3}),
        ],
      );

      expect(_standingFor(standings, '2').position, 1);
      expect(_standingFor(standings, '1').position, 2);
    });
  });

  group('computeStandings - incomplete scores', () {
    test('a team missing a score on a hole is not counted for it', () {
      final standings = computeStandings(
        scoringMode: ScoringMode.strokePlay,
        rankingDirection: RankingDirection.asc,
        teams: [_team('1'), _team('2')],
        playedHoles: [
          _hole(1, {'1': 4, '2': 4}),
          _hole(2, {'1': 3}),
        ],
      );

      final team1 = _standingFor(standings, '1');
      final team2 = _standingFor(standings, '2');
      expect(team1.holesScored, 2);
      expect(team1.isComplete, isTrue);
      expect(team2.holesScored, 1);
      expect(team2.holesTotal, 2);
      expect(team2.isComplete, isFalse);
    });
  });
}
