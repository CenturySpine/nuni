import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/sessions/domain/session_kind.dart';
import 'package:nuni/features/sessions/domain/session_member.dart';
import 'package:nuni/features/sessions/domain/team_composition.dart';

SessionMember _member(
  String userId, {
  String? teamId,
  MemberRole role = MemberRole.player,
}) =>
    SessionMember(sessionId: 's1', userId: userId, teamId: teamId, role: role);

void main() {
  group('drawRandomTeams', () {
    test('pairs every player exactly once', () {
      final pairs = drawRandomTeams([
        'a',
        'b',
        'c',
        'd',
        'e',
        'f',
      ], random: Random(1));

      expect(pairs, hasLength(3));
      expect(pairs.expand((pair) => pair).toSet(), {
        'a',
        'b',
        'c',
        'd',
        'e',
        'f',
      });
      for (final pair in pairs) {
        expect(pair, hasLength(2));
      }
    });

    test('is deterministic for a given seed', () {
      final first = drawRandomTeams(['a', 'b', 'c', 'd'], random: Random(42));
      final second = drawRandomTeams(['a', 'b', 'c', 'd'], random: Random(42));
      expect(first, second);
    });

    test('rejects an odd number of players', () {
      expect(
        () => drawRandomTeams(['a', 'b', 'c']),
        throwsA(isA<UnevenPlayerCountException>()),
      );
    });

    test('rejects fewer than 4 players even if even', () {
      expect(
        () => drawRandomTeams(['a', 'b']),
        throwsA(isA<NotEnoughPlayersException>()),
      );
    });
  });

  group('unassignedMembers', () {
    test('keeps only members without a team', () {
      final members = [_member('a', teamId: 't1'), _member('b'), _member('c')];
      expect(unassignedMembers(members).map((m) => m.userId), ['b', 'c']);
    });
  });

  group('canStartSession', () {
    test('individual needs at least one participant', () {
      expect(
        canStartSession(
          kind: SessionKind.individual,
          members: const [],
          teamCount: 0,
        ),
        isFalse,
      );
      expect(
        canStartSession(
          kind: SessionKind.individual,
          members: [_member('a')],
          teamCount: 0,
        ),
        isTrue,
      );
    });

    test('team is refused with no team at all', () {
      expect(
        canStartSession(
          kind: SessionKind.team,
          members: [_member('a')],
          teamCount: 0,
        ),
        isFalse,
      );
    });

    test('team is refused while a participant is unassigned (Q25)', () {
      expect(
        canStartSession(
          kind: SessionKind.team,
          members: [
            _member('a', teamId: 't1'),
            _member('b'),
          ],
          teamCount: 1,
        ),
        isFalse,
      );
    });

    test('team is allowed once everyone is assigned', () {
      expect(
        canStartSession(
          kind: SessionKind.team,
          members: [
            _member('a', teamId: 't1'),
            _member('b', teamId: 't1'),
          ],
          teamCount: 1,
        ),
        isTrue,
      );
    });
  });
}
