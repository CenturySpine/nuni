import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/badges/domain/badge.dart';
import 'package:nuni/features/badges/domain/badge_facts.dart';
import 'package:nuni/features/badges/domain/compute_badges.dart';
import 'package:nuni/features/badges/domain/contributions.dart';
import 'package:nuni/features/live/domain/live_session_snapshot.dart';
import 'package:nuni/features/sessions/domain/session.dart';
import 'package:nuni/features/sessions/domain/session_tag.dart';

import '../../stats/domain/stats_fixtures.dart';
import 'badges_test.dart' show game;

/// A session without scorecard (plan 29) attended by [attendees], owned by
/// [owner], with [tags].
LiveSessionSnapshot activity(
  String id,
  List<SessionTag> tags, {
  List<String> attendees = const ['p', 'x', 'y'],
  String owner = 'u-other',
  SessionStatus status = SessionStatus.completed,
  int day = 1,
}) => LiveSessionSnapshot(
  session: Session(
    id: id,
    code: 'CODE',
    ownerId: owner,
    status: status,
    tags: tags,
    createdAt: DateTime(2026, 1, day),
    startedAt: DateTime(2026, 1, day, 18),
  ),
  members: const [],
  teams: [team('t-$id', attendees)],
  playedHoles: const [],
);

/// [snapshot] with [tags] added.
LiveSessionSnapshot tagged(
  LiveSessionSnapshot snapshot,
  List<SessionTag> tags,
) => LiveSessionSnapshot(
  session: snapshot.session.copyWith(tags: tags),
  members: snapshot.members,
  teams: snapshot.teams,
  playedHoles: snapshot.playedHoles,
);

Map<BadgeId, BadgeResult> clubBadges(
  List<LiveSessionSnapshot> history, {
  List<LiveSessionSnapshot> created = const [],
}) => {
  for (final r in computeBadges(
    BadgeFacts(
      playerId: 'p',
      associationId: 'a1',
      history: history,
      userId: 'u-p',
      contributions: PlayerContributions(sessions: created),
    ),
  ))
    r.id: r,
};

void main() {
  test('a training counts from 3 attendees, not before (Q190)', () {
    final two = activity(
      't2',
      const [SessionTag.training],
      attendees: const ['p', 'x'],
    );
    final three = activity('t3', const [SessionTag.training]);
    expect(clubBadges([two])[BadgeId.warmUp]!.earned, isFalse);
    expect(clubBadges([three])[BadgeId.warmUp]!.earned, isTrue);
  });

  test('an unfinished training counts for nothing', () {
    final live = activity('t', const [
      SessionTag.training,
    ], status: SessionStatus.live);
    expect(clubBadges([live])[BadgeId.warmUp]!.earned, isFalse);
  });

  test('trainings add up to Studious (5) and Hard worker (10)', () {
    final five = [
      for (var i = 1; i <= 5; i++)
        activity('t$i', const [SessionTag.training], day: i),
    ];
    final results = clubBadges(five);
    expect(results[BadgeId.studious]!.earned, isTrue);
    expect(results[BadgeId.studious]!.sessionId, 't5');
    expect(results[BadgeId.hardWorker]!.progress, 5);
  });

  test('a training in the simulator counts for L1 and L7', () {
    final both = activity('ts', const [
      SessionTag.training,
      SessionTag.simulator,
    ]);
    final results = clubBadges([both]);
    expect(results[BadgeId.warmUp]!.earned, isTrue);
    expect(results[BadgeId.virtualPlayer]!.earned, isTrue);
  });

  test('club events: Party animal, then Soul of the club at 5', () {
    final events = [
      for (var i = 1; i <= 5; i++)
        activity('e$i', const [SessionTag.associationLife], day: i),
    ];
    expect(
      clubBadges(events.take(1).toList())[BadgeId.partyAnimal]!.earned,
      isTrue,
    );
    expect(clubBadges(events)[BadgeId.clubSoul]!.earned, isTrue);
  });

  test('All-rounder: a game, a training and a club event', () {
    final training = activity('t', const [SessionTag.training], day: 2);
    final dinner = activity('d', const [SessionTag.associationLife], day: 3);
    final aGame = game(id: 'g', at: DateTime(2026, 1, 4, 12));
    // A scored training is not a game (Q188).
    final scoredTraining = tagged(game(id: 'st'), const [SessionTag.training]);
    expect(
      clubBadges([
        training,
        dinner,
        scoredTraining,
      ])[BadgeId.allRounder]!.earned,
      isFalse,
    );
    final results = clubBadges([training, dinner, aGame]);
    expect(results[BadgeId.allRounder]!.earned, isTrue);
    expect(results[BadgeId.allRounder]!.sessionId, 'g');
  });

  test('trainings organized count, attended or not (Q200)', () {
    final mine = [
      for (var i = 1; i <= 5; i++)
        activity(
          'o$i',
          const [SessionTag.training],
          owner: 'u-p',
          attendees: const ['x', 'y', 'z'],
          day: i,
        ),
    ];
    final results = clubBadges(const [], created: mine);
    expect(results[BadgeId.instructor]!.earned, isTrue);
    expect(results[BadgeId.coach]!.earned, isTrue);
    expect(results[BadgeId.headCoach]!.earned, isFalse);
    // Someone else's training isn't mine to have organized.
    final theirs = activity('o', const [SessionTag.training]);
    expect(
      clubBadges(const [], created: [theirs])[BadgeId.instructor]!.earned,
      isFalse,
    );
  });

  test('a scored training or simulator session counts for no badge A to K', () {
    final history = [
      tagged(game(id: 'a'), const [SessionTag.training]),
      tagged(game(id: 'b'), const [SessionTag.simulator]),
    ];
    final results = clubBadges(history);
    expect(results[BadgeId.firstStart]!.earned, isFalse);
    expect(results[BadgeId.firstWin]!.earned, isFalse);
    // A Christmas tournament is still a game.
    final tournament = tagged(game(id: 'c'), const [
      SessionTag.associationLife,
    ]);
    expect(clubBadges([tournament])[BadgeId.firstStart]!.earned, isTrue);
  });
}
