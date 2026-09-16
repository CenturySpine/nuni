import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nuni/features/auth/ui/login_page.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';
import 'package:nuni/shared/nuni_logo.dart';

void main() {
  testWidgets(
    'LoginPage carries the branding and legal links, not the home shell',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginPage(),
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

      expect(find.byType(NuniLogo), findsOneWidget);
      expect(find.text('Never Up, Never In'), findsOneWidget);
      // No home shell chrome on this page.
      expect(find.byType(NavigationBar), findsNothing);
    },
  );
}
