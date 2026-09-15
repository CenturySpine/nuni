import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/shared/nuni_confirm_dialog.dart';

void main() {
  testWidgets('NuniConfirmDialog resolves true/false from the pressed button', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await NuniConfirmDialog.show(
                context,
                title: 'Supprimer la session ?',
                message: 'Cette action est irréversible.',
                danger: true,
              );
            },
            child: const Text('Ouvrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    expect(find.text('Supprimer la session ?'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}
