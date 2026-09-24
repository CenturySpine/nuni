import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_chip.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_hero.dart';
import '../../../shared/nuni_icon_tile.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_rank_badge.dart';
import '../../profile/data/profile_repository.dart';
import '../data/championship_repository.dart';
import '../domain/championship_season.dart';
import '../domain/player_standing.dart';

/// `/championship` (plans 15 and 18): full classement of one
/// association/season, with an association switcher (a visitor also appears
/// in the championship of the association that hosted them, Q77) and a season
/// selector (past seasons, once there are any). Opens on
/// [initialAssociationId]/[initialSeason] when given (the home tab's cards and
/// championship history, Q72), otherwise on the current season and, within
/// it, the first association the caller played for.
class ChampionshipPage extends ConsumerStatefulWidget {
  const ChampionshipPage({
    super.key,
    this.initialAssociationId,
    this.initialSeason,
  });

  final String? initialAssociationId;
  final String? initialSeason;

  @override
  ConsumerState<ChampionshipPage> createState() => _ChampionshipPageState();
}

class _ChampionshipPageState extends ConsumerState<ChampionshipPage> {
  late String? _associationId = widget.initialAssociationId;
  late String? _season = widget.initialSeason;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final membershipsAsync = ref.watch(myChampionshipMembershipsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.championshipTitle)),
      body: membershipsAsync.when(
        loading: () => const NuniLoading(),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: NuniErrorBanner(
            message: describeError(error, l10n),
            onRetry: () => ref.invalidate(myChampionshipMembershipsProvider),
          ),
        ),
        data: (memberships) {
          if (memberships.isEmpty) {
            return NuniEmptyState(
              icon: PhosphorIcons.crown,
              message: l10n.championshipEmpty,
            );
          }

          // My association first (Q88): the switcher's first chip and the
          // default when the page opens without a given association.
          final myAssociationId = ref
              .watch(myPlayerProvider)
              .value
              ?.associationId;
          final associationIds = {
            for (final m in memberships)
              if (m.associationId == myAssociationId) m.associationId,
            for (final m in memberships) m.associationId,
          };
          final associationId =
              _associationId != null && associationIds.contains(_associationId)
              ? _associationId!
              : associationIds.first;
          final seasons = {
            for (final m in memberships)
              if (m.associationId == associationId) m.season,
          }.toList()..sort((a, b) => b.compareTo(a));
          final season = _season != null && seasons.contains(_season)
              ? _season!
              : (seasons.contains(currentChampionshipSeason())
                    ? currentChampionshipSeason()
                    : seasons.first);

          return _AssociationSeasonView(
            associationIds: associationIds.toList(),
            seasons: seasons,
            associationId: associationId,
            season: season,
            onAssociationChanged: (id) => setState(() {
              _associationId = id;
              _season = null;
            }),
            onSeasonChanged: (s) => setState(() => _season = s),
          );
        },
      ),
    );
  }
}

class _AssociationSeasonView extends ConsumerWidget {
  const _AssociationSeasonView({
    required this.associationIds,
    required this.seasons,
    required this.associationId,
    required this.season,
    required this.onAssociationChanged,
    required this.onSeasonChanged,
  });

  final List<String> associationIds;
  final List<String> seasons;
  final String associationId;
  final String season;
  final ValueChanged<String> onAssociationChanged;
  final ValueChanged<String> onSeasonChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final standingsAsync = ref.watch(
      championshipStandingsProvider(associationId, season),
    );
    final myPlayerAsync = ref.watch(myPlayerProvider);
    final myPlayerId = myPlayerAsync.asData?.value.id;
    final associationLabelAsync = ref.watch(
      championshipAssociationLabelProvider(associationId),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        NuniHero(
          child: Row(
            children: [
              const NuniIconTile(
                icon: PhosphorIcons.crown,
                tone: NuniTone.sunshine,
                size: 48,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      associationLabelAsync.asData?.value ?? associationId,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    Text(
                      season,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary
                            .withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (associationIds.length > 1) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final id in associationIds)
                _AssociationChip(
                  associationId: id,
                  selected: id == associationId,
                  onTap: () => onAssociationChanged(id),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        if (seasons.length > 1) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in seasons)
                NuniChip(
                  label: s,
                  selected: s == season,
                  onTap: () => onSeasonChanged(s),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        standingsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: NuniLoading(),
          ),
          error: (error, _) =>
              NuniErrorBanner(message: describeError(error, l10n)),
          data: (standings) => standings.isEmpty
              ? NuniEmptyState(
                  icon: PhosphorIcons.crown,
                  message: l10n.championshipEmpty,
                )
              : Column(
                  children: [
                    for (final standing in standings)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _StandingRow(
                          standing: standing,
                          isMe: standing.playerId == myPlayerId,
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _AssociationChip extends ConsumerWidget {
  const _AssociationChip({
    required this.associationId,
    required this.selected,
    required this.onTap,
  });

  final String associationId;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelAsync = ref.watch(
      championshipAssociationLabelProvider(associationId),
    );
    return NuniChip(
      label: labelAsync.asData?.value ?? associationId,
      selected: selected,
      onTap: onTap,
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({required this.standing, required this.isMe});

  final PlayerStanding standing;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NuniCard(
      // Opens the player's public page (plan 26, volet C).
      onTap: () => context.push('/players/${standing.playerId}'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: isMe ? context.nuni.primaryTone.container : null,
      borderColor: isMe ? context.nuni.primaryInk : null,
      child: Row(
        children: [
          NuniRankBadge(
            label: '${standing.position}',
            position: standing.position,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  standing.playerName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isMe ? context.nuni.primaryTone.onContainer : null,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l10n.championshipSessionsPlayed(standing.sessionsPlayed),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            l10n.championshipPointsValue(standing.totalPoints),
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
