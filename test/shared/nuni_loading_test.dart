import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/shared/nuni_loading.dart';

void main() {
  testWidgets('NuniLoading shows a spinner and the optional message', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: NuniLoading(message: 'Chargement…')),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Chargement…'), findsOneWidget);
  });
}
