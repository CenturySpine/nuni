import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/phosphor_icons.dart';

import '../../l10n/generated/app_localizations.dart';
import 'app_bottom_nav.dart';

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
      bottomNavigationBar: NuniBottomNavBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
