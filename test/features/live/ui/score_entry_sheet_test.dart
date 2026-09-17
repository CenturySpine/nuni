import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuni/features/live/data/live_repository.dart';
import 'package:nuni/features/live/ui/score_entry_sheet.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';

class _MockLiveRepository extends Mock implements LiveRepository {}

void main() {
  late _MockLiveRepository repository;

  setUp(() {
    repository = _MockLiveRepository();
    when(
      () => repository.upsertScore(
        playedHoleId: any(named: 'playedHoleId'),
        teamId: any(named: 'teamId'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<void> pumpSheet(
    WidgetTester tester, {
    bool isPoints = false,
    int? initialValue,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [liveRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ScoreEntrySheet(
              playedHoleId: 'hole-1',
              teamId: 'team-1',
              teamLabel: 'Alice / Bob',
              isPoints: isPoints,
              initialValue: initialValue,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('tapping a digit chip saves it immediately', (tester) async {
    await pumpSheet(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('4'));
    await tester.pumpAndSettle();

    verify(
      () => repository.upsertScore(
        playedHoleId: 'hole-1',
        teamId: 'team-1',
        value: 4,
      ),
    ).called(1);
  });

  testWidgets('strokes mode hides the custom field until "X" is tapped', (
    tester,
  ) async {
    await pumpSheet(tester);
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '14');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    verify(
      () => repository.upsertScore(
        playedHoleId: 'hole-1',
        teamId: 'team-1',
        value: 14,
      ),
    ).called(1);
  });

  testWidgets('points mode always shows the custom field, no "X" chip', (
    tester,
  ) async {
    await pumpSheet(tester, isPoints: true);
    await tester.pumpAndSettle();

    expect(find.text('X'), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });
}
