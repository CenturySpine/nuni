import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/phosphor_icons.dart';

/// The three bottom-nav destinations (Home, Holes, History), shared between
/// [AppShell] (inside the stateful shell, driven by the branch index) and
/// [NuniStandaloneBottomNav] (outside it).
class NuniBottomNavBar extends StatelessWidget {
  const NuniBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        NavigationDestination(
          icon: const Icon(PhosphorIcons.house),
          selectedIcon: const Icon(PhosphorIcons.houseFill),
          label: l10n.navHome,
        ),
        NavigationDestination(
          icon: const Icon(PhosphorIcons.golf),
          selectedIcon: const Icon(PhosphorIcons.golfFill),
          label: l10n.navHoles,
        ),
        NavigationDestination(
          icon: const Icon(PhosphorIcons.clockCounterClockwise),
          selectedIcon: const Icon(PhosphorIcons.clockCounterClockwiseFill),
          label: l10n.navHistory,
        ),
      ],
    );
  }
}

/// Drop-in bottom nav for a screen that lives outside the stateful shell --
/// currently only the session flow (`/session/*`, PO 2026-09-18: the bar
/// must stay visible there, but a session's own app bar rules out nesting it
/// in the shell, which would double up with the shared shell app bar).
/// Highlights Home: `NavigationBar` always needs a valid selected index, and
/// a session is always reached from there, so it's the closest parent tab.
class NuniStandaloneBottomNav extends StatelessWidget {
  const NuniStandaloneBottomNav({super.key});

  static const _paths = ['/', '/holes', '/history'];

  @override
  Widget build(BuildContext context) => NuniBottomNavBar(
    selectedIndex: 0,
    onDestinationSelected: (index) => context.go(_paths[index]),
  );
}
