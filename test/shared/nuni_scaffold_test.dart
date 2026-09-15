import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/shared/nuni_scaffold.dart';

void main() {
  testWidgets('NuniScaffold shows the title, body, and sticky actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NuniScaffold(
          title: 'Titre',
          body: const Text('Contenu'),
          stickyActions: const Text('Action'),
        ),
      ),
    );

    expect(find.text('Titre'), findsOneWidget);
    expect(find.text('Contenu'), findsOneWidget);
    expect(find.text('Action'), findsOneWidget);
  });
}
