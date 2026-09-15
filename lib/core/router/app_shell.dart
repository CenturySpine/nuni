import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/phosphor_icons.dart';

import '../../l10n/generated/app_localizations.dart';

/// Bottom-bar shell for the three top-level destinations (Home, Holes,
/// History). The avatar in the app bar opens Profile / Settings -- there is
/// no side drawer.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const CircleAvatar(
              radius: 16,
              child: Icon(PhosphorIcons.userCircle, size: 18),
            ),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
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
      ),
    );
  }
}
