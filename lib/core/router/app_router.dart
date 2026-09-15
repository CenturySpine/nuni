import 'package:go_router/go_router.dart';

import '../../features/home/ui/home_page.dart';

/// Application routes. Deep links (`/join/CODE`, `/session/ID`) come later.
final GoRouter appRouter = GoRouter(
  routes: [GoRoute(path: '/', builder: (context, state) => const HomePage())],
);
