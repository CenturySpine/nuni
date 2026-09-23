import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_card.dart';
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
        final titleStyle = Theme.of(context).textTheme.titleMedium;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(l10n.championshipTitle, style: titleStyle),
            ),
            for (final zoneId in zoneIds) ...[
              _ZoneCard(zoneId: zoneId, season: season),
              const SizedBox(height: 12),
            ],
            if (past.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  l10n.championshipPastTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              for (final m in past) ...[
                _PastChampionshipRow(zoneId: m.zoneId, season: m.season),
                const SizedBox(height: 8),
              ],
            ],
          ],
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

    return NuniCard(
      onTap: () => _openClassement(context, zoneId, season),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.crown,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${label ?? l10n.championshipTitle} · $season',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (mine != null)
                  Text(
                    '${l10n.championshipFinalPosition(mine.position, standings!.length)}'
                    ' · ${l10n.championshipPointsValue(mine.totalPoints)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          const Icon(PhosphorIcons.caretRight, size: 18),
        ],
      ),
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

        final start = (myIndex - 1).clamp(0, standings.length);
        final end = (myIndex + 2).clamp(0, standings.length);
        final neighbors = standings.sublist(start, end);

        return NuniCard(
          onTap: () => _openClassement(context, zoneId, season),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIcons.crown,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${labelAsync.asData?.value ?? l10n.championshipTitle} · $season',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Icon(PhosphorIcons.caretRight, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              for (final standing in neighbors)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${standing.position}',
                          style: standing.playerId == myPlayerId
                              ? Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)
                              : Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          standing.playerName,
                          style: standing.playerId == myPlayerId
                              ? Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)
                              : Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        l10n.championshipPointsValue(standing.totalPoints),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
