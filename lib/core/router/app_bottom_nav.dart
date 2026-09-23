import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/phosphor_icons.dart';

/// The four bottom-nav destinations (Home, Holes, History, Associations --
/// the last one put forward on purpose, plan 18 Q85), shared between
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
    // A hairline on top separates the bar from scrolling content.
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: NavigationBar(
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
          NavigationDestination(
            icon: const Icon(PhosphorIcons.usersThree),
            selectedIcon: const Icon(PhosphorIcons.usersThreeFill),
            label: l10n.navAssociations,
          ),
        ],
      ),
    );
  }
}

/// Drop-in bottom nav for a screen that lives outside the stateful shell --
/// the session flow (`/session/*`, PO 2026-09-18) and a finished session's
/// detail (`/history/:id`, PO 2026-09-23): the bar must stay visible there,
/// but their own app bars rule out nesting them in the shell, which would
/// double up with the shared shell app bar. `NavigationBar` always needs a
/// valid selected index: the closest parent tab is highlighted.
class NuniStandaloneBottomNav extends StatelessWidget {
  const NuniStandaloneBottomNav({super.key, this.selectedIndex = 0});

  /// The tab to highlight: Home by default; History for a finished
  /// session's detail page, reached from there.
  final int selectedIndex;

  static const _paths = ['/', '/holes', '/history', '/associations'];

  @override
  Widget build(BuildContext context) => NuniBottomNavBar(
    selectedIndex: selectedIndex,
    onDestinationSelected: (index) => context.go(_paths[index]),
  );
}
