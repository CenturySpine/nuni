import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../supabase/supabase_providers.dart';
import 'pending_join_code.dart';

const _publicPaths = {'/login', '/signup', '/legal', '/privacy', '/about'};
const _authPaths = {'/login', '/signup'};

/// Redirects signed-out visitors to `/login` for every route except the
/// public ones; redirects a signed-in visitor away from `/login`/`/signup`.
/// `/join/:code` is remembered then redirected to `/login` regardless of
/// auth state (plan 09 picks it back up once signed in).
GoRouterRedirect authGuard(Ref ref) {
  return (context, state) {
    final path = state.matchedLocation;

    if (path.startsWith('/join/')) {
      ref
          .read(pendingJoinCodeProvider.notifier)
          .set(state.pathParameters['code']);
      return '/login';
    }

    final isSignedIn =
        ref.read(supabaseClientProvider).auth.currentSession != null;

    if (!isSignedIn && !_publicPaths.contains(path)) return '/login';
    if (isSignedIn && _authPaths.contains(path)) return '/';
    return null;
  };
}
