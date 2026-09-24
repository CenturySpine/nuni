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
import '../../../shared/nuni_chip.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_icon_tile.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_section_header.dart';
import '../../live/domain/live_session_snapshot.dart';
import '../../players/data/players_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/player.dart';
import '../data/stats_repository.dart';
import '../domain/player_stats.dart';
import 'season_chart.dart';

/// "+0,8", "-0,3" or "0,0" in the current language: strokes against par,
/// signed, one decimal.
String formatToPar(double value, String locale) {
  final rounded = (value * 10).round() / 10;
  if (rounded == 0) return NumberFormat('0.0', locale).format(0);
  return NumberFormat('+0.0;-0.0', locale).format(rounded);
}

/// A player's statistics block (plan 19), shared by my own profile and any
/// player's public page. Hidden from others when the player turned it off
/// (display only, Q133); the player always sees their own. On my profile
/// ([showVisibilitySwitch]) it carries the "Public statistics" switch;
/// elsewhere, my own hidden statistics show a reminder instead.
class PlayerStatsSection extends ConsumerWidget {
  const PlayerStatsSection({
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

    final header = NuniSectionHeader(title: l10n.statsTitle);
    if (!player.statsPublic && !isMe) {
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
                  child: Text(l10n.statsPrivate, style: textTheme.bodyLarge),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final historyAsync = ref.watch(playerHistoryProvider(player.id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        if (showVisibilitySwitch) ...[
          _VisibilitySwitch(player: player),
          const SizedBox(height: 12),
        ] else if (!player.statsPublic)
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
                    l10n.statsPrivateSelfNote,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        historyAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: NuniLoading(),
          ),
          error: (error, _) => NuniErrorBanner(
            message: describeError(error, l10n),
            onRetry: () => ref.invalidate(playerHistoryProvider(player.id)),
          ),
          data: (history) =>
              _SeasonBreakdown(playerId: player.id, history: history),
        ),
      ],
    );
  }
}

/// All time or one season (PO, 2026-09-24): chips on top, then the whole
/// block recomputed for the choice. All time by default. The chips show even
/// for a single season: they also say which season the numbers come from.
class _SeasonBreakdown extends StatefulWidget {
  const _SeasonBreakdown({required this.playerId, required this.history});

  final String playerId;
  final List<LiveSessionSnapshot> history;

  @override
  State<_SeasonBreakdown> createState() => _SeasonBreakdownState();
}

class _SeasonBreakdownState extends State<_SeasonBreakdown> {
  /// Null = all time.
  String? _season;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final seasons = playedSeasons(widget.playerId, widget.history);
    final season = seasons.contains(_season) ? _season : null;
    final stats = computePlayerStats(
      widget.playerId,
      widget.history,
      season: season,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (seasons.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              NuniChip(
                label: l10n.statsAllTime,
                selected: season == null,
                onTap: () => setState(() => _season = null),
              ),
              for (final s in seasons)
                NuniChip(
                  label: s,
                  selected: s == season,
                  onTap: () => setState(() => _season = s),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        _StatsBody(
          stats: stats,
          curveTitle: season == null
              ? l10n.statsCurveAllTime
              : l10n.statsCurveSeason(season),
        ),
      ],
    );
  }
}

