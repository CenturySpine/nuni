import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/live/ui/score_entry_sheet.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';

/// The sheet no longer saves anything itself (PO feedback, 2026-09-17: it
/// used to stay open after a tap) -- it just picks a value and pops with
/// it, so these tests drive it through a real Navigator and read back
/// whatever `showScoreEntrySheet`'s Future resolves to, the same contract
/// its caller (`PlayedHoleCard`) relies on.
///
/// [onOpened] receives the still-pending Future the moment the sheet opens
/// (not awaited here -- the whole point is to keep interacting with the
/// sheet afterwards, so this can't just `return await showScoreEntrySheet(...)`,
/// which would block until the sheet closes before the test gets a chance
/// to tap anything in it).
Future<void> pumpAndOpen(
  WidgetTester tester,
  void Function(Future<int?> result) onOpened, {
  bool isPoints = false,
  int? initialValue,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => onOpened(
              showScoreEntrySheet(
                context,
                teamLabel: 'Alice / Bob',
                isPoints: isPoints,
                initialValue: initialValue,
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tapping a digit chip closes the sheet with that value', (
    tester,
  ) async {
    Future<int?>? result;
    await pumpAndOpen(tester, (r) => result = r);

    await tester.tap(find.text('4'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(await result, 4);
  });

  testWidgets('strokes mode hides the custom field until "X" is tapped', (
    tester,
  ) async {
    Future<int?>? result;
    await pumpAndOpen(tester, (r) => result = r);

    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '14');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(await result, 14);
  });

  testWidgets('points mode always shows the custom field, no "X" chip', (
    tester,
  ) async {
    await pumpAndOpen(tester, (_) {}, isPoints: true);

    expect(find.text('X'), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });
}
