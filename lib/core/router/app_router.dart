import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/ui/auth_page.dart';
import '../../features/history/ui/history_page.dart';
import '../../features/holes/ui/holes_page.dart';
import '../../features/home/ui/home_page.dart';
import '../../features/legal/ui/about_page.dart';
import '../../features/legal/ui/legal_page.dart';
import '../../features/legal/ui/privacy_page.dart';
import '../../features/profile/ui/profile_page.dart';
import '../../features/settings/ui/settings_page.dart';
import '../supabase/supabase_providers.dart';
import '../theme/theme_demo_page.dart';
import 'app_shell.dart';
import 'auth_guard.dart';
import 'not_found_page.dart';

/// Turns a stream into a [Listenable] for [GoRouter.refreshListenable]: the
/// `GoRouterRefreshStream` helper that used to ship with go_router for
/// exactly this was removed from the package (v5.0.0, 2022) in favour of
/// letting apps write their own -- this is that standard ~10-line adapter.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Routes not wired yet: `/session/new`, `/session/:id`,
/// `/session/:id/hole/:playedHoleId`, `/history/:id`, `/holes/new`,
/// `/holes/:id` -- added by the plans that build those screens (06-10).
final appRouterProvider = Provider<GoRouter>((ref) {
  final authChanges = ref.watch(supabaseClientProvider).auth.onAuthStateChange;
  return GoRouter(
    // Re-evaluates `redirect` on sign-in/sign-out, not just on navigation.
    refreshListenable: _GoRouterRefreshStream(authChanges),
    redirect: authGuard(ref),
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/', builder: (context, state) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/holes',
                builder: (context, state) => const HolesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthPage(isSignUp: false),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const AuthPage(isSignUp: true),
      ),
      GoRoute(path: '/legal', builder: (context, state) => const LegalPage()),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyPage(),
      ),
      GoRoute(path: '/about', builder: (context, state) => const AboutPage()),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      // Never actually built: the redirect in authGuard always fires first.
      GoRoute(
        path: '/join/:code',
        builder: (context, state) => const SizedBox.shrink(),
      ),
      if (kDebugMode)
        GoRoute(
          path: '/dev/theme',
          builder: (context, state) => const ThemeDemoPage(),
        ),
    ],
  );
});
