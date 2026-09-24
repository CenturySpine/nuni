import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_avatar.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_loading.dart';
import '../../stats/ui/player_stats_section.dart';
import '../data/players_repository.dart';

/// `/players/:id` (plan 26, volet C): a player's public page -- photo and
/// display name, then their statistics (plan 19) unless they hid them;
/// badges (plan 21) will be added below. Open to every signed-in account,
/// for any player, imported ones included.
class PlayerPage extends ConsumerWidget {
  const PlayerPage({super.key, required this.playerId});

  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final playerAsync = ref.watch(playerByIdProvider(playerId));
    final myUserId = ref.watch(supabaseClientProvider).auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.playerPageTitle)),
      body: playerAsync.when(
        loading: () => const NuniLoading(),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: NuniErrorBanner(
            message: describeError(error, l10n),
            onRetry: () => ref.invalidate(playerByIdProvider(playerId)),
          ),
        ),
        data: (player) => player == null
            ? NuniEmptyState(
                icon: PhosphorIcons.warningCircle,
                message: l10n.playerPageNotFound,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
                children: [
                  Center(
                    child: NuniAvatar(
                      name: player.name,
                      imageUrl: player.avatarUrl,
                      size: 120,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      player.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 32),
                  PlayerStatsSection(
                    player: player,
                    isMe: myUserId != null && player.userId == myUserId,
                  ),
                ],
              ),
      ),
    );
  }
}
