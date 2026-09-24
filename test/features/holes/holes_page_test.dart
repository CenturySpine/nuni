import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nuni/features/holes/data/holes_repository.dart';
import 'package:nuni/features/holes/domain/hole.dart';
import 'package:nuni/features/holes/ui/holes_page.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';

class _FixedHolesRadius extends HolesRadius {
  @override
  Future<int> build() async => holesRadiusDefaultM;
}

void main() {
  const mine = Hole(
    id: 'h1',
    name: 'Le Ficus',
    par: 3,
    startLat: 48.8534,
    startLng: 2.3488,
    ownerId: 'u1',
  );
  // Imported from LsgScores, not repositioned yet (plan 13, Q49).
  const imported = Hole(id: 'h2', name: 'Vieux trou', par: 2, ownerId: 'u1');

  Future<void> pumpHolesPage(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/holes',
      routes: [
        GoRoute(path: '/holes', builder: (context, state) => const HolesPage()),
        GoRoute(
          path: '/holes/new',
          builder: (context, state) => const SizedBox(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myPositionProvider.overrideWith((ref) async => null),
          holesRadiusProvider.overrideWith(() => _FixedHolesRadius()),
          nearbyHolesProvider.overrideWith((ref, radiusM) async => const []),
          myHolesProvider.overrideWith((ref) async => const [mine, imported]),
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

  testWidgets(
    'shows the location-unavailable fallback when geolocation fails',
    (tester) async {
      await pumpHolesPage(tester);

      expect(
        find.text(
          'Location unavailable. Allow geolocation, or browse all your holes.',
        ),
        findsOneWidget,
      );
      expect(find.text('No holes within 1.0 km.'), findsOneWidget);
    },
  );

  testWidgets('switching to "All my holes" shows the owned hole', (
    tester,
  ) async {
    await pumpHolesPage(tester);

    await tester.tap(find.text('All my holes'));
    await tester.pumpAndSettle();

    expect(find.text('Le Ficus'), findsOneWidget);
    expect(find.text('Par 3'), findsOneWidget);
  });

  testWidgets('a hole without a position is listed as "position to set"', (
    tester,
  ) async {
    await pumpHolesPage(tester);

    await tester.tap(find.text('All my holes'));
    await tester.pumpAndSettle();

    expect(find.text('Vieux trou'), findsOneWidget);
    expect(find.text('Par 2'), findsOneWidget);
    expect(find.text('Position to set'), findsOneWidget);
  });
}
