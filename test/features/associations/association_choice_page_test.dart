import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nuni/core/location/location_service.dart';
import 'package:nuni/features/associations/data/associations_repository.dart';
import 'package:nuni/features/associations/domain/association.dart';
import 'package:nuni/features/associations/ui/association_choice_page.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';
import 'package:nuni/shared/nuni_button.dart';

/// Never calls the real `geolocator` plugin; [position] null = refused.
class _FakeLocationService implements LocationService {
  _FakeLocationService(this.position);

  final Position? position;

  @override
  Future<Position?> getCurrentPosition() async => position;
}

Position _at(double lat, double lng) => Position(
  latitude: lat,
  longitude: lng,
  timestamp: DateTime(2026, 9, 23),
  accuracy: 10,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

Association _association(String id, String name, double lat, double lng) =>
    Association(
      id: id,
      name: name,
      city: 'City of $name',
      locationLat: lat,
      locationLng: lng,
      status: AssociationStatus.approved,
    );

void main() {
  final associations = [
    _association('lyon', 'Lyon Street Golf', 45.749, 4.8459),
    _association('grenoble', 'Wild Shrimp Crew', 45.188, 5.724),
    _association('morlaix', "Street Golf à l'Ouest", 48.577, -3.827),
    // A pending request never shows in the choice (Q81).
    _association(
      'pending',
      'Pending Club',
      45.19,
      5.72,
    ).copyWith(status: AssociationStatus.pending),
  ];

  Future<void> pump(WidgetTester tester, Position? position) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          locationServiceProvider.overrideWithValue(
            _FakeLocationService(position),
          ),
          associationsProvider.overrideWith((ref) async => associations),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: AssociationChoicePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  VoidCallback? confirmAction(WidgetTester tester) => tester
      .widget<NuniButton>(find.widgetWithText(NuniButton, 'Confirm'))
      .onPressed;

  testWidgets('pre-selects the nearest approved association', (tester) async {
    // A player in Grenoble.
    await pump(tester, _at(45.19, 5.72));

    expect(find.text('Pending Club'), findsNothing);
    final names = [
      for (final name in ['Wild Shrimp Crew', 'Lyon Street Golf'])
        tester.getTopLeft(find.text(name)).dy,
    ];
    expect(names[0], lessThan(names[1]));
    expect(confirmAction(tester), isNotNull);
  });

  testWidgets('without a position: alphabetical, nothing selected', (
    tester,
  ) async {
    await pump(tester, null);

    expect(
      tester.getTopLeft(find.text('Lyon Street Golf')).dy,
      lessThan(tester.getTopLeft(find.text('Wild Shrimp Crew')).dy),
    );
    expect(confirmAction(tester), isNull);

    await tester.tap(find.text('Wild Shrimp Crew'));
    await tester.pump();
    expect(confirmAction(tester), isNotNull);
  });
}
