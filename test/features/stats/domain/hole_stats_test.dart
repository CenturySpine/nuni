import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/live/domain/live_session_snapshot.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';
import 'package:nuni/features/sessions/domain/session.dart';
import 'package:nuni/features/sessions/domain/session_kind.dart';
import 'package:nuni/features/stats/domain/hole_stats.dart';

import 'stats_fixtures.dart';

/// An individual session where hole "hole-a" is played first with
/// [strokesByPlayer], followed by two other holes (so it is eligible).
LiveSessionSnapshot _session(
  String id,
  Map<String, int> strokesByPlayer, {
  DateTime? startedAt,
  int par = 3,
  ScoringMode scoringMode = ScoringMode.strokePlay,
  SessionStatus status = SessionStatus.completed,
}) {
  final values = {
    for (final entry in strokesByPlayer.entries) 't-${entry.key}': entry.value,
  };
  final filler = {for (final key in values.keys) key: 3};
  return individualSession(
    id: id,
    playerIds: strokesByPlayer.keys.toList(),
    startedAt: startedAt,
    scoringMode: scoringMode,
    status: status,
    holes: [
      hole(1, values, par: par),
      hole(2, filler, holeId: 'hole-b'),
      hole(3, filler, holeId: 'hole-c'),
    ],
  );
}

