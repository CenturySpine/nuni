import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuni/core/location/location_service.dart';
import 'package:nuni/features/sessions/data/sessions_repository.dart';
import 'package:nuni/features/sessions/domain/ranking_direction.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';
import 'package:nuni/features/sessions/domain/session.dart';
import 'package:nuni/features/sessions/domain/session_kind.dart';
import 'package:nuni/features/sessions/ui/session_create_page.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';

class _MockSessionsRepository extends Mock implements SessionsRepository {}

/// Never calls the real `geolocator` plugin, which has no platform
/// implementation registered in the widget test environment.
class _FakeLocationService implements LocationService {
  @override
  Future<Position?> getCurrentPosition() async => null;
}

void main() {
  late _MockSessionsRepository repository;

  setUpAll(() {
    registerFallbackValue(SessionKind.individual);
    registerFallbackValue(ScoringMode.strokePlay);
    registerFallbackValue(RankingDirection.asc);
  });

  setUp(() {
    repository = _MockSessionsRepository();
    when(() => repository.zonesForCity(any())).thenAnswer((_) async => []);
    when(
      () => repository.create(
        kind: any(named: 'kind'),
        scoringMode: any(named: 'scoringMode'),
        rankingDirection: any(named: 'rankingDirection'),
        city: any(named: 'city'),
        zone: any(named: 'zone'),
        lat: any(named: 'lat'),
        lng: any(named: 'lng'),
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

  Future<void> pumpForm(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionsRepositoryProvider.overrideWithValue(repository),
          locationServiceProvider.overrideWithValue(_FakeLocationService()),
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

  testWidgets(
    'submitting the default form creates an individual, Stroke Play session',
    (tester) async {
      await pumpForm(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create the session'));
      await tester.pumpAndSettle();

      verify(
        () => repository.create(
          kind: SessionKind.individual,
          scoringMode: ScoringMode.strokePlay,
          rankingDirection: RankingDirection.asc,
          city: null,
          zone: null,
          lat: null,
          lng: null,
        ),
      ).called(1);
    },
  );

  testWidgets('picking Team switches the selected kind chip', (tester) async {
    await pumpForm(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Team'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create the session'));
    await tester.pumpAndSettle();

    verify(
      () => repository.create(
        kind: SessionKind.team,
        scoringMode: any(named: 'scoringMode'),
        rankingDirection: any(named: 'rankingDirection'),
        city: any(named: 'city'),
        zone: any(named: 'zone'),
        lat: any(named: 'lat'),
        lng: any(named: 'lng'),
      ),
    ).called(1);
  });
}
