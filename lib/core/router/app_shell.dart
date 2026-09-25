import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/associations/data/association_choice_skip_pref.dart';
import '../../features/associations/data/associations_repository.dart';
import '../../features/associations/ui/association_choice_page.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/nuni_avatar.dart';
import '../../shared/nuni_logo.dart';
import 'app_bottom_nav.dart';

/// Bottom-bar shell for the top-level destinations (Home, Planning -- only
/// with an association, plan 23 --, Holes, History, Associations): the brand
/// mark and the current tab's name as a
/// large title, the player's avatar on the right opening Profile / Settings
/// -- there is no side drawer. A player with no association and no creation
/// request pending is offered the association choice first, unless they put
/// it off on this device (plan 18, decision 1, Q146).
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final player = ref.watch(myPlayerProvider).value;
    final pendingRequest = ref.watch(myPendingRequestProvider);
    final choiceSkipped = ref.watch(associationChoiceSkippedProvider);
    if (player != null &&
        player.associationId == null &&
        pendingRequest.hasValue &&
        pendingRequest.value == null &&
        choiceSkipped.value == false) {
      return const AssociationChoicePage();
    }
    final titles = [
      l10n.navHome,
      l10n.navHoles,
      l10n.navHistory,
      l10n.navAssociations,
      l10n.navPlanning,
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 68,
        titleSpacing: 16,
        title: Row(
          children: [
            const NuniLogo(size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titles[navigationShell.currentIndex],
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: l10n.settingsTitle,
              icon: NuniAvatar(
                name: player?.name,
                imageUrl: player?.avatarUrl,
                size: 36,
              ),
              onPressed: () => context.push('/settings'),
            ),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NuniBottomNavBar(
        selectedBranch: navigationShell.currentIndex,
        showPlanning: player?.associationId != null,
        onBranchSelected: (branch) => navigationShell.goBranch(
          branch,
          initialLocation: branch == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
