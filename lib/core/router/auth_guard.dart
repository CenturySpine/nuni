import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pending_join_code.dart';

/// Redirects `/join/:code` visitors to `/login` after remembering their code
/// (plan 09 picks it back up once the user is signed in). Stub until plan 05
/// wires real auth state: every other route is reachable for now.
/// TODO(plan 05): redirect an unauthenticated visitor to '/login' for every
/// route except '/login', '/legal', '/privacy', '/about'.
GoRouterRedirect authGuard(Ref ref) {
  return (context, state) {
    final path = state.matchedLocation;

    if (path.startsWith('/join/')) {
      ref
          .read(pendingJoinCodeProvider.notifier)
          .set(state.pathParameters['code']);
      return '/login';
    }

    return null;
  };
}
