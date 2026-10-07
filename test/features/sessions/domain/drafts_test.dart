import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/sessions/domain/drafts.dart';
import 'package:nuni/features/sessions/domain/session.dart';
import 'package:nuni/features/sessions/domain/session_member.dart';

Session _session(
  String id, {
  bool published = false,
  SessionStatus status = SessionStatus.draft,
  String associationId = 'a1',
  int day = 1,
}) => Session(
  id: id,
  code: id.toUpperCase(),
  ownerId: 'u1',
  status: status,
  associationId: associationId,
  published: published,
  createdAt: DateTime.utc(2026, 10, day),
);

void main() {
  group('offerableDrafts (plan 37, Q258)', () {
    test('keeps unpublished waiting rooms, most recent first', () {
      final drafts = offerableDrafts([
        _session('old', day: 1),
        _session('new', day: 5),
        _session('published', published: true, day: 6),
      ]);
      expect([for (final s in drafts) s.id], ['new', 'old']);
    });

    test('leaves out a draft no longer in its waiting room', () {
      // The base never lets a draft start (Q261); a stale row still
      // mustn't be offered.
      expect(
        offerableDrafts([_session('live', status: SessionStatus.live)]),
        isEmpty,
      );
    });

    test("from an event, only the event's association's drafts", () {
      final drafts = offerableDrafts([
        _session('mine', associationId: 'a1'),
        _session('elsewhere', associationId: 'a2'),
      ], eventAssociationId: 'a1');
      expect([for (final s in drafts) s.id], ['mine']);
    });
  });

  group('canOrganizeSession (plan 37, Q262)', () {
    test('the creator or a co-organizer organizes', () {
      expect(canOrganizeSession(MemberRole.owner, isSuperAdmin: false), isTrue);
    });

    test('a participant or a non-member does not', () {
      expect(
        canOrganizeSession(MemberRole.player, isSuperAdmin: false),
        isFalse,
      );
      expect(canOrganizeSession(null, isSuperAdmin: false), isFalse);
    });

    test('a super_admin organizes any session, member or not', () {
      expect(canOrganizeSession(null, isSuperAdmin: true), isTrue);
      expect(canOrganizeSession(MemberRole.player, isSuperAdmin: true), isTrue);
    });
  });
}
