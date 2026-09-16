import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuni/core/location/location_service.dart';
import 'package:nuni/core/supabase/supabase_providers.dart';
import 'package:nuni/features/holes/data/holes_repository.dart';
import 'package:nuni/features/holes/domain/hole.dart';
import 'package:nuni/features/holes/ui/hole_form_page.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockHolesRepository extends Mock implements HolesRepository {}

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

/// Never calls the real `geolocator` plugin, which has no platform
/// implementation registered in the widget test environment.
class _FakeLocationService implements LocationService {
  @override
  Future<Position?> getCurrentPosition() async => null;
}

void main() {
  late _MockHolesRepository repository;
  late _MockSupabaseClient client;
  late _MockGoTrueClient auth;

  setUpAll(() {
    registerFallbackValue(HoleVisibility.public);
  });

  setUp(() {
    repository = _MockHolesRepository();
    client = _MockSupabaseClient();
    auth = _MockGoTrueClient();
    when(() => client.auth).thenReturn(auth);
    when(() => auth.currentUser).thenReturn(null);
  });

  Future<void> pumpForm(WidgetTester tester) async {
    // The form is taller than the default test surface; the "Save" and
    // "Delete" actions sit past the initial viewport + cache extent, so a
    // plain ListView never mounts them without either scrolling or a taller
    // surface -- the latter is simpler here since these tests don't care
    // about scroll behaviour.
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          holesRepositoryProvider.overrideWithValue(repository),
          locationServiceProvider.overrideWithValue(_FakeLocationService()),
          supabaseClientProvider.overrideWithValue(client),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HoleFormPage(),
        ),
      ),
    );
  }

  testWidgets('an empty name blocks save and the repository is never called', (
    tester,
  ) async {
    await pumpForm(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required.'), findsOneWidget);
    verifyNever(
      () => repository.create(
        name: any(named: 'name'),
        description: any(named: 'description'),
        par: any(named: 'par'),
        distanceM: any(named: 'distanceM'),
        lat: any(named: 'lat'),
        lng: any(named: 'lng'),
        visibility: any(named: 'visibility'),
      ),
    );
  });

  testWidgets('a valid name without a position shows the position hint', (
    tester,
  ) async {
    await pumpForm(tester);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Le Ficus');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        "Couldn't get your position. Drag the marker on the map instead.",
      ),
      findsOneWidget,
    );
  });
}
