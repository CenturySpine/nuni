import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_icon_tile.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_section_header.dart';
import '../../../shared/nuni_status_pill.dart';
import '../../players/data/players_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/player.dart';
import '../data/badges_repository.dart';
import '../data/seen_badges_store.dart';
import '../domain/badge.dart';
import 'badge_detail_sheet.dart';
import 'badge_medal.dart';
import 'badge_texts.dart';

/// A player's badges (plan 21), shared by my own profile and any player's
/// public page, like the statistics block (plan 19). Others see only the
/// badges earned, unless the player hid them (display only, Q133); I see
/// every badge of the catalogue, those still to earn greyed with their
/// progress (decision 17). On my profile ([showVisibilitySwitch]) it
/// carries the "Public badges" switch.
class PlayerBadgesSection extends ConsumerWidget {
  const PlayerBadgesSection({
    super.key,
    required this.player,
    required this.isMe,
    this.showVisibilitySwitch = false,
  });

  final Player player;
  final bool isMe;
  final bool showVisibilitySwitch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final header = NuniSectionHeader(title: l10n.badgesTitle);
    if (!player.badgesPublic && !isMe) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          NuniCard(
            child: Row(
              children: [
                const NuniIconTile(
                  icon: PhosphorIcons.lockSimple,
                  tone: NuniTone.neutral,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(l10n.badgesPrivate, style: textTheme.bodyLarge),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final badgesAsync = ref.watch(playerBadgesProvider(player.id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        if (showVisibilitySwitch) ...[
          _VisibilitySwitch(player: player),
          const SizedBox(height: 12),
        ] else if (!player.badgesPublic)
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.lockSimple,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.badgesPrivateSelfNote,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        badgesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: NuniLoading(),
          ),
          error: (error, _) => NuniErrorBanner(
            message: describeError(error, l10n),
            onRetry: () => ref.invalidate(playerBadgesProvider(player.id)),
          ),
          data: (results) => _BadgesBody(results: results, isMe: isMe),
        ),
      ],
    );
  }
}

/// The count, then one grid per family. On my own page, badges earned but
/// not yet seen here wear "New", and opening the section marks them seen.
class _BadgesBody extends ConsumerWidget {
  const _BadgesBody({required this.results, required this.isMe});

  final List<BadgeResult> results;
  final bool isMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final earnedCount = results.where((r) => r.earned).length;
    // "New": earned, and not yet seen here when the app started. Seeing
    // them now marks them for next time.
    final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
    final viewed = isMe && userId != null
        ? ref.watch(viewedBadgesAtStartProvider(userId)).value
        : null;
    if (viewed != null) {
      SeenBadgesStore(userId!).markViewed([
        for (final r in results)
          if (r.earned) r.id,
      ]);
    }

    final families = [
      for (final family in BadgeFamily.values)
        (
          family,
          [
            for (final r in results)
              if (r.id.family == family && (isMe || r.earned)) r,
          ],
        ),
    ].where((f) => f.$2.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NuniCard(
          child: Row(
            children: [
              const NuniIconTile(
                icon: PhosphorIcons.badgeMedalFill,
                tone: NuniTone.sunshine,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.badgesCount(earnedCount, results.length),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        if (families.isEmpty) ...[
          const SizedBox(height: 12),
          NuniCard(child: Text(l10n.badgesNone, style: textTheme.bodyLarge)),
        ],
        for (final (family, results) in families) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            // The family's name, and which sessions its badges read.
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(l10n.badgeFamilyName(family), style: textTheme.titleSmall),
                NuniStatusPill(
                  label: l10n.badgeScopeName(family.scope),
                  tone: switch (family.scope) {
                    BadgeScope.individual => NuniTone.primary,
                    BadgeScope.team => NuniTone.highlight,
                    BadgeScope.both => NuniTone.neutral,
                  },
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              for (final result in results)
                _BadgeTile(
                  result: result,
                  isMe: isMe,
                  isNew:
                      viewed != null &&
                      result.earned &&
                      !viewed.contains(result.id),
                ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            l10n.badgesEligibilityRule,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.result,
    required this.isMe,
    required this.isNew,
  });

  final BadgeResult result;
  final bool isMe;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final target = result.id.target;
    final showProgress =
        !result.earned && target != null && target > 1 && result.progress > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(NuniRadius.small),
      onTap: () => showBadgeDetailSheet(context, result, isMe: isMe),
      child: SizedBox(
        width: 84,
        child: Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 4),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  BadgeMedal(id: result.id, earned: result.earned, size: 56),
                  if (isNew)
                    Positioned(
                      top: -18,
                      child: NuniStatusPill(
                        label: l10n.badgesNew,
                        tone: NuniTone.highlight,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.badgeName(result.id),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textTheme.labelSmall?.copyWith(
                  color: result.earned ? null : scheme.onSurfaceVariant,
                ),
              ),
              if (showProgress) ...[
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: result.ratio,
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.badgesProgress(result.progress, target),
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Whether my badges show on my public page (plan 21, Q108), saved as soon
/// as it's flipped -- same as the statistics switch (plan 19).
class _VisibilitySwitch extends ConsumerStatefulWidget {
  const _VisibilitySwitch({required this.player});

  final Player player;

  @override
  ConsumerState<_VisibilitySwitch> createState() => _VisibilitySwitchState();
}

class _VisibilitySwitchState extends ConsumerState<_VisibilitySwitch> {
  bool _saving = false;

  Future<void> _toggle(bool value) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).updateMyBadgesPublic(value);
      ref
        ..invalidate(myPlayerProvider)
        ..invalidate(playerByIdProvider(widget.player.id));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(describeError(error, l10n))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NuniCard(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: SwitchListTile(
        title: Text(l10n.profileBadgesPublic),
        subtitle: Text(l10n.profileBadgesPublicHelp),
        value: widget.player.badgesPublic,
        onChanged: _saving ? null : _toggle,
      ),
    );
  }
}
