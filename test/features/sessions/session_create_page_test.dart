import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuni/core/location/location_service.dart';
import 'package:nuni/features/associations/data/associations_repository.dart';
import 'package:nuni/features/associations/domain/association.dart';
import 'package:nuni/features/profile/data/profile_repository.dart';
import 'package:nuni/features/profile/domain/player.dart';
import 'package:nuni/features/sessions/data/sessions_repository.dart';
import 'package:nuni/features/sessions/domain/ranking_direction.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';
import 'package:nuni/features/sessions/domain/session.dart';
import 'package:nuni/features/sessions/domain/session_kind.dart';
import 'package:nuni/features/sessions/ui/session_create_page.dart';
import 'package:nuni/features/spots/data/spots_repository.dart';
import 'package:nuni/features/spots/domain/spot.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';

class _MockSessionsRepository extends Mock implements SessionsRepository {}

/// Never calls the real `geolocator` plugin, which has no platform
/// implementation registered in the widget test environment.
class _FakeLocationService implements LocationService {
  @override
  Future<Position?> getCurrentPosition() async => null;
}

const _lsg = Association(
  id: 'lsg',
  name: 'Lyon Street Golf',
  shortName: 'LSG',
  city: 'Lyon',
  locationLat: 45.749,
  locationLng: 4.8459,
  status: AssociationStatus.approved,
);
const _park = Spot(
  id: 'sp1',
  associationId: 'lsg',
  name: 'Parc de la Tête d’Or',
  locationLat: 45.77,
  locationLng: 4.85,
);
const _member = Player(
  id: 'p1',
  name: 'Bruno',
  locale: 'en',
  userId: 'u1',
  associationId: 'lsg',
);

void main() {
  late _MockSessionsRepository repository;

  setUpAll(() {
    registerFallbackValue(SessionKind.individual);
    registerFallbackValue(ScoringMode.strokePlay);
    registerFallbackValue(RankingDirection.asc);
  });

  setUp(() {
    repository = _MockSessionsRepository();
    when(
      () => repository.create(
        kind: any(named: 'kind'),
        scoringMode: any(named: 'scoringMode'),
        rankingDirection: any(named: 'rankingDirection'),
        spotId: any(named: 'spotId'),
        city: any(named: 'city'),
        lat: any(named: 'lat'),
        lng: any(named: 'lng'),
        eventId: any(named: 'eventId'),
      ),
    ).thenAnswer(
      (_) async => Session(
        id: 's1',
        code: 'ABC123',
        ownerId: 'u1',
        status: SessionStatus.draft,
        kind: SessionKind.individual,
        scoringMode: ScoringMode.strokePlay,
        rankingDirection: RankingDirection.asc,
        createdAt: DateTime(2026, 9, 16),
      ),
    );
  });

  Future<void> pumpForm(WidgetTester tester, {Player player = _member}) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionsRepositoryProvider.overrideWithValue(repository),
          locationServiceProvider.overrideWithValue(_FakeLocationService()),
          myPlayerProvider.overrideWith((ref) async => player),
          associationsProvider.overrideWith((ref) async => [_lsg]),
          associationSpotsProvider.overrideWith(
            (ref, associationId) async => const [_park],
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SessionCreatePage(),
        ),
      ),
    );
  }

  Future<void> chooseSpot(WidgetTester tester) async {
    await tester.tap(find.text('Choose a spot'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_park.name));
    await tester.pumpAndSettle();
  }

  testWidgets('a session needs a spot (plan 28)', (tester) async {
    await pumpForm(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create the session'));
    await tester.pumpAndSettle();

    expect(find.text('Choose the spot where you play.'), findsOneWidget);
    verifyNever(
      () => repository.create(
        kind: any(named: 'kind'),
        scoringMode: any(named: 'scoringMode'),
        rankingDirection: any(named: 'rankingDirection'),
        spotId: any(named: 'spotId'),
        city: any(named: 'city'),
        lat: any(named: 'lat'),
        lng: any(named: 'lng'),
        eventId: any(named: 'eventId'),
      ),
    );
  });

  testWidgets(
    'submitting the default form creates an individual, Stroke Play session',
    (tester) async {
      await pumpForm(tester);
      await tester.pumpAndSettle();

      await chooseSpot(tester);
      await tester.tap(find.text('Create the session'));
      await tester.pumpAndSettle();

      verify(
        () => repository.create(
          kind: SessionKind.individual,
          scoringMode: ScoringMode.strokePlay,
          rankingDirection: RankingDirection.asc,
          spotId: 'sp1',
          city: null,
          lat: null,
          lng: null,
          eventId: null,
        ),
      ).called(1);
    },
  );

  testWidgets('picking Team switches the selected kind chip', (tester) async {
    await pumpForm(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Team'));
    await tester.pumpAndSettle();
    await chooseSpot(tester);
    await tester.tap(find.text('Create the session'));
    await tester.pumpAndSettle();

    verify(
      () => repository.create(
        kind: SessionKind.team,
        scoringMode: any(named: 'scoringMode'),
        rankingDirection: any(named: 'rankingDirection'),
        spotId: any(named: 'spotId'),
        city: any(named: 'city'),
        lat: any(named: 'lat'),
        lng: any(named: 'lng'),
        eventId: any(named: 'eventId'),
      ),
    ).called(1);
  });

  testWidgets('shows the session\'s association, read-only (plan 18)', (
    tester,
  ) async {
    await pumpForm(tester);
    await tester.pumpAndSettle();

    expect(find.text('Lyon Street Golf'), findsOneWidget);
    expect(find.text("Session's club"), findsOneWidget);
  });

  testWidgets('without an association, creating is blocked (plan 18, Q81)', (
    tester,
  ) async {
    await pumpForm(
      tester,
      player: const Player(id: 'p2', name: 'New', locale: 'en', userId: 'u2'),
    );
    await tester.pumpAndSettle();

    expect(find.text('See the clubs'), findsOneWidget);
    expect(find.text('Create the session'), findsNothing);
  });
}
