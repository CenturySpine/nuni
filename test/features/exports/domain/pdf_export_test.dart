import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/exports/domain/pdf_export.dart';
import 'package:nuni/features/history/domain/history_entry.dart';
import 'package:nuni/features/live/domain/game_mode.dart';
import 'package:nuni/features/live/domain/live_session_snapshot.dart';
import 'package:nuni/features/live/domain/live_team.dart';
import 'package:nuni/features/live/domain/played_hole.dart';
import 'package:nuni/features/sessions/domain/ranking_direction.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';
import 'package:nuni/features/sessions/domain/session.dart';
import 'package:nuni/features/sessions/domain/session_kind.dart';

void main() {
  test('builds a one-page A4 PDF for a small session', () async {
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
          city: 'Lyon',
          createdAt: DateTime(2026, 9, 16),
          startedAt: DateTime(2026, 9, 16, 10),
          endedAt: DateTime(2026, 9, 16, 12),
        ),
        members: const [],
        teams: [
          LiveTeam(
            id: '1',
            position: 1,
            players: const [TeamPlayerName(playerId: 'p1', name: 'Alice')],
          ),
          LiveTeam(
            id: '2',
            position: 2,
            players: const [TeamPlayerName(playerId: 'p2', name: 'Bob')],
          ),
        ],
        playedHoles: [
          PlayedHole(
            id: 'h1',
            position: 1,
            gameMode: GameMode.individual,
            par: 3,
            hole: const PlayedHoleGeo(
              id: 'hole1',
              name: 'Radioactive',
              par: 3,
              startLat: 0,
              startLng: 0,
            ),
            scores: const [
              HoleScore(teamId: '1', value: 4),
              HoleScore(teamId: '2', value: 5),
            ],
          ),
        ],
      ),
    );

    final labels = const PdfExportLabels(
      title: 'Lyon',
      dateLine: '16 sept. 2026',
      durationLine: 'Durée : 2 h 0 min',
      scoringModeLine: 'Stroke Play',
      weatherLine: '18 °C, vent 10 km/h',
      comment: 'Une belle partie.',
      rankingTitle: 'Classement',
      strokesUnit: 'coups',
      pointsUnit: 'pts',
      footer: 'NUNI — Never Up, Never In',
      teamHeader: 'Équipe',
      totalHeader: 'Total',
    );

    final bytes = await buildSessionPdf(entry: entry, labels: labels);

    expect(bytes.length, greaterThan(500));
    // A real PDF file, not an error page or empty buffer.
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
