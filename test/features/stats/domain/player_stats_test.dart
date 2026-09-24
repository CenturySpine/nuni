import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/live/domain/live_session_snapshot.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';
import 'package:nuni/features/sessions/domain/session_kind.dart';
import 'package:nuni/features/stats/domain/player_stats.dart';

import 'stats_fixtures.dart';

/// Three par-3 holes of the same directory hole, one value per player.
LiveSessionSnapshot _threeHoles(
  String id,
  Map<String, List<int>> strokesByPlayer, {
  DateTime? startedAt,
  ScoringMode scoringMode = ScoringMode.strokePlay,
}) => individualSession(
  id: id,
  playerIds: strokesByPlayer.keys.toList(),
  startedAt: startedAt,
  scoringMode: scoringMode,
  holes: [
    for (var i = 0; i < 3; i++)
      hole(i + 1, {
        for (final entry in strokesByPlayer.entries)
          't-${entry.key}': entry.value[i],
      }),
  ],
);

void main() {
  group('key figures and par report', () {
    // s1: a ties b for first (9 strokes each) -- a win, ties included.
    // s2: a is second -- a podium. s3 has 2 holes only: ignored.
    final s1 = _threeHoles('s1', {
      'a': [2, 3, 4],
      'b': [3, 3, 3],
      'c': [5, 5, 5],
    });
    final s2 = _threeHoles('s2', {
      'a': [4, 4, 4],
      'b': [3, 3, 3],
      'c': [5, 5, 5],
    });
    final s3 = individualSession(
      id: 's3',
      playerIds: ['a', 'b', 'c'],
      holes: [
        hole(1, {'t-a': 1, 't-b': 5, 't-c': 5}),
        hole(2, {'t-a': 1, 't-b': 5, 't-c': 5}),
      ],
    );
    final stats = computePlayerStats('a', [s2, s3, s1]);

    test('only eligible sessions count', () {
      expect(stats.sessionsPlayed, 2);
      expect(stats.holesPlayed, 6);
    });

    test('a shared first place is a win; places 1 to 3 are podiums', () {
      expect(stats.wins, 1);
      expect(stats.podiums, 2);
    });

    test('average to par and split', () {
      final report = stats.parReport!;
      expect(report.holes, 6);
      expect(report.averageToPar, 0.5);
      expect(report.birdieOrBetter, 1);
      expect(report.pars, 1);
      expect(report.bogeyOrWorse, 4);
    });

    test('a session without the player changes nothing', () {
      final other = _threeHoles('s4', {
        'x': [1, 1, 1],
        'y': [2, 2, 2],
        'z': [3, 3, 3],
      });
      final withOther = computePlayerStats('a', [s1, s2, other]);
      expect(withOther.sessionsPlayed, 2);
      expect(withOther.parReport!.holes, 6);
    });
  });

  test('a hole without the player\'s score is not a played hole', () {
    final s = individualSession(
      playerIds: ['a', 'b', 'c'],
      holes: [
        hole(1, {'t-a': 3, 't-b': 3, 't-c': 3}),
        hole(2, {'t-b': 3, 't-c': 3}),
        hole(3, {'t-a': 4, 't-b': 3, 't-c': 3}),
      ],
    );
    final stats = computePlayerStats('a', [s]);
    expect(stats.holesPlayed, 2);
    expect(stats.parReport!.holes, 2);
    expect(stats.parReport!.averageToPar, 0.5);
  });

  test('Free scoring: sessions and wins, no strokes', () {
    final s = _threeHoles('s1', {
      'a': [9, 9, 9],
      'b': [1, 1, 1],
      'c': [2, 2, 2],
    }, scoringMode: ScoringMode.free);
    final stats = computePlayerStats('a', [s]);
    expect(stats.sessionsPlayed, 1);
    expect(stats.wins, 1, reason: 'Free ranks highest points first here');
    expect(stats.parReport, isNull);
    expect(stats.curve, isEmpty);
    expect(stats.bestHole, isNull);
  });

  test('a free hole counts against par but is never the best hole', () {
    final s = individualSession(
      playerIds: ['a', 'b', 'c'],
      holes: [
        for (var i = 1; i <= 3; i++)
          hole(i, {'t-a': 1, 't-b': 3, 't-c': 3}, holeId: null),
        for (var i = 4; i <= 6; i++)
          hole(i, {'t-a': 3, 't-b': 3, 't-c': 3}, holeId: 'h1'),
      ],
    );
    final stats = computePlayerStats('a', [s]);
    expect(stats.parReport!.holes, 6);
    expect(stats.parReport!.birdieOrBetter, 3);
    expect(stats.bestHole!.holeId, 'h1');
  });

  test('par of the played hole, not the directory hole', () {
    final s = individualSession(
      playerIds: ['a', 'b', 'c'],
      holes: [
        for (var i = 1; i <= 3; i++)
          hole(i, {'t-a': 4, 't-b': 4, 't-c': 4}, par: 4),
      ],
    );
    final stats = computePlayerStats('a', [s]);
    expect(stats.parReport!.averageToPar, 0);
    expect(stats.parReport!.pars, 3);
  });

  group('best and worst hole', () {
    /// One session where player "a" plays each (hole id, name, strokes)
    /// in order, on par-3 holes.
    LiveSessionSnapshot onHoles(List<(String, String, int)> passages) =>
        individualSession(
          playerIds: ['a', 'b', 'c'],
          holes: [
            for (var i = 0; i < passages.length; i++)
              hole(
                i + 1,
                {'t-a': passages[i].$3, 't-b': 3, 't-c': 3},
                holeId: passages[i].$1,
                name: passages[i].$2,
              ),
          ],
        );

    test('lowest and highest average to par, from 3 passages', () {
      final stats = computePlayerStats('a', [
        onHoles([
          for (var i = 0; i < 3; i++) ('h1', 'Bench', 2),
          for (var i = 0; i < 3; i++) ('h2', 'Stairs', 5),
          for (var i = 0; i < 3; i++) ('h3', 'Fountain', 3),
        ]),
      ]);
      expect(stats.bestHole!.name, 'Bench');
      expect(stats.bestHole!.averageToPar, -1);
      expect(stats.worstHole!.name, 'Stairs');
      expect(stats.worstHole!.averageToPar, 2);
    });

    test('a hole played fewer than 3 times is left out (Q93)', () {
      final stats = computePlayerStats('a', [
        onHoles([
          ('gauss', 'Gauss', 10),
          ('gauss', 'Gauss', 10),
          ('lucky', 'Lucky', 1),
          for (var i = 0; i < 3; i++) ('h1', 'Bench', 3),
          for (var i = 0; i < 3; i++) ('h2', 'Stairs', 4),
        ]),
      ]);
      expect(stats.bestHole!.name, 'Bench');
      expect(stats.worstHole!.name, 'Stairs');
      expect(
        stats.parReport!.holes,
        9,
        reason: 'every hole still counts against par',
      );
    });

    test('no hole played 3 times: no best, no worst', () {
      final stats = computePlayerStats('a', [
        onHoles([('h1', 'Bench', 2), ('h1', 'Bench', 2), ('h2', 'Stairs', 5)]),
      ]);
      expect(stats.parReport, isNotNull);
      expect(stats.bestHole, isNull);
      expect(stats.worstHole, isNull);
    });

    test('ties: the most played hole, then alphabetical order', () {
      final stats = computePlayerStats('a', [
        onHoles([
          for (var i = 0; i < 4; i++) ('z', 'Zinc', 3),
          for (var i = 0; i < 3; i++) ('b', 'Béton', 3),
          for (var i = 0; i < 3; i++) ('a', 'Acier', 3),
        ]),
      ]);
      expect(stats.bestHole!.name, 'Zinc');
      expect(stats.worstHole!.name, 'Zinc');

      final sameCount = computePlayerStats('a', [
        onHoles([
          for (var i = 0; i < 3; i++) ('b', 'Béton', 3),
          for (var i = 0; i < 3; i++) ('a', 'Acier', 3),
        ]),
      ]);
      expect(sameCount.bestHole!.name, 'Acier');
    });

    test('a single hole played 3 times: best, no worst', () {
      final s = _threeHoles('s1', {
        'a': [3, 4, 3],
        'b': [3, 3, 3],
        'c': [3, 3, 3],
      });
      final stats = computePlayerStats('a', [s]);
      expect(stats.bestHole!.passages, 3);
      expect(stats.worstHole, isNull);
    });
  });

  group('seasons (September to August) and all time', () {
    final august = _threeHoles('aug', {
      'a': [4, 4, 4],
      'b': [3, 3, 3],
      'c': [3, 3, 3],
    }, startedAt: DateTime(2026, 8, 31, 18));
    final september = _threeHoles('sep', {
      'a': [3, 3, 3],
      'b': [3, 3, 3],
      'c': [3, 3, 3],
    }, startedAt: DateTime(2026, 9, 1, 18));
    final october = _threeHoles('oct', {
      'a': [2, 3, 3],
      'b': [3, 3, 3],
      'c': [3, 3, 3],
    }, startedAt: DateTime(2026, 10, 1, 18));
    final history = [october, august, september];

    test('played seasons, most recent first', () {
      expect(playedSeasons('a', history), ['2026-2027', '2025-2026']);
      expect(playedSeasons('z', history), isEmpty);
    });

    test('all time: every session, curve in chronological order', () {
      final stats = computePlayerStats('a', history);
      expect(stats.sessionsPlayed, 3);
      expect(stats.curve.map((p) => p.sessionId), ['aug', 'sep', 'oct']);
    });

    test('one season: only its sessions, everywhere', () {
      final current = computePlayerStats('a', history, season: '2026-2027');
      expect(current.sessionsPlayed, 2);
      expect(current.holesPlayed, 6);
      expect(current.wins, 2, reason: 'sep ties, oct wins');
      expect(current.curve.map((p) => p.sessionId), ['sep', 'oct']);
      expect(current.curve.last.averageToPar, closeTo(-1 / 3, 1e-9));
      expect(current.parReport!.averageToPar, closeTo(-1 / 6, 1e-9));

      final previous = computePlayerStats('a', history, season: '2025-2026');
      expect(previous.sessionsPlayed, 1);
      expect(previous.wins, 0);
      expect(previous.curve.single.averageToPar, 1);
    });

    test('a season without sessions: empty statistics', () {
      final none = computePlayerStats('a', history, season: '2020-2021');
      expect(none.sessionsPlayed, 0);
      expect(none.curve, isEmpty);
    });
  });

  group('team sessions', () {
    LiveSessionSnapshot teamSession(
      String id, {
      required List<String> myTeam,
      required bool myTeamWins,
    }) => snapshot(
      id: id,
      kind: SessionKind.team,
      teams: [
        team('mine', myTeam),
        team('theirs', ['x', 'y']),
      ],
      holes: [
        for (var i = 1; i <= 3; i++)
          hole(i, {'mine': myTeamWins ? 2 : 4, 'theirs': 3}),
      ],
    );

    test('count for figures and team stats, never for strokes', () {
      final stats = computePlayerStats('a', [
        teamSession('s1', myTeam: ['a', 'b'], myTeamWins: true),
      ]);
      expect(stats.sessionsPlayed, 1);
      expect(stats.wins, 1);
      expect(stats.holesPlayed, 3);
      expect(stats.parReport, isNull);
      expect(stats.team!.sessions, 1);
      expect(stats.team!.wins, 1);
      expect(stats.team!.mostFrequentTeammate!.playerId, 'b');
    });

    test('no team session: no team stats', () {
      final s = _threeHoles('s1', {
        'a': [3, 3, 3],
        'b': [3, 3, 3],
        'c': [3, 3, 3],
      });
      expect(computePlayerStats('a', [s]).team, isNull);
    });

    test('most frequent teammate: most sessions, then alphabetical', () {
      final stats = computePlayerStats('a', [
        teamSession('s1', myTeam: ['a', 'c'], myTeamWins: false),
        teamSession('s2', myTeam: ['a', 'b'], myTeamWins: false),
        teamSession('s3', myTeam: ['a', 'c'], myTeamWins: false),
      ]);
      expect(stats.team!.mostFrequentTeammate!.playerId, 'c');
      expect(stats.team!.mostFrequentTeammate!.sessions, 2);

      final tied = computePlayerStats('a', [
        teamSession('s1', myTeam: ['a', 'c'], myTeamWins: false),
        teamSession('s2', myTeam: ['a', 'b'], myTeamWins: false),
      ]);
      expect(tied.team!.mostFrequentTeammate!.playerId, 'b');
    });

    test('best duo: 3 shared sessions and a win at least, best rate', () {
      final stats = computePlayerStats('a', [
        // b: 2 wins out of 3.
        teamSession('b1', myTeam: ['a', 'b'], myTeamWins: true),
        teamSession('b2', myTeam: ['a', 'b'], myTeamWins: true),
        teamSession('b3', myTeam: ['a', 'b'], myTeamWins: false),
        // c: 2 wins out of 2 -- better rate, but under 3 sessions.
        teamSession('c1', myTeam: ['a', 'c'], myTeamWins: true),
        teamSession('c2', myTeam: ['a', 'c'], myTeamWins: true),
        // d: 0 wins out of 4 -- no "best duo" without a win.
        for (var i = 0; i < 4; i++)
          teamSession('d$i', myTeam: ['a', 'd'], myTeamWins: false),
      ]);
      final duo = stats.team!.bestDuo!;
      expect(duo.playerId, 'b');
      expect(duo.wins, 2);
      expect(duo.sessions, 3);
      expect(stats.team!.mostFrequentTeammate!.playerId, 'd');
    });

    test('best duo ties: same rate, more shared sessions wins', () {
      final stats = computePlayerStats('a', [
        for (var i = 0; i < 3; i++)
          teamSession('b$i', myTeam: ['a', 'b'], myTeamWins: i == 0),
        for (var i = 0; i < 6; i++)
          teamSession('c$i', myTeam: ['a', 'c'], myTeamWins: i < 2),
      ]);
      expect(stats.team!.bestDuo!.playerId, 'c');
    });

    test('no qualifying duo: null', () {
      final stats = computePlayerStats('a', [
        teamSession('s1', myTeam: ['a', 'b'], myTeamWins: true),
      ]);
      expect(stats.team!.bestDuo, isNull);
    });
  });

  test('no eligible session: everything empty', () {
    final stats = computePlayerStats('a', const []);
    expect(stats.sessionsPlayed, 0);
    expect(stats.parReport, isNull);
    expect(stats.team, isNull);
    expect(stats.curve, isEmpty);
  });
}
