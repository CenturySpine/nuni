import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/sessions/domain/other_sessions.dart';
import 'package:nuni/features/sessions/domain/session.dart';
import 'package:nuni/features/sessions/domain/session_member.dart';

Session _session(
  String id, {
  SessionStatus status = SessionStatus.draft,
  String? associationId = 'a2',
  int day = 1,
}) => Session(
  id: id,
  code: id.toUpperCase(),
  ownerId: 'u2',
  status: status,
  associationId: associationId,
  createdAt: DateTime.utc(2026, 10, day),
);

List<String> _ids(List<Session> sessions) => [for (final s in sessions) s.id];

void main() {
  group('otherSessionsForHome (plan 38, Q274)', () {
    test('keeps drafts, waiting rooms and live sessions, newest first', () {
      final others = otherSessionsForHome(
        [
          _session('waiting', day: 1),
          _session('live', status: SessionStatus.live, day: 3),
          _session('completed', status: SessionStatus.completed, day: 4),
        ],
        memberSessionIds: const {},
        myAssociationId: 'a1',
      );
      // Completed ones are the history's.
      expect(_ids(others), ['live', 'waiting']);
    });

    test('leaves out the ones I am a member of', () {
      final others = otherSessionsForHome(
        [_session('mine'), _session('theirs')],
        memberSessionIds: const {'mine'},
        myAssociationId: 'a1',
      );
      expect(_ids(others), ['theirs']);
    });

    test("leaves out my association's live ones, already on home", () {
      final others = otherSessionsForHome(
        [
          _session('followed', status: SessionStatus.live, associationId: 'a1'),
          // A waiting room of my association isn't on home (plan 26).
          _session('waiting_home', associationId: 'a1'),
          _session('live_elsewhere', status: SessionStatus.live),
        ],
        memberSessionIds: const {},
        myAssociationId: 'a1',
      );
      expect(_ids(others), unorderedEquals(['waiting_home', 'live_elsewhere']));
    });

    test('without an association, every live one is shown', () {
      final others = otherSessionsForHome(
        [_session('orphan', status: SessionStatus.live, associationId: null)],
        memberSessionIds: const {},
        myAssociationId: null,
      );
      expect(_ids(others), ['orphan']);
    });
  });

  group('isSuperAdminOutsider (plan 38, Q277)', () {
    test('a super_admin outside the session gets the banner', () {
      expect(isSuperAdminOutsider(isMember: false, isSuperAdmin: true), isTrue);
    });

    test('a super_admin taking part does not, nor anyone else', () {
      expect(isSuperAdminOutsider(isMember: true, isSuperAdmin: true), isFalse);
      expect(
        isSuperAdminOutsider(isMember: false, isSuperAdmin: false),
        isFalse,
      );
    });
  });
}
