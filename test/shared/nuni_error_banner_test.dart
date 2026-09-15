import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/core/theme/phosphor_icons.dart';
import 'package:nuni/shared/nuni_error_banner.dart';

void main() {
  testWidgets('NuniErrorBanner shows the message and fires onRetry', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: NuniErrorBanner(
          message: 'Échec du chargement',
          onRetry: () => retried = true,
        ),
      ),
    );

    expect(find.text('Échec du chargement'), findsOneWidget);
    await tester.tap(find.byIcon(PhosphorIcons.arrowClockwise));
    expect(retried, isTrue);
  });
}
