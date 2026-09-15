import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/app.dart';

void main() {
  testWidgets('root route shows the home shell: title bar and bottom nav', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: NuniApp()));
    await tester.pumpAndSettle();

    // The test harness's default locale is English regardless of the app's
    // own "follow the browser" default.
    expect(find.text('NUNI'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Holes'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
  });
}
