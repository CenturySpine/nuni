import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuni/app.dart';
import 'package:nuni/core/supabase/supabase_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockSession extends Mock implements Session {}

void main() {
  late _MockSupabaseClient client;
  late _MockGoTrueClient auth;

  setUp(() {
    client = _MockSupabaseClient();
    auth = _MockGoTrueClient();
    when(() => client.auth).thenReturn(auth);
    when(() => auth.onAuthStateChange).thenAnswer((_) => const Stream.empty());
  });

  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
    ProviderScope(
      overrides: [supabaseClientProvider.overrideWithValue(client)],
      child: const NuniApp(),
    ),
  );

  testWidgets(
    'signed-out visitors land on the login page, not the home shell',
    (tester) async {
      when(() => auth.currentSession).thenReturn(null);

      await pumpApp(tester);
      await tester.pumpAndSettle();

      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    },
  );

  testWidgets(
    'signed-in visitors see the home shell: title bar and bottom nav',
    (tester) async {
      when(() => auth.currentSession).thenReturn(_MockSession());

      await pumpApp(tester);
      await tester.pumpAndSettle();

      expect(find.text('NUNI'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Holes'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    },
  );
}
