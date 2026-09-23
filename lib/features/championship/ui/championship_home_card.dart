import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_icon_tile.dart';
import '../../../shared/nuni_list_card.dart';
import '../../../shared/nuni_rank_badge.dart';
import '../../../shared/nuni_section_header.dart';
import '../../profile/data/profile_repository.dart';
import '../data/championship_repository.dart';
import '../domain/championship_membership.dart';
import '../domain/championship_season.dart';

/// Opens the full classement on one zone/season (plan 15, Q72).
void _openClassement(BuildContext context, String zoneId, String season) =>
    context.push(
      Uri(
        path: '/championship',
        queryParameters: {'zone': zoneId, 'season': season},
      ).toString(),
    );

/// Championship section of the home tab (plan 15): provisional standing
/// card(s) for the current season (parcours 2), then the championship
/// history -- one line per past zone/season, like the session history (Q72).
/// Nothing at all if the caller has no championship session (no empty screen
/// to explain).
class ChampionshipHomeSection extends ConsumerWidget {
  const ChampionshipHomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipsAsync = ref.watch(myChampionshipMembershipsProvider);
    final season = currentChampionshipSeason();

    return membershipsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (memberships) {
        final zoneIds = {
          for (final m in memberships)
            if (m.season == season) m.zoneId,
        };
        final past = pastMemberships(memberships, season);
        if (zoneIds.isEmpty && past.isEmpty) return const SizedBox.shrink();

        final l10n = AppLocalizations.of(context)!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NuniSectionHeader(title: l10n.championshipTitle),
              for (final zoneId in zoneIds) ...[
                _ZoneCard(zoneId: zoneId, season: season),
                const SizedBox(height: 10),
              ],
              if (past.isNotEmpty) ...[
                const SizedBox(height: 6),
                NuniSectionHeader(
                  title: l10n.championshipPastTitle,
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                ),
                for (final m in past) ...[
                  _PastChampionshipRow(zoneId: m.zoneId, season: m.season),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

/// One past zone/season: the caller's final position among the players
/// ranked, and their total points.
class _PastChampionshipRow extends ConsumerWidget {
  const _PastChampionshipRow({required this.zoneId, required this.season});

  final String zoneId;
  final String season;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final standings = ref
        .watch(championshipZoneStandingsProvider(zoneId, season))
        .asData
        ?.value;
    final label = ref
        .watch(championshipZoneLabelProvider(zoneId))
        .asData
        ?.value;
    final myPlayerId = ref.watch(myPlayerProvider).asData?.value.id;
    final mine = standings?.where((s) => s.playerId == myPlayerId).firstOrNull;

    return NuniListCard(
      onTap: () => _openClassement(context, zoneId, season),
      leading: const NuniIconTile(
        icon: PhosphorIcons.crown,
        tone: NuniTone.neutral,
      ),
      title: '${label ?? l10n.championshipTitle} · $season',
      subtitle: mine == null
          ? null
          : '${l10n.championshipFinalPosition(mine.position, standings!.length)}'
                ' · ${l10n.championshipPointsValue(mine.totalPoints)}',
    );
  }
}

class _ZoneCard extends ConsumerWidget {
  const _ZoneCard({required this.zoneId, required this.season});

  final String zoneId;
  final String season;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final standingsAsync = ref.watch(
      championshipZoneStandingsProvider(zoneId, season),
    );
    final labelAsync = ref.watch(championshipZoneLabelProvider(zoneId));
    final myPlayerAsync = ref.watch(myPlayerProvider);

    return standingsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (standings) {
        final myPlayerId = myPlayerAsync.asData?.value.id;
        final myIndex = standings.indexWhere((s) => s.playerId == myPlayerId);
        if (myIndex == -1) return const SizedBox.shrink();

        // Podium first, then my own row if I'm not on it (PO, 2026-09-23:
        // the leader must always show); the full standings are one tap away.
        const podiumSize = 3;
        final podium = standings.take(podiumSize).toList();
        final showMine = myIndex >= podiumSize;
        final textTheme = Theme.of(context).textTheme;
        final highlight = context.nuni.primaryTone;

        return NuniCard(
          onTap: () => _openClassement(context, zoneId, season),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const NuniIconTile(
                    icon: PhosphorIcons.crown,
                    tone: NuniTone.sunshine,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      '${labelAsync.asData?.value ?? l10n.championshipTitle} · $season',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    PhosphorIcons.caretRight,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final standing in [
                ...podium,
                if (showMine) standings[myIndex],
              ]) ...[
                if (showMine && standing == standings[myIndex])
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 2),
                    child: Text('⋯', style: textTheme.titleMedium),
                  ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: standing.playerId == myPlayerId
                        ? highlight.container
                        : null,
                    borderRadius: BorderRadius.circular(NuniRadius.small),
                  ),
                  child: Row(
                    children: [
                      NuniRankBadge(
                        label: '${standing.position}',
                        position: standing.position,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          standing.playerName,
                          style: standing.playerId == myPlayerId
                              ? textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: highlight.onContainer,
                                )
                              : textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        l10n.championshipPointsValue(standing.totalPoints),
                        style: textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _openClassement(context, zoneId, season),
                  child: Text(l10n.championshipSeeFullStandings),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
