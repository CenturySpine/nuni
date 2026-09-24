import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
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
import 'package:nuni/shared/nuni_chip.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockHolesRepository extends Mock implements HolesRepository {}

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockUser extends Mock implements User {}

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

  setUp(() {
    repository = _MockHolesRepository();
    client = _MockSupabaseClient();
    auth = _MockGoTrueClient();
    when(() => client.auth).thenReturn(auth);
    when(() => auth.currentUser).thenReturn(null);
  });

  Future<void> pumpForm(WidgetTester tester, {String? holeId}) async {
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
          home: HoleFormPage(holeId: holeId),
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

  testWidgets(
    'placing start moves on to the target, then to the path (PO, 2026-09-23)',
    (tester) async {
      await pumpForm(tester);
      await tester.pumpAndSettle();

      bool selected(String label) => tester
          .widget<NuniChip>(find.widgetWithText(NuniChip, label))
          .selected;
      Future<void> tapMap(Offset offset) async {
        await tester.tapAt(tester.getCenter(find.byType(FlutterMap)) + offset);
        // Past flutter_map's double-tap window, so the tap is delivered.
        await tester.pump(const Duration(milliseconds: 500));
      }

      expect(selected('Start'), isTrue);

      await tapMap(Offset.zero);
      expect(selected('Target'), isTrue);

      await tapMap(const Offset(40, 40));
      expect(selected('Path'), isTrue);

      // Manual switch still works, and correcting the start of a hole that
      // already has a target stays on start.
      await tester.tap(find.widgetWithText(NuniChip, 'Start'));
      await tester.pump();
      await tapMap(const Offset(-40, 0));
      expect(selected('Start'), isTrue);
    },
  );

  group('an existing hole', () {
    const hole = Hole(
      id: 'h1',
      name: 'Le Ficus',
      par: 3,
      startLat: 48.85,
      startLng: 2.35,
      ownerId: 'owner',
    );

    setUp(() {
      when(() => repository.fetchById('h1')).thenAnswer((_) async => hole);
      when(() => repository.fetchLastPlaced(excludeId: any(named: 'excludeId')))
          .thenAnswer((_) async => null);
    });

    testWidgets('opens read-only for someone who does not own it', (
      tester,
    ) async {
      await pumpForm(tester, holeId: 'h1');
      await tester.pumpAndSettle();

      expect(find.text('Hole details'), findsOneWidget);
      expect(find.text('Le Ficus'), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(NuniChip), findsNothing);
      expect(find.text('Save'), findsNothing);
      expect(find.text('Delete hole'), findsNothing);
      for (final field in tester.widgetList<EditableText>(
        find.byType(EditableText),
      )) {
        expect(field.readOnly, isTrue);
      }
    });

    testWidgets('stays editable for its owner', (tester) async {
      final user = _MockUser();
      when(() => user.id).thenReturn('owner');
      when(() => auth.currentUser).thenReturn(user);

      await pumpForm(tester, holeId: 'h1');
      await tester.pumpAndSettle();

      expect(find.text('Edit hole'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(NuniChip), findsNWidgets(3));
    });
  });
}
