import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nuni/features/championship/data/championship_repository.dart';
import 'package:nuni/features/championship/domain/championship_membership.dart';
import 'package:nuni/features/championship/domain/championship_season.dart';
import 'package:nuni/features/championship/domain/player_standing.dart';
import 'package:nuni/features/championship/ui/championship_home_card.dart';
import 'package:nuni/features/profile/data/profile_repository.dart';
import 'package:nuni/features/profile/domain/player.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';

void main() {
  final current = currentChampionshipSeason();
  const pastSeason = '2000-2001';
  const me = Player(id: 'p1', name: 'Bruno', locale: 'en', userId: 'u1');
  const standings = [
    PlayerStanding(
      playerId: 'p2',
      playerName: 'Florent',
      position: 1,
      totalPoints: 50,
      sessionsPlayed: 4,
    ),
    PlayerStanding(
      playerId: 'p1',
      playerName: 'Bruno',
      position: 2,
      totalPoints: 42,
      sessionsPlayed: 4,
    ),
    PlayerStanding(
      playerId: 'p3',
      playerName: 'Louis',
      position: 3,
      totalPoints: 30,
      sessionsPlayed: 3,
    ),
  ];

  late Uri? openedUri;

  Future<void> pump(
    WidgetTester tester,
    List<ChampionshipMembership> memberships,
  ) async {
    openedUri = null;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: ChampionshipHomeSection()),
        ),
        GoRoute(
          path: '/championship',
          builder: (context, state) {
            openedUri = state.uri;
            return const SizedBox();
          },
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myChampionshipMembershipsProvider.overrideWith(
            (ref) async => memberships,
          ),
          championshipStandingsProvider.overrideWith(
            (ref, args) async => standings,
          ),
          championshipAssociationLabelProvider.overrideWith(
            (ref, associationId) async => 'INSA',
          ),
          myPlayerProvider.overrideWith((ref) async => me),
        ],
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
    await tester.pumpAndSettle();
  }

  testWidgets('shows the current season card and the past championships', (
    tester,
  ) async {
    await pump(tester, [
      (associationId: 'z1', season: current),
      (associationId: 'z1', season: pastSeason),
    ]);

    expect(find.text('INSA · $current'), findsOneWidget);
    expect(find.text('Past championships'), findsOneWidget);
    expect(find.text('INSA · $pastSeason'), findsOneWidget);
    expect(find.text('#2 of 3 · 42 pts'), findsOneWidget);
  });

  testWidgets(
    'a past season alone still shows the history (Q72), opening its classement',
    (tester) async {
      await pump(tester, [(associationId: 'z1', season: pastSeason)]);

      expect(find.text('INSA · $current'), findsNothing);
      expect(find.text('INSA · $pastSeason'), findsOneWidget);

      await tester.tap(find.text('INSA · $pastSeason'));
      await tester.pumpAndSettle();

      expect(openedUri?.path, '/championship');
      expect(openedUri?.queryParameters, {
        'association': 'z1',
        'season': pastSeason,
      });
    },
  );

  testWidgets('nothing at all without any championship session', (
    tester,
  ) async {
    await pump(tester, []);

    expect(find.text('Championship'), findsNothing);
  });
}
