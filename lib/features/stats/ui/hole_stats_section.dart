import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_avatar.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_icon_tile.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_section_header.dart';
import '../../live/domain/live_session_snapshot.dart';
import '../../players/data/players_repository.dart';
import '../data/stats_repository.dart';
import '../domain/hole_stats.dart';
import '../domain/player_stats.dart' show minHolePassages;
import 'player_stats_section.dart' show formatToPar;
import 'score_histogram.dart';
import 'stats_widgets.dart';

/// A hole's statistics (plan 20), in its sheet: key figures, record, king of
/// the hole and score distribution, over all time or one season. Common to
/// every association (Q95) and loaded on its own, so the sheet never waits
/// for it. [par] is the hole's own par, highlighted in the distribution.
class HoleStatsSection extends ConsumerWidget {
  const HoleStatsSection({super.key, required this.holeId, required this.par});

  final String holeId;
  final int par;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(holeHistoryProvider(holeId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NuniSectionHeader(title: l10n.statsTitle),
        historyAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: NuniLoading(),
          ),
          error: (error, _) => NuniErrorBanner(
            message: describeError(error, l10n),
            onRetry: () => ref.invalidate(holeHistoryProvider(holeId)),
          ),
          data: (history) =>
              _SeasonBreakdown(holeId: holeId, par: par, history: history),
        ),
      ],
    );
  }
}

class _SeasonBreakdown extends StatefulWidget {
  const _SeasonBreakdown({
    required this.holeId,
    required this.par,
    required this.history,
  });

  final String holeId;
  final int par;
  final List<LiveSessionSnapshot> history;

  @override
  State<_SeasonBreakdown> createState() => _SeasonBreakdownState();
}

class _SeasonBreakdownState extends State<_SeasonBreakdown> {
  /// What the viewer picked; the most recent season until then
  /// ([displayedSeason]).
  bool _allTime = false;
  String? _picked;

  @override
  Widget build(BuildContext context) {
    final seasons = playedHoleSeasons(widget.holeId, widget.history);
    final season = displayedSeason(
      seasons: seasons,
      allTime: _allTime,
      picked: _picked,
    );
    final stats = computeHoleStats(
      widget.holeId,
      widget.history,
      season: season,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (seasons.isNotEmpty) ...[
          SeasonChips(
            seasons: seasons,
            selected: season,
            onSelected: (s) => setState(() {
              _allTime = s == null;
              _picked = s;
            }),
          ),
          const SizedBox(height: 12),
        ],
        _StatsBody(stats: stats, par: widget.par),
      ],
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats, required this.par});

  final HoleStats stats;
  final int par;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final muted = textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    final rule = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(l10n.statsEligibilityRule, style: muted),
    );

    if (stats.sessions == 0) {
      return NuniCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.holeStatsEmpty, style: textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text(l10n.statsEligibilityRule, style: muted),
          ],
        ),
      );
    }

    final averageStrokes = stats.averageStrokes;
    final averageToPar = stats.averageToPar;
    final record = stats.record;
    final king = stats.king;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NuniCard(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              for (final (value, label) in [
                ('${stats.sessions}', l10n.statsSessions),
                ('${stats.passages}', l10n.holeStatsPassages),
                (
                  averageStrokes == null
                      ? '–'
                      : NumberFormat('0.0', locale).format(averageStrokes),
                  l10n.holeStatsAverageStrokes,
                ),
                (
                  averageToPar == null
                      ? '–'
                      : formatToPar(averageToPar, locale),
                  l10n.holeStatsToPar,
                ),
              ])
                Expanded(
                  child: StatFigure(value: value, label: label),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (record == null)
          NuniCard(
            child: Text(
              l10n.holeStatsNoIndividual,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          )
        else ...[
          NuniCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PlayerRow(
                  title: l10n.holeStatsRecord,
                  titleIcon: PhosphorIcons.medalFill,
                  titleTone: NuniTone.highlight,
                  playerId: record.playerId,
                  name: record.name,
                  detail: l10n.holeStatsRecordDetail(
                    record.strokes,
                    DateFormat.yMMMd(locale).format(record.date),
                  ),
                ),
                const Divider(height: 24),
                if (king != null)
                  _PlayerRow(
                    title: l10n.holeStatsKing,
                    titleIcon: PhosphorIcons.crownFill,
                    titleTone: NuniTone.sunshine,
                    playerId: king.playerId,
                    name: king.name,
                    detail: l10n.statsHoleDetail(
                      formatToPar(king.averageToPar, locale),
                      king.passages,
                    ),
                  )
                else
                  Row(
                    children: [
                      const NuniIconTile(
                        icon: PhosphorIcons.crown,
                        tone: NuniTone.neutral,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.holeStatsNoKing(minHolePassages),
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          NuniCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.holeStatsDistribution, style: textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(l10n.holeStatsDistributionCaption, style: muted),
                const SizedBox(height: 16),
                ScoreHistogram(distribution: stats.distribution, par: par),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        rule,
      ],
    );
  }
}

/// The record holder or the king of the hole: shown with their name and
/// photo even when they hid their statistics (Q109); a tap opens their page.
class _PlayerRow extends ConsumerWidget {
  const _PlayerRow({
    required this.title,
    required this.titleIcon,
    required this.titleTone,
    required this.playerId,
    required this.name,
    required this.detail,
  });

  final String title;

  /// Medal for the record, crown for the king (PO, 2026-09-24).
  final IconData titleIcon;
  final NuniTone titleTone;
  final String playerId;
  final String name;
  final String detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final avatarUrl = ref.watch(playerByIdProvider(playerId)).value?.avatarUrl;
    return InkWell(
      borderRadius: BorderRadius.circular(NuniRadius.small),
      onTap: () {
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        router.push('/players/$playerId');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            NuniAvatar(name: name, imageUrl: avatarUrl, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        titleIcon,
                        size: 16,
                        color: context.nuni.tone(titleTone).base,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        title,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Text(name, style: textTheme.titleSmall),
                  Text(detail, style: textTheme.bodySmall),
                ],
              ),
            ),
            Icon(PhosphorIcons.caretRight, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
