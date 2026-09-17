import 'package:flutter/material.dart';

import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_card.dart';
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
              Icon(PhosphorIcons.crown, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.sessionsLiveRankingTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (standings.isNotEmpty)
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: const Icon(PhosphorIcons.caretRight),
                ),
            ],
          ),
          if (!_expanded && leaders.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              leaders.length == 1
                  ? l10n.sessionsLiveRankingLeader(
                      teamById[leaders.single.teamId]?.playerNames() ?? '',
                    )
                  : l10n.sessionsLiveRankingLeaderTied(
                      leaders
                          .map((s) => teamById[s.teamId]?.playerNames() ?? '')
                          .join(', '),
                    ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (incomplete) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  PhosphorIcons.warningCircle,
                  size: 16,
                  color: scheme.error,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.sessionsLiveRankingIncomplete,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: scheme.error),
                ),
              ],
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
    final metric = mode == ScoringMode.strokePlay
        ? l10n.sessionsLiveStrokesValue(standing.totalStrokes)
        : l10n.sessionsLivePointsValue(standing.totalPoints ?? 0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              l10n.sessionsLiveRankingPosition(standing.position),
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: scheme.primary),
            ),
          ),
          Expanded(
            child: Text(
              team?.playerNames() ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(metric, style: Theme.of(context).textTheme.labelLarge),
          if (!standing.isComplete) ...[
            const SizedBox(width: 6),
            Text(
              '${standing.holesScored}/${standing.holesTotal}',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
