import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuni/shared/nuni_logo.dart';
import 'package:nuni/app.dart';
import 'package:nuni/core/location/location_service.dart';
import 'package:nuni/core/supabase/supabase_providers.dart';
import 'package:nuni/features/associations/data/associations_repository.dart';
import 'package:nuni/features/associations/domain/association.dart';
import 'package:nuni/features/profile/data/profile_repository.dart';
import 'package:nuni/features/profile/domain/player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockSession extends Mock implements Session {}

class _NoLocation implements LocationService {
  @override
  Future<Position?> getCurrentPosition() async => null;
}

void main() {
  late _MockSupabaseClient client;
  late _MockGoTrueClient auth;

  setUp(() {
    client = _MockSupabaseClient();
    auth = _MockGoTrueClient();
    when(() => client.auth).thenReturn(auth);
    when(() => auth.onAuthStateChange).thenAnswer((_) => const Stream.empty());
  });

  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
    ProviderScope(
      overrides: [supabaseClientProvider.overrideWithValue(client)],
      child: const NuniApp(),
    ),
  );

  testWidgets(
    'signed-out visitors land on the login page, not the home shell',
    (tester) async {
      when(() => auth.currentSession).thenReturn(null);

      await pumpApp(tester);
      await tester.pumpAndSettle();

      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    },
  );

  testWidgets(
    'signed-in visitors see the home shell: title bar and bottom nav',
    (tester) async {
      when(() => auth.currentSession).thenReturn(_MockSession());

      await pumpApp(tester);
      await tester.pumpAndSettle();

      expect(find.byType(NuniLogo), findsOneWidget);
      expect(find.text('Home'), findsNWidgets(2));
      expect(find.text('Holes'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    },
  );

  Future<void> pumpWithoutAssociation(WidgetTester tester) async {
    when(() => auth.currentSession).thenReturn(_MockSession());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseClientProvider.overrideWithValue(client),
          locationServiceProvider.overrideWithValue(_NoLocation()),
          myPlayerProvider.overrideWith(
            (ref) async =>
                const Player(id: 'p1', name: 'New', locale: 'en', userId: 'u1'),
          ),
          myPendingRequestProvider.overrideWith((ref) async => null),
          associationsProvider.overrideWith(
            (ref) async => const [
              Association(
                id: 'lsg',
                name: 'Lyon Street Golf',
                city: 'Lyon',
                locationLat: 45.749,
                locationLng: 4.8459,
                status: AssociationStatus.approved,
              ),
            ],
          ),
        ],
        child: const NuniApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'a player with no association is offered one before the app (plan 18)',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await pumpWithoutAssociation(tester);

      expect(find.text('Choose your club'), findsOneWidget);
      expect(find.text('Holes'), findsNothing);

      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      expect(find.text('Choose your club'), findsNothing);
      expect(find.text('Holes'), findsOneWidget);
    },
  );

  testWidgets(
    'once put off on this device, the choice is not offered again (Q146)',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'nuni.association_choice_skipped': true,
      });
      await pumpWithoutAssociation(tester);

      expect(find.text('Choose your club'), findsNothing);
      expect(find.text('Holes'), findsOneWidget);
    },
  );
}
