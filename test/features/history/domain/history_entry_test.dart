import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/history/domain/history_entry.dart';
import 'package:nuni/features/live/domain/live_session_snapshot.dart';
import 'package:nuni/features/live/domain/live_team.dart';
import 'package:nuni/features/sessions/domain/ranking_direction.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';
import 'package:nuni/features/sessions/domain/session.dart';
import 'package:nuni/features/sessions/domain/session_kind.dart';

void main() {
  // A completed session of the association with two teams (plan 26, Q129).
  final entry = HistoryEntry(
    LiveSessionSnapshot(
      session: Session(
        id: 's1',
        code: 'ABC123',
        ownerId: 'u1',
        status: SessionStatus.completed,
        kind: SessionKind.team,
        scoringMode: ScoringMode.strokePlay,
        rankingDirection: RankingDirection.asc,
        createdAt: DateTime(2026, 9, 24),
      ),
      members: const [],
      teams: const [
        LiveTeam(
          id: 't1',
          position: 1,
          players: [
            TeamPlayerName(playerId: 'p1', name: 'Alice'),
            TeamPlayerName(playerId: 'p2', name: 'Bob'),
          ],
        ),
        LiveTeam(
          id: 't2',
          position: 2,
          players: [TeamPlayerName(playerId: 'p3', name: 'Chloé')],
        ),
      ],
      playedHoles: const [],
    ),
  );

  test('playedBy is true for a player of any team', () {
    expect(entry.playedBy('p2'), isTrue);
    expect(entry.playedBy('p3'), isTrue);
  });

  test('playedBy is false for another player or no player', () {
    expect(entry.playedBy('p9'), isFalse);
    expect(entry.playedBy(null), isFalse);
  });
}
