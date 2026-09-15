import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/shared/nuni_empty_state.dart';

void main() {
  testWidgets('NuniEmptyState shows the message and the optional action', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NuniEmptyState(message: 'Rien ici', action: Text('Créer')),
      ),
    );

    expect(find.text('Rien ici'), findsOneWidget);
    expect(find.text('Créer'), findsOneWidget);
  });
}
