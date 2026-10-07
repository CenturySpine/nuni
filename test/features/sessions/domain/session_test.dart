import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/sessions/domain/ranking_direction.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';
import 'package:nuni/features/sessions/domain/session.dart';
import 'package:nuni/features/sessions/domain/session_kind.dart';
import 'package:nuni/features/sessions/domain/session_tag.dart';

void main() {
  test(
    'Session.fromJson reads a "sessions" row, ignoring unmapped columns',
    () {
      final session = Session.fromJson({
        'id': 's1',
        'code': 'ABC123',
        'owner_id': 'u1',
        'status': 'draft',
        'kind': 'team',
        'scoring_mode': 'stroke_play',
        'ranking_direction': 'asc',
        'city': 'Paris',
        'zone': 'Rive gauche',
        'location_lat': 45.75,
        'location_lng': 4.85,
        'created_at': '2026-09-16T10:00:00Z',
        'started_at': null,
        'ended_at': null,
        // Columns the client doesn't map, present on a raw realtime row.
        'location': null,
        'weather': null,
        'comment': null,
      });

      expect(session.id, 's1');
      expect(session.code, 'ABC123');
      expect(session.ownerId, 'u1');
      expect(session.status, SessionStatus.draft);
      expect(session.kind, SessionKind.team);
      expect(session.scoringMode, ScoringMode.strokePlay);
      expect(session.rankingDirection, RankingDirection.asc);
      expect(session.city, 'Paris');
      expect(session.zone, 'Rive gauche');
      expect(session.locationLat, 45.75);
      expect(session.locationLng, 4.85);
    },
  );

  test('a session without scorecard reads its tags (plan 29)', () {
    final session = Session.fromJson({
      'id': 's2',
      'code': 'XYZ789',
      'owner_id': 'u1',
      'status': 'completed',
      'kind': null,
      'scoring_mode': null,
      'ranking_direction': null,
      'tags': ['training', 'association_life'],
      'created_at': '2026-09-16T10:00:00Z',
    });

    expect(session.hasScoring, isFalse);
    expect(session.kind, isNull);
    expect(session.tags, [SessionTag.training, SessionTag.associationLife]);
    expect(session.hasTag(SessionTag.simulator), isFalse);
  });

  test('a plain row without tags is a course, untagged', () {
    final session = Session.fromJson({
      'id': 's3',
      'code': 'ABC123',
      'owner_id': 'u1',
      'status': 'draft',
      'kind': 'individual',
      'scoring_mode': 'free',
      'ranking_direction': 'desc',
      'created_at': '2026-09-16T10:00:00Z',
    });
    expect(session.hasScoring, isTrue);
    expect(session.tags, isEmpty);
    // A row without the column (a `session_snapshot`) is published.
    expect(session.published, isTrue);
  });

  test('a draft reads published = false (plan 37)', () {
    final session = Session.fromJson({
      'id': 's4',
      'code': 'DRF123',
      'owner_id': 'u1',
      'status': 'draft',
      'published': false,
      'created_at': '2026-10-07T10:00:00Z',
      'tags': ['training'],
    });
    expect(session.published, isFalse);
    expect(session.status, SessionStatus.draft);
  });
}
