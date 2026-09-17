import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../holes/domain/hole.dart';
import '../../sessions/domain/scoring_mode.dart';
import 'game_mode_label.dart';
import '../domain/live_team.dart';
import '../domain/played_hole.dart';
import '../domain/score_calculator.dart';
import 'score_entry_sheet.dart';

/// One played hole (plan 08): every team's raw value (and, for Match
/// Play/Redistribution, the points that value earned on this hole -- see
/// the note below), tap-to-score inline for the teams [canEditTeam] allows.
/// Stroke Play shows strokes alone (there's no separate points concept for
/// it); Free shows points alone (no strokes are collected for it, Q7b).
class PlayedHoleCard extends StatelessWidget {
  const PlayedHoleCard({
    super.key,
    required this.playedHole,
    required this.teams,
    required this.scoringMode,
    required this.canEditTeam,
    required this.playerNameForUserId,
    required this.onScoreSubmit,
    this.highlighted = false,
    this.onDelete,
  });

  final PlayedHole playedHole;
  final List<LiveTeam> teams;
  final ScoringMode scoringMode;
  final bool Function(String teamId) canEditTeam;
  final String? Function(String userId) playerNameForUserId;
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

    return Card(
      clipBehavior: Clip.antiAlias,
      color: highlighted ? scheme.secondaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  playedHole.hole.visibility == HoleVisibility.private
                      ? PhosphorIcons.lockSimple
                      : PhosphorIcons.golf,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.sessionsLiveHoleLabel(
                      playedHole.position,
                      playedHole.hole.name,
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(PhosphorIcons.trash, size: 18),
                    tooltip: l10n.sessionsLiveDeleteHole,
                    onPressed: onDelete,
                  ),
              ],
            ),
            Text(
              '${l10n.holesPar(playedHole.hole.par)} · ${gameModeLabel(l10n, playedHole.gameMode)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final team in teams)
              _TeamScoreRow(
                team: team,
                score: playedHole.scoreFor(team.id),
                holePoints: points?[team.id],
                editable: canEditTeam(team.id),
                isPoints: isPoints,
                showPoints: needsPoints,
                editorName: playedHole.scoreFor(team.id)?.updatedBy == null
                    ? null
                    : playerNameForUserId(
                        playedHole.scoreFor(team.id)!.updatedBy!,
                      ),
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
    required this.editorName,
    required this.onTap,
  });

  final LiveTeam team;
  final HoleScore? score;
  final int? holePoints;
  final bool editable;
  final bool isPoints;
  final bool showPoints;
  final String? editorName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();

    final Widget valueWidget;
    if (score == null) {
      valueWidget = Text(
        l10n.sessionsLiveMissingScore,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: scheme.error),
      );
    } else if (isPoints) {
      valueWidget = Text(
        l10n.sessionsLivePointsValue(score!.value),
        style: Theme.of(context).textTheme.titleSmall,
      );
    } else if (showPoints) {
      valueWidget = Text(
        '${l10n.sessionsLiveStrokesValue(score!.value)} · ${l10n.sessionsLivePointsValue(holePoints ?? 0)}',
        style: Theme.of(context).textTheme.titleSmall,
      );
    } else {
      valueWidget = Text(
        l10n.sessionsLiveStrokesValue(score!.value),
        style: Theme.of(context).textTheme.titleSmall,
      );
    }

    final row = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                team.playerNames(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (score != null && editorName != null)
                Text(
                  score!.updatedAt == null
                      ? editorName!
                      : l10n.sessionsLiveScoreUpdatedBy(
                          editorName!,
                          DateFormat.Hm(locale)
                              .format(score!.updatedAt!.toLocal()),
                        ),
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
        valueWidget,
        if (editable) ...[
          const SizedBox(width: 4),
          Icon(
            PhosphorIcons.pencilSimple,
            size: 14,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: editable
          ? InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: row,
            )
          : row,
    );
  }
}
