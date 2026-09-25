import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../supabase/supabase_providers.dart';
import 'pending_link.dart';

const _publicPaths = {'/login', '/signup', '/legal', '/privacy', '/about'};
const _authPaths = {'/login', '/signup'};

/// Pages a shared link leads to (an invitation, plan 09; an event, plan 23):
/// a signed-out visitor is sent to sign in, then lands on them.
bool _isSharedLink(String path) =>
    path.startsWith('/join/') || path.startsWith('/planning/');

/// Redirects signed-out visitors to `/login` for every route except the
/// public ones; redirects a signed-in visitor away from `/login`/`/signup`.
/// A shared link opened signed out is remembered ([PendingLink]) and opened
/// once signed in, instead of home -- whether the sign-in ends on
/// `/login`/`/signup` or, after the Google redirect reloads the app, on `/`.
GoRouterRedirect authGuard(Ref ref) {
  return (context, state) {
    final path = state.matchedLocation;
    final isSignedIn =
        ref.read(supabaseClientProvider).auth.currentSession != null;

    // The component gallery (debug builds only, see app_router.dart) needs
    // no account.
    final isDevPage = kDebugMode && path == '/dev/theme';
    if (!isSignedIn && !_publicPaths.contains(path) && !isDevPage) {
      if (_isSharedLink(path)) PendingLink.remember(state.uri.toString());
      return '/login';
    }
    if (isSignedIn && (_authPaths.contains(path) || path == '/')) {
      final pending = PendingLink.take();
      if (pending != null) return pending;
      if (_authPaths.contains(path)) return '/';
    }
    return null;
  };
}
