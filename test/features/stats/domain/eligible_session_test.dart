import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/live/domain/live_session_snapshot.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';
import 'package:nuni/features/sessions/domain/session.dart';
import 'package:nuni/features/sessions/domain/session_kind.dart';
import 'package:nuni/features/sessions/domain/session_tag.dart';
import 'package:nuni/features/stats/domain/eligible_session.dart';

import 'stats_fixtures.dart';

void main() {
  group('isGameSession and isActivitySession (plan 29)', () {
    Session noScores(List<SessionTag> tags) => Session(
      id: 's',
      code: 'C',
      ownerId: 'u',
      status: SessionStatus.completed,
      tags: tags,
      createdAt: DateTime(2026),
    );

    test('a game has a scorecard, no training nor simulator', () {
      final game = individualSession(playerIds: ['a'], holes: const []).session;
      expect(isGameSession(game), isTrue);
      expect(
        isGameSession(game.copyWith(tags: [SessionTag.training])),
        isFalse,
      );
      expect(
        isGameSession(game.copyWith(tags: [SessionTag.associationLife])),
        isTrue,
      );
      expect(isGameSession(noScores([SessionTag.associationLife])), isFalse);
    });

    test('an activity: completed, 3 attendees, whatever its natures', () {
      LiveSessionSnapshot attended(int count, SessionStatus status) =>
          LiveSessionSnapshot(
            session: noScores([SessionTag.associationLife])
                .copyWith(status: status),
            members: const [],
            teams: [
              team('t', [for (var i = 0; i < count; i++) 'p']),
            ],
            playedHoles: const [],
          );
      expect(isActivitySession(attended(3, SessionStatus.completed)), isTrue);
      expect(isActivitySession(attended(2, SessionStatus.completed)), isFalse);
      expect(isActivitySession(attended(3, SessionStatus.live)), isFalse);
    });
  });

  final threeHoles = [
    hole(1, {'t-a': 3}),
    hole(2, {'t-a': 3}),
    hole(3, {'t-a': 3}),
  ];

  group('isEligibleSession', () {
    test('completed, 3 players, 3 holes: eligible', () {
      expect(
        isEligibleSession(
          individualSession(playerIds: ['a', 'b', 'c'], holes: threeHoles),
        ),
        isTrue,
      );
    });

    test('only 2 players: not eligible', () {
      expect(
        isEligibleSession(
          individualSession(playerIds: ['a', 'b'], holes: threeHoles),
        ),
        isFalse,
      );
    });

    test('only 2 played holes: not eligible', () {
      expect(
        isEligibleSession(
          individualSession(
            playerIds: ['a', 'b', 'c'],
            holes: threeHoles.take(2).toList(),
          ),
        ),
        isFalse,
      );
    });

    test('not completed: not eligible', () {
      for (final status in [SessionStatus.draft, SessionStatus.live]) {
        expect(
          isEligibleSession(
            individualSession(
              playerIds: ['a', 'b', 'c'],
              holes: threeHoles,
              status: status,
            ),
          ),
          isFalse,
        );
      }
    });

    test('players are counted, not teams (Q124)', () {
      final twoTeamsOfTwo = snapshot(
        kind: SessionKind.team,
        teams: [
          team('t1', ['a', 'b']),
          team('t2', ['c', 'd']),
        ],
        holes: threeHoles,
      );
      expect(sessionPlayerCount(twoTeamsOfTwo), 4);
      expect(isEligibleSession(twoTeamsOfTwo), isTrue);
    });

    test('a training or a simulator session never counts (plan 29, Q188)', () {
      final game = individualSession(
        playerIds: ['a', 'b', 'c'],
        holes: threeHoles,
      );
      for (final tag in [SessionTag.training, SessionTag.simulator]) {
        final tagged = LiveSessionSnapshot(
          session: game.session.copyWith(tags: [tag]),
          members: const [],
          teams: game.teams,
          playedHoles: game.playedHoles,
        );
        expect(isEligibleSession(tagged), isFalse, reason: '');
      }
      final tournament = LiveSessionSnapshot(
        session: game.session.copyWith(tags: [SessionTag.associationLife]),
        members: const [],
        teams: game.teams,
        playedHoles: game.playedHoles,
      );
      expect(isEligibleSession(tournament), isTrue);
    });
  });

  group('countsStrokes', () {
    test('individual Stroke Play, Match Play, Redistribution: strokes', () {
      for (final mode in [
        ScoringMode.strokePlay,
        ScoringMode.matchPlay,
        ScoringMode.redistribution,
      ]) {
        final session = individualSession(
          playerIds: ['a'],
          holes: const [],
          scoringMode: mode,
        ).session;
        expect(countsStrokes(session), isTrue, reason: '$mode');
      }
    });

    test('Free: points, not strokes', () {
      final session = individualSession(
        playerIds: ['a'],
        holes: const [],
        scoringMode: ScoringMode.free,
      ).session;
      expect(countsStrokes(session), isFalse);
    });

    test('team session: the score is the team\'s, not a player\'s (Q90)', () {
      final session = snapshot(
        kind: SessionKind.team,
        teams: const [],
        holes: const [],
      ).session;
      expect(countsStrokes(session), isFalse);
    });
  });

  test('sessionDate: the start, or the creation when never started', () {
    final started = individualSession(
      playerIds: ['a'],
      holes: const [],
      startedAt: DateTime(2026, 3, 4, 10),
    ).session;
    expect(sessionDate(started), DateTime(2026, 3, 4, 10));
    final neverStarted = started.copyWith(startedAt: null);
    expect(sessionDate(neverStarted), started.createdAt);
  });

  test('teamOf finds the player\'s team, or null', () {
    final s = individualSession(playerIds: ['a', 'b', 'c'], holes: threeHoles);
    expect(teamOf(s, 'b')?.id, 't-b');
    expect(teamOf(s, 'z'), isNull);
  });
}
