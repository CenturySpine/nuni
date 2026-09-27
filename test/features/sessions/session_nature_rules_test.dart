import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/sessions/domain/ranking_direction.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';
import 'package:nuni/features/sessions/domain/session.dart';
import 'package:nuni/features/sessions/domain/session_kind.dart';
import 'package:nuni/features/sessions/domain/session_tag.dart';
import 'package:nuni/features/sessions/ui/session_nature_rules.dart';
import 'package:nuni/l10n/generated/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final course = Session(
    id: 's',
    code: 'C',
    ownerId: 'u',
    status: SessionStatus.live,
    kind: SessionKind.individual,
    scoringMode: ScoringMode.strokePlay,
    rankingDirection: RankingDirection.asc,
    createdAt: DateTime(2026),
  );
  final noScores = Session(
    id: 's',
    code: 'C',
    ownerId: 'u',
    status: SessionStatus.completed,
    tags: const [SessionTag.training],
    createdAt: DateTime(2026),
  );

  String? lock(Session session, SessionTag tag, {bool isStaff = false}) =>
      sessionTagLock(l10n, session, tag, isStaff: isStaff);

  test('simulator is frozen with a scorecard, free without (Q197)', () {
    expect(lock(course, SessionTag.simulator), l10n.sessionsNatureFrozen);
    expect(lock(noScores, SessionTag.simulator), isNull);
  });

  test('club life is always free', () {
    expect(lock(course, SessionTag.associationLife), isNull);
    expect(
      lock(
        course.copyWith(status: SessionStatus.completed),
        SessionTag.associationLife,
      ),
      isNull,
    );
  });

  test('training with a scorecard: the organizer until completed, the staff '
      'always', () {
    final done = course.copyWith(status: SessionStatus.completed);
    expect(lock(course, SessionTag.training), isNull);
    expect(lock(done, SessionTag.training), l10n.sessionsNatureLocked);
    expect(lock(done, SessionTag.training, isStaff: true), isNull);
    expect(lock(noScores, SessionTag.training), isNull);
  });

  test('no training added to a championship session', () {
    final championship = course.copyWith(isChampionship: true);
    expect(
      lock(championship, SessionTag.training, isStaff: true),
      l10n.sessionsChampionshipFirst,
    );
  });
}
