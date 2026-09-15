import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/shared/nuni_button.dart';

void main() {
  testWidgets('NuniButton fires onPressed and respects each variant', (
    tester,
  ) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: NuniButton(label: 'Go', onPressed: () => pressed = true),
      ),
    );
    await tester.tap(find.text('Go'));
    expect(pressed, isTrue);

    await tester.pumpWidget(
      const MaterialApp(
        home: NuniButton(
          label: 'Secondaire',
          onPressed: null,
          variant: NuniButtonVariant.secondary,
        ),
      ),
    );
    expect(find.byType(OutlinedButton), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: NuniButton(
          label: 'Supprimer',
          onPressed: null,
          variant: NuniButtonVariant.danger,
        ),
      ),
    );
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
