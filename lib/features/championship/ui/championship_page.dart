import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_chip.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_loading.dart';
import '../../profile/data/profile_repository.dart';
import '../data/championship_repository.dart';
import '../domain/championship_season.dart';
import '../domain/player_standing.dart';

/// `/championship` (plan 15, parcours 3): full classement of one zone/season,
/// with a zone switcher (Q45's scope: a player can appear in several zones
/// the same season) and a season selector (past seasons, once there are
/// any). Defaults to the current season and, within it, the first zone the
/// caller belongs to.
class ChampionshipPage extends ConsumerStatefulWidget {
  const ChampionshipPage({super.key});

  @override
  ConsumerState<ChampionshipPage> createState() => _ChampionshipPageState();
}

class _ChampionshipPageState extends ConsumerState<ChampionshipPage> {
  String? _zoneId;
  String? _season;

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

          final zoneIds = {for (final m in memberships) m.zoneId};
          final zoneId = _zoneId != null && zoneIds.contains(_zoneId)
              ? _zoneId!
              : zoneIds.first;
          final seasons = {
            for (final m in memberships)
              if (m.zoneId == zoneId) m.season,
          }.toList()..sort((a, b) => b.compareTo(a));
          final season = _season != null && seasons.contains(_season)
              ? _season!
              : (seasons.contains(currentChampionshipSeason())
                    ? currentChampionshipSeason()
                    : seasons.first);

          return _ZoneSeasonView(
            zoneIds: zoneIds.toList(),
            seasons: seasons,
            zoneId: zoneId,
            season: season,
            onZoneChanged: (id) => setState(() {
              _zoneId = id;
              _season = null;
            }),
            onSeasonChanged: (s) => setState(() => _season = s),
          );
        },
      ),
    );
  }
}

class _ZoneSeasonView extends ConsumerWidget {
  const _ZoneSeasonView({
    required this.zoneIds,
    required this.seasons,
    required this.zoneId,
    required this.season,
    required this.onZoneChanged,
    required this.onSeasonChanged,
  });

  final List<String> zoneIds;
  final List<String> seasons;
  final String zoneId;
  final String season;
  final ValueChanged<String> onZoneChanged;
  final ValueChanged<String> onSeasonChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final standingsAsync = ref.watch(
      championshipZoneStandingsProvider(zoneId, season),
    );
    final myPlayerAsync = ref.watch(myPlayerProvider);
    final myPlayerId = myPlayerAsync.asData?.value.id;
    final zoneLabelAsync = ref.watch(championshipZoneLabelProvider(zoneId));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          '${zoneLabelAsync.asData?.value ?? zoneId} · $season',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        if (zoneIds.length > 1) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final id in zoneIds)
                _ZoneChip(
                  zoneId: id,
                  selected: id == zoneId,
                  onTap: () => onZoneChanged(id),
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
                        padding: const EdgeInsets.only(bottom: 8),
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

class _ZoneChip extends ConsumerWidget {
  const _ZoneChip({
    required this.zoneId,
    required this.selected,
    required this.onTap,
  });

  final String zoneId;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelAsync = ref.watch(championshipZoneLabelProvider(zoneId));
    return NuniChip(
      label: labelAsync.asData?.value ?? zoneId,
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
    final scheme = Theme.of(context).colorScheme;

    return NuniCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${standing.position}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  standing.playerName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isMe ? scheme.primary : null,
                    fontWeight: isMe ? FontWeight.bold : null,
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
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
