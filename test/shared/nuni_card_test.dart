import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/shared/nuni_card.dart';

void main() {
  testWidgets('NuniCard renders its child and reacts to tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: NuniCard(
          onTap: () => tapped = true,
          child: const Text('Contenu'),
        ),
      ),
    );

    expect(find.text('Contenu'), findsOneWidget);
    await tester.tap(find.byType(NuniCard));
    expect(tapped, isTrue);
  });
}