void main() {
  test('never played: empty statistics', () {
    final stats = computeHoleStats('hole-a', const []);
    expect(stats.sessions, 0);
    expect(stats.passages, 0);
    expect(stats.averageStrokes, isNull);
    expect(stats.record, isNull);
    expect(stats.king, isNull);
    expect(stats.distribution, isEmpty);
  });

  test('key figures use each passage own par', () {
    final stats = computeHoleStats('hole-a', [
      _session('s1', {'a': 3, 'b': 4, 'c': 5}),
      // Same hole played as a par 4 that day (plan 26).
      _session('s2', {'a': 4, 'b': 4, 'c': 4}, par: 4),
    ]);
    expect(stats.sessions, 2);
    expect(stats.passages, 6);
    expect(stats.averageStrokes, 4);
    // (0 + 1 + 2) + (0 + 0 + 0) over 6 passages.
    expect(stats.averageToPar, 0.5);
    expect(stats.distribution, {3: 1, 4: 4, 5: 1});
  });

  test('only eligible sessions count', () {
    final stats = computeHoleStats('hole-a', [
      _session('duel', {'a': 1, 'b': 2}),
      _session('live', {'a': 1, 'b': 2, 'c': 3}, status: SessionStatus.live),
      individualSession(
        id: 'short',
        playerIds: const ['a', 'b', 'c'],
        holes: [
          hole(1, {'t-a': 1, 't-b': 1, 't-c': 1}),
        ],
      ),
    ]);
    expect(stats.sessions, 0);
    expect(stats.record, isNull);
  });

  test('team and Free sessions count as sessions, not passages', () {
    final teamSession = snapshot(
      id: 'team',
      kind: SessionKind.team,
      teams: [
        team('t1', const ['a', 'b']),
        team('t2', const ['c', 'd']),
      ],
      holes: [
        hole(1, {'t1': 2, 't2': 3}),
        hole(2, {'t1': 2, 't2': 3}, holeId: 'hole-b'),
        hole(3, {'t1': 2, 't2': 3}, holeId: 'hole-c'),
      ],
    );
    final free = _session('free', {
      'a': 9,
      'b': 8,
      'c': 7,
    }, scoringMode: ScoringMode.free);
    final stats = computeHoleStats('hole-a', [teamSession, free]);
    expect(stats.sessions, 2);
    expect(stats.passages, 0);
    expect(stats.record, isNull);
  });

  test('record: fewest strokes, the most recent one takes it on a tie', () {
    final stats = computeHoleStats('hole-a', [
      _session('later', {
        'a': 2,
        'b': 4,
        'c': 4,
      }, startedAt: DateTime(2026, 3, 1)),
      _session('earlier', {
        'z': 2,
        'b': 3,
        'c': 3,
      }, startedAt: DateTime(2026, 2, 1)),
    ]);
    expect(stats.record?.playerId, 'a');
    expect(stats.record?.strokes, 2);
    expect(stats.record?.date, DateTime(2026, 3, 1));
  });

  test('record tie within one passage: alphabetical order', () {
    final stats = computeHoleStats('hole-a', [
      _session('s1', {'c': 2, 'b': 2, 'd': 4}),
    ]);
    expect(stats.record?.playerId, 'b');
  });

  test('a hole played twice in a session counts twice, in order', () {
    final session = individualSession(
      playerIds: const ['a', 'b', 'c'],
      holes: [
        hole(1, {'t-a': 4, 't-b': 3, 't-c': 3}),
        hole(2, {'t-a': 2, 't-b': 3, 't-c': 3}, holeId: 'hole-b'),
        hole(3, {'t-a': 2, 't-b': 2, 't-c': 3}),
      ],
    );
    final stats = computeHoleStats('hole-a', [session]);
    expect(stats.passages, 6);
    // b scored 3 on the first passage, but a and b both scored 2 on the
    // second: alphabetical order among the same passage.
    expect(stats.record?.playerId, 'a');
  });

  test('king: 3 passages minimum, best average', () {
    final sessions = [
      for (var i = 0; i < 3; i++)
        _session('s$i', {
          'a': 3,
          'b': 2,
          'c': 4,
        }, startedAt: DateTime(2026, 1, i + 1)),
      // d is excellent but played only twice.
      _session('d1', {'d': 1, 'a': 3, 'c': 3}),
      _session('d2', {'d': 1, 'a': 3, 'c': 3}),
    ];
    final stats = computeHoleStats('hole-a', sessions);
    expect(stats.king?.playerId, 'b');
    expect(stats.king?.passages, 3);
    expect(stats.king?.averageToPar, -1);
    expect(stats.record?.playerId, 'd');
  });

  test('king tie: the most recent player wins, even with fewer passages', () {
    final stats = computeHoleStats('hole-a', [
      for (var i = 0; i < 4; i++)
        _session('old$i', {
          'b': 3,
          'x': 5,
          'y': 5,
        }, startedAt: DateTime(2026, 1, i + 1)),
      for (var i = 0; i < 3; i++)
        _session('new$i', {
          'a': 3,
          'x': 5,
          'y': 5,
        }, startedAt: DateTime(2026, 2, i + 1)),
    ]);
    expect(stats.king?.playerId, 'a');
    expect(stats.king?.passages, 3);
  });

  test('king tie within the last passage: alphabetical order', () {
    final stats = computeHoleStats('hole-a', [
      for (var i = 0; i < 3; i++)
        _session('s$i', {
          'c': 3,
          'b': 3,
          'x': 5,
        }, startedAt: DateTime(2026, 1, i + 1)),
    ]);
    expect(stats.king?.playerId, 'b');
  });

  test('king tie: the latest passage decides', () {
    final stats = computeHoleStats('hole-a', [
      for (var i = 0; i < 4; i++)
        _session('s$i', {
          'a': 3,
          'b': 3,
          'x': 5,
          if (i == 3) 'a2': 9,
        }, startedAt: DateTime(2026, 1, i + 1)),
      _session('extra', {
        'b': 3,
        'x': 5,
        'y': 5,
      }, startedAt: DateTime(2026, 2, 1)),
    ]);
    expect(stats.king?.playerId, 'b');
    expect(stats.king?.passages, 5);
  });

  test('distribution keeps the X like any stroke count', () {
    final stats = computeHoleStats('hole-a', [
      _session('s1', {'a': 2, 'b': 3, 'c': 10}),
    ]);
    expect(stats.distribution, {2: 1, 3: 1, 10: 1});
    expect(stats.averageToPar, 2);
  });

  test('season breakdown', () {
    final snapshots = [
      _session('old', {
        'a': 2,
        'b': 3,
        'c': 3,
      }, startedAt: DateTime(2025, 5, 1)),
      _session('new', {
        'a': 4,
        'b': 4,
        'c': 4,
      }, startedAt: DateTime(2025, 10, 1)),
    ];
    expect(playedHoleSeasons('hole-a', snapshots), ['2025-2026', '2024-2025']);
    final season = computeHoleStats('hole-a', snapshots, season: '2025-2026');
    expect(season.sessions, 1);
    expect(season.record?.strokes, 4);
    expect(computeHoleStats('hole-a', snapshots).record?.strokes, 2);
  });

  test('another hole of the sessions has its own statistics', () {
    final stats = computeHoleStats('hole-b', [
      _session('s1', {'a': 2, 'b': 3, 'c': 3}),
    ]);
    expect(stats.passages, 3);
    expect(stats.distribution, {3: 3});
  });
}
