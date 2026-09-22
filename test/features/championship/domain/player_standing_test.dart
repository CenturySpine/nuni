import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/championship/domain/championship_session_result.dart';
import 'package:nuni/features/championship/domain/player_standing.dart';

ChampionshipSessionResult _result(
  String sessionId,
  Map<String, int> pointsByPlayerId,
) => ChampionshipSessionResult(
  sessionId: sessionId,
  pointsByPlayerId: pointsByPlayerId,
  playerNameById: {for (final id in pointsByPlayerId.keys) id: 'Player $id'},
);

PlayerStanding _for(List<PlayerStanding> standings, String playerId) =>
    standings.firstWhere((s) => s.playerId == playerId);

void main() {
  group('seasonStandings', () {
    test('sums points and counts sessions across the whole season', () {
      final standings = seasonStandings([
        _result('s1', {'a': 3, 'b': 2}),
        _result('s2', {'a': 2, 'b': 3}),
        _result('s3', {'a': 2}),
      ]);

      expect(_for(standings, 'a').totalPoints, 7);
      expect(_for(standings, 'a').sessionsPlayed, 3);
      expect(_for(standings, 'b').totalPoints, 5);
      expect(_for(standings, 'b').sessionsPlayed, 2);
    });

    test('ranks by total points descending', () {
      final standings = seasonStandings([
        _result('s1', {'a': 5, 'b': 3}),
      ]);

      expect(_for(standings, 'a').position, 1);
      expect(_for(standings, 'b').position, 2);
    });

    test(
      'Q45: equal points broken by sessions played -- more present wins',
      () {
        final standings = seasonStandings([
          _result('s1', {'a': 3, 'b': 2}),
          _result('s2', {'b': 1}),
        ]);
        // a: 3 pts / 1 session -- b: 3 pts / 2 sessions.
        expect(_for(standings, 'a').totalPoints, 3);
        expect(_for(standings, 'b').totalPoints, 3);
        expect(_for(standings, 'b').position, 1);
        expect(_for(standings, 'a').position, 2);
      },
    );

    test('Q45: equal points and equal sessions played -- ex aequo', () {
      final standings = seasonStandings([
        _result('s1', {'a': 3, 'b': 3}),
      ]);

      expect(_for(standings, 'a').position, 1);
      expect(_for(standings, 'b').position, 1);
    });

    test('a player absent from a session simply doesn\'t count it', () {
      final standings = seasonStandings([
        _result('s1', {'a': 3, 'b': 2}),
        _result('s2', {'a': 2}),
      ]);

      expect(_for(standings, 'b').sessionsPlayed, 1);
    });
  });
}
