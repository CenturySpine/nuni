import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/sessions/domain/ranking_direction.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';
import 'package:nuni/features/sessions/domain/session.dart';
import 'package:nuni/features/sessions/domain/session_kind.dart';

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
        // Columns the client doesn't map, present on a raw realtime row.
        'location': null,
        'weather': null,
        'comment': null,
        'started_at': null,
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
    },
  );
}
