import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/shared/google_logo.dart';

void main() {
  testWidgets('GoogleLogo renders at the requested size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: GoogleLogo(size: 24))),
    );

    expect(find.byType(GoogleLogo), findsOneWidget);
    final size = tester.getSize(find.byType(GoogleLogo));
    expect(size, const Size(24, 24));
  });
}
