import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nuni/features/auth/ui/auth_page.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';
import 'package:nuni/shared/nuni_logo.dart';

Future<void> _pump(WidgetTester tester, String initialLocation) async {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthPage(isSignUp: false),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const AuthPage(isSignUp: true),
      ),
      GoRoute(
        path: '/legal',
        builder: (context, state) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const SizedBox.shrink(),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('login page: brand top-left, "Sign Up" link, no home shell', (
    tester,
  ) async {
    await _pump(tester, '/login');

    expect(find.byType(NuniLogo), findsOneWidget);
    expect(find.text('Log in to NUNI'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('signup page: same layout, "Log In" link, different heading', (
    tester,
  ) async {
    await _pump(tester, '/signup');

    expect(find.byType(NuniLogo), findsOneWidget);
    expect(find.text('Sign up for NUNI'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
