import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nuni/core/authorization/authorization_repository.dart';
import 'package:nuni/features/associations/data/associations_repository.dart';
import 'package:nuni/features/associations/domain/association.dart';
import 'package:nuni/features/associations/ui/association_detail_page.dart';
import 'package:nuni/features/players/data/players_repository.dart';
import 'package:nuni/features/profile/data/profile_repository.dart';
import 'package:nuni/features/profile/domain/player.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';

void main() {
  const association = Association(
    id: 'lyon',
    name: 'Lyon Street Golf',
    city: 'Lyon',
    locationLat: 45.749,
    locationLng: 4.8459,
    status: AssociationStatus.approved,
  );

  Future<void> pump(
    WidgetTester tester,
    List<Player> members, {
    List<AssociationManager> myManagerRows = const [],
    Map<String, ManagerSummary> managers = const {},
    Set<String> adminIds = const {},
    Association shown = association,
  }) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = GoRouter(
      initialLocation: '/associations/lyon',
      routes: [
        GoRoute(
          path: '/associations/:id',
          builder: (_, state) =>
              AssociationDetailPage(associationId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/players/:id',
          builder: (_, state) => Text('player ${state.pathParameters['id']}'),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          associationsProvider.overrideWith((ref) async => [shown]),
          associationManagersProvider.overrideWith((ref) async => managers),
          associationAdminsProvider.overrideWith(
            (ref) async => {'lyon': adminIds},
          ),
          myManagerRowsProvider.overrideWith((ref) async => myManagerRows),
          isSuperAdminProvider.overrideWith((ref) async => false),
          myPlayerProvider.overrideWith(
            (ref) async => const Player(
              id: 'me',
              name: 'Me',
              locale: 'en',
              associationId: 'lyon',
              userId: 'u-me',
            ),
          ),
          associationPlayersProvider('lyon')
              .overrideWith((ref) async => members),
        ],
        child: MaterialApp.router(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists the members and opens a public page on tap', (
    tester,
  ) async {
    await pump(tester, const [
      Player(id: 'p1', name: 'Ada', locale: 'en'),
      Player(id: 'p2', name: 'Grace', locale: 'en'),
    ]);

    expect(find.text('Players'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Ada')).dy,
      lessThan(tester.getTopLeft(find.text('Grace')).dy),
    );

    await tester.tap(find.text('Grace'));
    await tester.pumpAndSettle();
    expect(find.text('player p2'), findsOneWidget);
  });

  testWidgets('says so when the association has no members', (tester) async {
    await pump(tester, const []);

    expect(find.text('No players in this association yet.'), findsOneWidget);
  });

  testWidgets('a member can leave their association (Q146)', (tester) async {
    await pump(tester, const []);

    expect(
      find.textContaining('Leave this club', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Join this club', findRichText: true),
      findsNothing,
    );
  });

  testWidgets("its local manager can't leave it (Q146)", (tester) async {
    await pump(
      tester,
      const [],
      myManagerRows: [
        AssociationManager(
          id: 'm1',
          associationId: 'lyon',
          userId: 'u1',
          status: AssociationManagerStatus.approved,
          requestedAt: DateTime(2026, 9, 23),
        ),
      ],
    );

    expect(
      find.textContaining('Leave this club', findRichText: true),
      findsNothing,
    );
    expect(
      find.text("You are this club's local manager: you can't leave it."),
      findsOneWidget,
    );
  });

  group('local admins and partners (plan 27)', () {
    const ada = Player(id: 'p1', name: 'Ada', locale: 'en', userId: 'u1');
    const grace = Player(id: 'p2', name: 'Grace', locale: 'en', userId: 'u2');
    const me = Player(id: 'me', name: 'Me', locale: 'en', userId: 'u-me');

    testWidgets('no section for a plain member when there is no admin', (
      tester,
    ) async {
      await pump(tester, const [ada, me]);

      expect(find.text('Local admins'), findsNothing);
      expect(
        find.textContaining('Add a local admin', findRichText: true),
        findsNothing,
      );
    });

    testWidgets('everyone sees the admins; a plain member acts on none', (
      tester,
    ) async {
      await pump(tester, const [ada, grace, me], adminIds: {'p2'});

      expect(find.text('Local admins'), findsOneWidget);
      expect(find.text('Remove'), findsNothing);
      expect(
        find.textContaining('Add a local admin', findRichText: true),
        findsNothing,
      );
      expect(
        find.textContaining('Stop being a local admin', findRichText: true),
        findsNothing,
      );
    });

    testWidgets('the manager adds and removes admins', (tester) async {
      await pump(
        tester,
        const [ada, grace, me],
        adminIds: {'p2'},
        managers: {'lyon': (managerId: 'm1', userId: 'u-me', name: 'Me')},
      );

      expect(find.text('Remove'), findsOneWidget);
      await tester.tap(
        find.textContaining('Add a local admin', findRichText: true),
      );
      await tester.pumpAndSettle();
      // Neither the admin already named nor the manager themself.
      expect(find.text('Choose a member'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Ada'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Grace'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Me'),
        ),
        findsNothing,
      );
    });

    testWidgets('an admin can renounce and still leave the club (Q170-171)', (
      tester,
    ) async {
      await pump(tester, const [ada, me], adminIds: {'me'});

      expect(
        find.textContaining('Stop being a local admin', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Leave this club', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('lists the partners in order', (tester) async {
      await pump(
        tester,
        const [],
        shown: association.copyWith(
          partners: const [
            AssociationPartner(label: 'Bakery', url: 'bakery.example'),
            AssociationPartner(label: 'Town hall'),
          ],
        ),
      );

      expect(find.text('Partners'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Bakery')).dy,
        lessThan(tester.getTopLeft(find.text('Town hall')).dy),
      );
    });
  });
}