/// Whether my statistics show on my public page (plan 19, Q108), saved as
/// soon as it's flipped.
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
      await ref.read(profileRepositoryProvider).updateMyStatsPublic(value);
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
        title: Text(l10n.profileStatsPublic),
        subtitle: Text(l10n.profileStatsPublicHelp),
        value: widget.player.statsPublic,
        onChanged: _saving ? null : _toggle,
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats, required this.curveTitle});

  final PlayerStats stats;
  final String curveTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    if (stats.sessionsPlayed == 0) {
      return NuniCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.statsEmpty, style: textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text(
              l10n.statsEligibilityRule,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final parReport = stats.parReport;
    final team = stats.team;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _KeyFigures(stats: stats),
        const SizedBox(height: 12),
        if (parReport == null)
          NuniCard(
            child: Text(
              l10n.statsNoIndividual,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          )
        else ...[
          _ParReportCard(report: parReport),
          const SizedBox(height: 12),
          if (stats.bestHole != null)
            _HolesCard(best: stats.bestHole!, worst: stats.worstHole)
          else
            NuniCard(
              child: Text(
                l10n.statsHolesNotEnough(minHolePassages),
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          if (stats.curve.isNotEmpty) ...[
            const SizedBox(height: 12),
            _CurveCard(title: curveTitle, points: stats.curve),
          ],
        ],
        if (team != null) ...[
          const SizedBox(height: 24),
          NuniSectionHeader(title: l10n.statsTeamTitle),
          _TeamCard(team: team),
        ],
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            l10n.statsEligibilityRule,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// A number and its label, for the key figures rows.
class _Figure extends StatelessWidget {
  const _Figure({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _KeyFigures extends StatelessWidget {
  const _KeyFigures({required this.stats});

  final PlayerStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NuniCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        children: [
          for (final (value, label) in [
            (stats.sessionsPlayed, l10n.statsSessions),
            (stats.wins, l10n.statsWins),
            (stats.podiums, l10n.statsPodiums),
            (stats.holesPlayed, l10n.statsHolesPlayed),
          ])
            Expanded(
              child: _Figure(value: '$value', label: label),
            ),
        ],
      ),
    );
  }
}

class _ParReportCard extends StatelessWidget {
  const _ParReportCard({required this.report});

  final ParReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final nuni = context.nuni;
    final shares = [
      (report.birdieOrBetter, l10n.statsBirdieOrBetter, nuni.fairway.base),
      (report.pars, l10n.statsParShare, nuni.sunshine.base),
      (report.bogeyOrWorse, l10n.statsBogeyOrWorse, nuni.highlight.base),
    ];
    final percent = NumberFormat.percentPattern(locale);

    return NuniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.statsParTitle, style: textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formatToPar(report.averageToPar, locale),
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              Text(l10n.statsPerHole, style: textTheme.bodyLarge),
            ],
          ),
          Text(
            l10n.statsOverHoles(report.holes),
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          // One bar split in three, then its legend with percentages.
          ClipRRect(
            borderRadius: BorderRadius.circular(NuniRadius.small),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  for (final (count, _, color) in shares)
                    if (count > 0)
                      Expanded(
                        flex: count,
                        child: Container(color: color),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final (count, label, color) in shares)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(label, style: textTheme.bodyMedium)),
                  Text(
                    percent.format(count / report.holes),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HolesCard extends StatelessWidget {
  const _HolesCard({required this.best, required this.worst});

  final HoleAverage best;
  final HoleAverage? worst;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NuniCard(
      child: Column(
        children: [
          _HoleRow(
            title: l10n.statsBestHole,
            hole: best,
            icon: PhosphorIcons.starFill,
            tone: NuniTone.fairway,
          ),
          if (worst != null) ...[
            const Divider(height: 24),
            _HoleRow(
              title: l10n.statsWorstHole,
              hole: worst!,
              icon: PhosphorIcons.warningCircle,
              tone: NuniTone.highlight,
            ),
          ],
        ],
      ),
    );
  }
}

class _HoleRow extends StatelessWidget {
  const _HoleRow({
    required this.title,
    required this.hole,
    required this.icon,
    required this.tone,
  });

  final String title;
  final HoleAverage hole;
  final IconData icon;
  final NuniTone tone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        NuniIconTile(icon: icon, tone: tone),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Text(hole.name, style: textTheme.titleSmall),
              Text(
                l10n.statsHoleDetail(
                  formatToPar(hole.averageToPar, locale),
                  hole.passages,
                ),
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CurveCard extends StatelessWidget {
  const _CurveCard({required this.title, required this.points});

  final String title;
  final List<CurvePoint> points;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return NuniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(
            l10n.statsSeasonCaption,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SeasonChart(
            points: points,
            formatToPar: (value) => formatToPar(value, locale),
            parLabel: l10n.statsParAxis,
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.team});

  final TeamStats team;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mate = team.mostFrequentTeammate;
    final duo = team.bestDuo;
    return NuniCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Row(
            children: [
              for (final (value, label) in [
                (team.sessions, l10n.statsSessions),
                (team.wins, l10n.statsWins),
                (team.podiums, l10n.statsPodiums),
              ])
                Expanded(
                  child: _Figure(value: '$value', label: label),
                ),
            ],
          ),
          if (mate != null) ...[
            const Divider(height: 24),
            _TeammateRow(
              title: l10n.statsTeammate,
              teammate: mate,
              detail: l10n.statsTeammateDetail(mate.sessions),
            ),
          ],
          if (duo != null) ...[
            const Divider(height: 24),
            _TeammateRow(
              title: l10n.statsBestDuo,
              teammate: duo,
              detail: l10n.statsBestDuoDetail(duo.wins, duo.sessions),
            ),
          ],
        ],
      ),
    );
  }
}

class _TeammateRow extends StatelessWidget {
  const _TeammateRow({
    required this.title,
    required this.teammate,
    required this.detail,
  });

  final String title;
  final TeammateStat teammate;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(NuniRadius.small),
      onTap: () => context.push('/players/${teammate.playerId}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            NuniAvatar(name: teammate.name, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text(teammate.name, style: textTheme.titleSmall),
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
