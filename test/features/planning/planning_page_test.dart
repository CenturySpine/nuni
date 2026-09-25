import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nuni/features/planning/data/events_repository.dart';
import 'package:nuni/features/planning/data/planning_rights.dart';
import 'package:nuni/features/planning/domain/event.dart';
import 'package:nuni/features/planning/ui/event_widgets.dart';
import 'package:nuni/features/planning/ui/next_event_home_card.dart';
import 'package:nuni/features/planning/ui/planning_page.dart';
import 'package:nuni/features/players/data/players_repository.dart';
import 'package:nuni/features/profile/data/profile_repository.dart';
import 'package:nuni/features/profile/domain/player.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';
import 'package:nuni/shared/nuni_avatar.dart';

void main() {
  const me = Player(id: 'me', name: 'Me', locale: 'en', associationId: 'lsg');
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  Event event(
    String id,
    String label,
    DateTime startsAt, {
    List<EventAnswer> answers = const [],
    int comments = 0,
    String? managerPlayerId,
  }) => Event(
    id: id,
    associationId: 'lsg',
    createdBy: 'u',
    startsAt: startsAt,
    label: label,
    answers: answers,
    commentCount: comments,
    managerPlayerId: managerPlayerId,
  );

  final events = [
    event('past', 'Old outing', today.subtract(const Duration(days: 40))),
    event(
      'next',
      'Thursday session',
      today.add(const Duration(days: 2, hours: 19)),
      answers: const [
        EventAnswer(playerId: 'me', response: EventResponse.yes),
        EventAnswer(playerId: 'p2', response: EventResponse.yes),
      ],
      comments: 3,
    ),
    event('later', 'Christmas dinner', today.add(const Duration(days: 70))),
  ];

  Future<void> pump(
    WidgetTester tester,
    Widget page, {
    Player player = me,
    List<Event>? planning,
    bool manager = false,
  }) async {
    await tester.binding.setSurfaceSize(const Size(800, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(body: page),
        ),
        GoRoute(
          path: '/planning/:id',
          builder: (_, state) => Text('event ${state.pathParameters['id']}'),
        ),
        GoRoute(path: '/planning', builder: (_, _) => const Text('planning')),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myPlayerProvider.overrideWith((ref) async => player),
          myPlanningProvider.overrideWith((ref) async => planning ?? events),
          playerByIdProvider.overrideWith(
            (ref, id) async => Player(id: id, name: 'Anna Bell', locale: 'en'),
          ),
          canModeratePlanningProvider.overrideWith(
            (ref, associationId) async => manager,
          ),
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

  group('PlanningPage', () {
    testWidgets('lists every event with its month and my answer', (
      tester,
    ) async {
      await pump(tester, const PlanningPage());

      expect(find.text('Old outing'), findsOneWidget);
      expect(find.text('Thursday session'), findsOneWidget);
      expect(find.text('Christmas dinner'), findsOneWidget);
      expect(find.text('Present'), findsOneWidget);
      expect(find.text('2 present'), findsOneWidget);
      // The comment count shows only where there are comments.
      expect(
        find.descendant(
          of: find.byType(EventCommentCount),
          matching: find.text('3'),
        ),
        findsOneWidget,
      );
      expect(find.text('New event'), findsOneWidget);
      // A plain member has no import action.
      expect(find.text('Import an agenda'), findsNothing);
    });

    testWidgets('shows the person in charge under the day tile', (
      tester,
    ) async {
      await pump(
        tester,
        const PlanningPage(),
        planning: [
          event(
            'managed',
            'Managed outing',
            today.add(const Duration(days: 3)),
            managerPlayerId: 'p2',
          ),
          event('free', 'Free outing', today.add(const Duration(days: 4))),
        ],
      );
      // Only the managed event has an avatar, with the manager's initials.
      expect(find.byType(NuniAvatar), findsOneWidget);
      expect(find.text('AB'), findsOneWidget);
      expect(find.byTooltip('In charge · Anna Bell'), findsOneWidget);
    });

    testWidgets('offers the import to the local manager', (tester) async {
      await pump(tester, const PlanningPage(), manager: true);
      expect(find.text('Import an agenda'), findsOneWidget);
    });

    testWidgets('invites to create the first event when empty', (tester) async {
      await pump(tester, const PlanningPage(), planning: const []);
      expect(find.text('No event planned yet.'), findsOneWidget);
      expect(
        find.textContaining('Create the first event', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('asks to join a club without one', (tester) async {
      await pump(
        tester,
        const PlanningPage(),
        player: const Player(id: 'x', name: 'New', locale: 'en'),
      );
      expect(find.text('Join a club to see its planning.'), findsOneWidget);
    });
  });

  group('NextEventHomeSection', () {
    testWidgets('shows the next event with my answer buttons', (tester) async {
      await pump(tester, const NextEventHomeSection());

      expect(find.text('Next event'), findsOneWidget);
      expect(find.text('Thursday session'), findsOneWidget);
      expect(find.text('Old outing'), findsNothing);
      expect(find.text('Absent'), findsOneWidget);
      expect(find.text('Maybe'), findsOneWidget);

      await tester.tap(find.text('Thursday session'));
      await tester.pumpAndSettle();
      expect(find.text('event next'), findsOneWidget);
    });

    testWidgets('shows nothing without a coming event', (tester) async {
      await pump(
        tester,
        const NextEventHomeSection(),
        planning: [events.first],
      );
      expect(find.text('Next event'), findsNothing);
    });
  });
}
