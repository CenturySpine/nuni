import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/ui/auth_page.dart';
import '../../features/championship/ui/championship_page.dart';
import '../../features/history/ui/history_detail_page.dart';
import '../../features/history/ui/history_page.dart';
import '../../features/holes/ui/hole_form_page.dart';
import '../../features/holes/ui/holes_page.dart';
import '../../features/home/ui/home_page.dart';
import '../../features/join/ui/join_page.dart';
import '../../features/legal/ui/about_page.dart';
import '../../features/legal/ui/legal_page.dart';
import '../../features/legal/ui/privacy_page.dart';
import '../../features/profile/ui/profile_page.dart';
import '../../features/sessions/ui/session_create_page.dart';
import '../../features/sessions/ui/session_room_page.dart';
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

/// Routes not wired yet: `/session/:id/hole/:playedHoleId` -- no plan has
/// needed a dedicated per-hole screen so far.
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
      GoRoute(
        path: '/holes/new',
        builder: (context, state) => const HoleFormPage(),
      ),
      GoRoute(
        path: '/holes/:id',
        builder: (context, state) =>
            HoleFormPage(holeId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/join/:code',
        builder: (context, state) =>
            JoinPage(code: state.pathParameters['code']!),
      ),
      GoRoute(
        path: '/session/new',
        builder: (context, state) => const SessionCreatePage(),
      ),
      GoRoute(
        path: '/session/:id',
        builder: (context, state) =>
            SessionRoomPage(sessionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/history/:id',
        builder: (context, state) =>
            HistoryDetailPage(sessionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/championship',
        builder: (context, state) => const ChampionshipPage(),
      ),
      if (kDebugMode)
        GoRoute(
          path: '/dev/theme',
          builder: (context, state) => const ThemeDemoPage(),
        ),
    ],
  );
});
