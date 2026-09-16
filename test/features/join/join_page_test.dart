import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuni/features/join/ui/join_page.dart';
import 'package:nuni/features/sessions/data/sessions_repository.dart';
import 'package:nuni/features/sessions/domain/ranking_direction.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';
import 'package:nuni/features/sessions/domain/session.dart';
import 'package:nuni/features/sessions/domain/session_kind.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

class _MockSessionsRepository extends Mock implements SessionsRepository {}

void main() {
  late _MockSessionsRepository repository;

  setUp(() {
    repository = _MockSessionsRepository();
  });

  Future<void> pumpJoinPage(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/join/ABC123',
      routes: [
        GoRoute(
          path: '/join/:code',
          builder: (context, state) =>
              JoinPage(code: state.pathParameters['code']!),
        ),
        GoRoute(
          path: '/session/:id',
          builder: (context, state) =>
              Text('session:${state.pathParameters['id']}'),
        ),
        GoRoute(path: '/', builder: (context, state) => const Text('home')),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionsRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
  }

  testWidgets('case 3 (not on any team) shows the refusal message', (
    tester,
  ) async {
    when(() => repository.joinByCode('ABC123')).thenThrow(
      const PostgrestException(message: 'not_in_team', code: 'P0001'),
    );

    await pumpJoinPage(tester);
    await tester.pumpAndSettle();

    expect(
      find.text(
        "You're not on any team in this session yet. Ask the organizer to add you.",
      ),
      findsOneWidget,
    );
    expect(find.text('Back to home'), findsOneWidget);
  });

  testWidgets('an unavailable or ended session shows its own message', (
    tester,
  ) async {
    when(() => repository.joinByCode('ABC123')).thenThrow(
      const PostgrestException(message: 'session_unavailable', code: 'P0001'),
    );

    await pumpJoinPage(tester);
    await tester.pumpAndSettle();

    expect(
      find.text("This session doesn't exist or has ended."),
      findsOneWidget,
    );
  });

  testWidgets('cases 1/2 (join succeeds) navigate to the session', (
    tester,
  ) async {
    when(() => repository.joinByCode('ABC123')).thenAnswer(
      (_) async => Session(
        id: 's1',
        code: 'ABC123',
        ownerId: 'u1',
        status: SessionStatus.draft,
        kind: SessionKind.team,
        scoringMode: ScoringMode.strokePlay,
        rankingDirection: RankingDirection.asc,
        createdAt: DateTime(2026, 9, 16),
      ),
    );

    await pumpJoinPage(tester);
    await tester.pumpAndSettle();

    expect(find.text('session:s1'), findsOneWidget);
  });
}
