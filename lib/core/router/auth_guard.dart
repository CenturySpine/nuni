import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../supabase/supabase_providers.dart';
import 'pending_join_code.dart';

const _publicPaths = {'/login', '/signup', '/legal', '/privacy', '/about'};
const _authPaths = {'/login', '/signup'};

/// Redirects signed-out visitors to `/login` for every route except the
/// public ones; redirects a signed-in visitor away from `/login`/`/signup`.
/// `/join/:code` for a signed-out visitor is remembered then redirected to
/// `/login`; once signed in, the redirect away from `/login`/`/signup`
/// picks the code back up instead of going home (plan 09). A signed-in
/// visitor hitting `/join/:code` directly (already had a session, e.g. an
/// existing account clicking an invite link) reaches it with no redirect.
GoRouterRedirect authGuard(Ref ref) {
  return (context, state) {
    final path = state.matchedLocation;
    final isSignedIn =
        ref.read(supabaseClientProvider).auth.currentSession != null;

    if (path.startsWith('/join/')) {
      if (isSignedIn) return null;
      ref
          .read(pendingJoinCodeProvider.notifier)
          .set(state.pathParameters['code']);
      return '/login';
    }

    // The component gallery (debug builds only, see app_router.dart) needs
    // no account.
    final isDevPage = kDebugMode && path == '/dev/theme';
    if (!isSignedIn && !_publicPaths.contains(path) && !isDevPage) {
      return '/login';
    }
    if (isSignedIn && _authPaths.contains(path)) {
      final pendingCode = ref.read(pendingJoinCodeProvider);
      if (pendingCode != null) {
        ref.read(pendingJoinCodeProvider.notifier).set(null);
        return '/join/$pendingCode';
      }
      return '/';
    }
    return null;
  };
}
