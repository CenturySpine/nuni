import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/shared/nuni_logo.dart';

void main() {
  testWidgets('NuniLogo renders at the requested size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: NuniLogo(size: 48))),
    );

    expect(find.byType(NuniLogo), findsOneWidget);
    final size = tester.getSize(find.byType(NuniLogo));
    expect(size, const Size(48, 48));
  });
}
