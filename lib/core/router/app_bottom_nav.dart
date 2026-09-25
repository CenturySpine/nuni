import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/profile/data/profile_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../theme/phosphor_icons.dart';

/// The shell's branches, in [StatefulShellRoute] order: Planning (plan 23)
/// came last, so the other branches kept their index.
const shellPaths = ['/', '/holes', '/history', '/associations', '/planning'];

/// The branch index of the Planning tab.
const planningBranch = 4;

/// The order the tabs are shown in: Planning right after Home (Q156), and
/// only for a player with an association.
List<int> _shownBranches({required bool showPlanning}) =>
    showPlanning ? const [0, planningBranch, 1, 2, 3] : const [0, 1, 2, 3];

/// The bottom-nav destinations (Home, Planning, Holes, History,
/// Associations -- the last one put forward on purpose, plan 18 Q85),
/// shared between [AppShell] (inside the stateful shell, driven by the
/// branch index) and [NuniStandaloneBottomNav] (outside it). Works with
/// branch indexes: the Planning tab may be hidden, which shifts positions.
class NuniBottomNavBar extends StatelessWidget {
  const NuniBottomNavBar({
    super.key,
    required this.selectedBranch,
    required this.onBranchSelected,
    required this.showPlanning,
  });

  final int selectedBranch;
  final ValueChanged<int> onBranchSelected;
  final bool showPlanning;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Shown while on it, whatever [showPlanning] says: the player (and so
    // their association) may still be loading.
    final branches = _shownBranches(
      showPlanning: showPlanning || selectedBranch == planningBranch,
    );
    final destinations = {
      0: NavigationDestination(
        icon: const Icon(PhosphorIcons.house),
        selectedIcon: const Icon(PhosphorIcons.houseFill),
        label: l10n.navHome,
      ),
      1: NavigationDestination(
        icon: const Icon(PhosphorIcons.golf),
        selectedIcon: const Icon(PhosphorIcons.golfFill),
        label: l10n.navHoles,
      ),
      2: NavigationDestination(
        icon: const Icon(PhosphorIcons.clockCounterClockwise),
        selectedIcon: const Icon(PhosphorIcons.clockCounterClockwiseFill),
        label: l10n.navHistory,
      ),
      3: NavigationDestination(
        icon: const Icon(PhosphorIcons.usersThree),
        selectedIcon: const Icon(PhosphorIcons.usersThreeFill),
        label: l10n.navAssociations,
      ),
      planningBranch: NavigationDestination(
        icon: const Icon(PhosphorIcons.calendarDots),
        selectedIcon: const Icon(PhosphorIcons.calendarDotsFill),
        label: l10n.navPlanning,
      ),
    };
    final position = branches.indexOf(selectedBranch);

    // A hairline on top separates the bar from scrolling content.
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: NavigationBar(
        selectedIndex: position < 0 ? 0 : position,
        onDestinationSelected: (index) => onBranchSelected(branches[index]),
        destinations: [for (final branch in branches) destinations[branch]!],
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
class NuniStandaloneBottomNav extends ConsumerWidget {
  const NuniStandaloneBottomNav({super.key, this.selectedBranch = 0});

  /// The tab to highlight, as a branch index: Home by default; History for
  /// a finished session's detail page, reached from there.
  final int selectedBranch;

  @override
  Widget build(BuildContext context, WidgetRef ref) => NuniBottomNavBar(
    selectedBranch: selectedBranch,
    showPlanning: ref.watch(myPlayerProvider).value?.associationId != null,
    onBranchSelected: (branch) => context.go(shellPaths[branch]),
  );
}
