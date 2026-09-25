import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuni/core/router/auth_guard.dart';
import 'package:nuni/core/router/pending_link.dart';
import 'package:nuni/core/supabase/supabase_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockSession extends Mock implements Session {}

final _routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    redirect: authGuard(ref),
    routes: [
      for (final path in ['/', '/login', '/planning/:id', '/join/:code'])
        GoRoute(
          path: path,
          builder: (context, state) => Text('page ${state.uri}'),
        ),
    ],
  ),
);

void main() {
  late _MockGoTrueClient auth;
  late DateTime now;

  setUp(() {
    auth = _MockGoTrueClient();
    now = DateTime(2026, 9, 25, 20);
    PendingLink.clock = () => now;
    PendingLink.take(); // Leftover from another test.
  });

  tearDown(() => PendingLink.clock = DateTime.now);

  void signedIn(bool value) =>
      when(() => auth.currentSession).thenReturn(value ? _MockSession() : null);

  Future<GoRouter> pumpRouter(WidgetTester tester) async {
    final client = _MockSupabaseClient();
    when(() => client.auth).thenReturn(auth);
    final container = ProviderContainer(
      overrides: [supabaseClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);
    final router = container.read(_routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    return router;
  }

  /// The visitor opens [link] signed out, then signs in [after] later.
  Future<String> openThenSignIn(
    WidgetTester tester,
    String link, {
    Duration after = const Duration(minutes: 1),
  }) async {
    signedIn(false);
    final router = await pumpRouter(tester);
    router.go(link);
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), '/login');

    now = now.add(after);
    signedIn(true);
    router.refresh(); // What the auth state change does in the app.
    await tester.pumpAndSettle();
    return router.state.uri.toString();
  }

  testWidgets('a shared event opened signed out opens once signed in', (
    tester,
  ) async {
    expect(await openThenSignIn(tester, '/planning/e1'), '/planning/e1');
  });

  testWidgets('an invitation opened signed out opens once signed in', (
    tester,
  ) async {
    expect(await openThenSignIn(tester, '/join/ABC'), '/join/ABC');
  });

  testWidgets('a link older than its lifetime leads home', (tester) async {
    final location = await openThenSignIn(
      tester,
      '/planning/e1',
      after: PendingLink.lifetime + const Duration(seconds: 1),
    );
    expect(location, '/');
  });

  testWidgets('the link is used once only', (tester) async {
    await openThenSignIn(tester, '/planning/e1');
    expect(PendingLink.take(), isNull);
  });

  testWidgets('a signed-in visitor goes straight to the link', (tester) async {
    signedIn(true);
    final router = await pumpRouter(tester);
    router.go('/planning/e1');
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), '/planning/e1');
  });
}
