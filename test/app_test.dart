import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/app.dart';

void main() {
  testWidgets('home page shows the app name and tagline', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NuniApp()));
    await tester.pumpAndSettle();

    expect(find.text('NUNI'), findsOneWidget);
    expect(find.text('Never Up, Never In'), findsOneWidget);
  });
}
