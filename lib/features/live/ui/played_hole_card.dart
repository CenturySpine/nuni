import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_icon_tile.dart';
import '../../../shared/nuni_status_pill.dart';
import '../../holes/domain/hole.dart';
import '../../sessions/domain/scoring_mode.dart';
import '../domain/live_team.dart';
import '../domain/played_hole.dart';
import '../domain/score_calculator.dart';
import 'game_mode_label.dart';
import 'played_hole_label.dart';
import 'score_entry_sheet.dart';

/// One played hole (plan 08): every team's raw value (and, for Match
/// Play/Redistribution, the points that value earned on this hole -- see
/// the note below), tap-to-score inline for the teams [canEditTeam] allows.
/// Stroke Play shows strokes alone (there's no separate points concept for
/// it); Free shows points alone (no strokes are collected for it, Q7b).
/// [highlighted] (the latest hole) gets a violet outline.
class PlayedHoleCard extends StatelessWidget {
  const PlayedHoleCard({
    super.key,
    required this.playedHole,
    required this.teams,
    required this.scoringMode,
    required this.canEditTeam,
    required this.onScoreSubmit,
    this.highlighted = false,
    this.onDelete,
  });

  final PlayedHole playedHole;
  final List<LiveTeam> teams;
  final ScoringMode scoringMode;
  final bool Function(String teamId) canEditTeam;
  final Future<void> Function(String playedHoleId, String teamId, int value)
  onScoreSubmit;
  final bool highlighted;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final isPoints = scoringMode == ScoringMode.free;
    final needsPoints =
        scoringMode == ScoringMode.matchPlay ||
        scoringMode == ScoringMode.redistribution;
    final points = needsPoints
        ? calculateHolePoints(scoringMode, playedHole.valueByTeamId)
        : null;
    final isPrivate = playedHole.hole?.visibility == HoleVisibility.private;

    return NuniCard(
      borderColor: highlighted ? scheme.primary : null,
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NuniIconTile(
                icon: isPrivate ? PhosphorIcons.lockSimple : PhosphorIcons.golf,
                tone: highlighted ? NuniTone.primary : NuniTone.fairway,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.sessionsLiveHoleLabel(
                        playedHole.position,
                        playedHoleName(l10n, playedHole),
                      ),
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // A free hole has no par (plan 17).
                        if (playedHole.hole case final hole?)
                          NuniStatusPill(
                            label: l10n.holesPar(hole.par),
                            tone: NuniTone.fairway,
                          ),
                        NuniStatusPill(
                          label: gameModeLabel(l10n, playedHole.gameMode),
                          tone: NuniTone.neutral,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: Icon(
                    PhosphorIcons.trash,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  tooltip: l10n.sessionsLiveDeleteHole,
                  onPressed: onDelete,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Column(
              children: [
                for (final team in teams)
                  _TeamScoreRow(
                    team: team,
                    score: playedHole.scoreFor(team.id),
                    holePoints: points?[team.id],
                    editable: canEditTeam(team.id),
                    isPoints: isPoints,
                    showPoints: needsPoints,
                    onTap: () async {
                      final value = await showScoreEntrySheet(
                        context,
                        teamLabel: team.playerNames(),
                        isPoints: isPoints,
                        initialValue: playedHole.scoreFor(team.id)?.value,
                      );
                      if (value != null) {
                        await onScoreSubmit(playedHole.id, team.id, value);
                      }
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamScoreRow extends StatelessWidget {
  const _TeamScoreRow({
    required this.team,
    required this.score,
    required this.holePoints,
    required this.editable,
    required this.isPoints,
    required this.showPoints,
    required this.onTap,
  });

  final LiveTeam team;
  final HoleScore? score;
  final int? holePoints;
  final bool editable;
  final bool isPoints;
  final bool showPoints;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final nuni = context.nuni;

    final Widget valueWidget;
    if (score == null) {
      valueWidget = Text(
        l10n.sessionsLiveMissingScore,
        style: textTheme.labelMedium?.copyWith(color: scheme.error),
      );
    } else {
      final main = isPoints
          ? l10n.sessionsLivePointsValue(score!.value)
          : l10n.sessionsLiveStrokesValue(score!.value);
      valueWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            main,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (showPoints)
            Text(
              l10n.sessionsLivePointsValue(holePoints ?? 0),
              style: textTheme.labelMedium?.copyWith(
                color: nuni.primaryTone.onContainer,
              ),
            ),
        ],
      );
    }

    final row = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: score == null && editable
            ? nuni.danger.container.withValues(alpha: 0.6)
            : nuni.surfaceMuted,
        borderRadius: BorderRadius.circular(NuniRadius.small + 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.playerNames(),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          valueWidget,
          if (editable) ...[
            const SizedBox(width: 10),
            Icon(PhosphorIcons.pencilSimple, size: 16, color: scheme.primary),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: editable
          ? Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(NuniRadius.small + 2),
                onTap: onTap,
                child: row,
              ),
            )
          : row,
    );
  }
}
