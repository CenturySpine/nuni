import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/shared/nuni_chip.dart';

void main() {
  testWidgets('NuniChip reports selection via onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NuniChip(label: 'Scramble', onTap: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Scramble'), findsOneWidget);
    await tester.tap(find.byType(NuniChip));
    expect(tapped, isTrue);
  });
}
