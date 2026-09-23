import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_icon_tile.dart';
import '../../../shared/nuni_rank_badge.dart';
import '../../sessions/domain/scoring_mode.dart';
import '../../sessions/domain/session.dart';
import '../domain/live_team.dart';
import '../domain/played_hole.dart';
import '../domain/team_standing.dart';

/// Collapsible ranking card (plan 08): a one-line leader summary when
/// collapsed, the full ranked list when expanded, and a "scores incomplete"
/// warning whenever a team is missing a score for a played hole.
class RankingCard extends StatefulWidget {
  const RankingCard({
    super.key,
    required this.session,
    required this.teams,
    required this.playedHoles,
  });

  final Session session;
  final List<LiveTeam> teams;
  final List<PlayedHole> playedHoles;

  @override
  State<RankingCard> createState() => _RankingCardState();
}

class _RankingCardState extends State<RankingCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mode = widget.session.scoringMode;
    final standings = computeStandings(
      scoringMode: mode,
      rankingDirection: widget.session.rankingDirection,
      teams: widget.teams,
      playedHoles: widget.playedHoles,
    );
    final teamById = {for (final team in widget.teams) team.id: team};
    final incomplete =
        widget.playedHoles.isNotEmpty && standings.any((s) => !s.isComplete);
    final leaders = [
      for (final standing in standings)
        if (standing.position == 1) standing,
    ];

    return NuniCard(
      onTap: standings.isEmpty
          ? null
          : () => setState(() => _expanded = !_expanded),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.sessionsLiveRankingTitle,
                      style: textTheme.titleMedium,
                    ),
                    if (!_expanded && leaders.isNotEmpty)
                      Text(
                        leaders.length == 1
                            ? l10n.sessionsLiveRankingLeader(
                                teamById[leaders.single.teamId]
                                        ?.playerNames() ??
                                    '',
                              )
                            : l10n.sessionsLiveRankingLeaderTied(
                                leaders
                                    .map(
                                      (s) =>
                                          teamById[s.teamId]?.playerNames() ??
                                          '',
                                    )
                                    .join(', '),
                              ),
                        style: textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              if (standings.isNotEmpty)
                AnimatedRotation(
                  turns: _expanded ? 0.75 : 0.25,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    PhosphorIcons.caretRight,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          if (incomplete) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(NuniRadius.small),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.warningCircle,
                    size: 16,
                    color: scheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.sessionsLiveRankingIncomplete,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_expanded) ...[
            const SizedBox(height: 12),
            for (final standing in standings)
              _StandingRow(
                standing: standing,
                team: teamById[standing.teamId],
                mode: mode,
              ),
          ],
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({
    required this.standing,
    required this.team,
    required this.mode,
  });

  final TeamStanding standing;
  final LiveTeam? team;
  final ScoringMode mode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final metric = mode == ScoringMode.strokePlay
        ? l10n.sessionsLiveStrokesValue(standing.totalStrokes)
        : l10n.sessionsLivePointsValue(standing.totalPoints ?? 0);
    final leader = standing.position == 1;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: leader ? context.nuni.sunshine.container : null,
        borderRadius: BorderRadius.circular(NuniRadius.small),
      ),
      child: Row(
        children: [
          NuniRankBadge(
            label: '${standing.position}',
            position: standing.position,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              team?.playerNames() ?? '',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: leader ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(metric, style: textTheme.labelLarge),
          if (!standing.isComplete) ...[
            const SizedBox(width: 6),
            Text(
              '${standing.holesScored}/${standing.holesTotal}',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
