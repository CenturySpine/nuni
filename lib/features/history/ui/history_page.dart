import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../core/weather/weather_icon.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_chip.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_icon_tile.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_status_pill.dart';
import '../../live/domain/live_team.dart';
import '../../profile/data/profile_repository.dart';
import '../../sessions/domain/session_kind.dart';
import '../../sessions/ui/scoring_mode_label.dart';
import '../../sessions/ui/session_kind_label.dart';
import '../data/history_repository.dart';
import '../domain/history_entry.dart';

/// History tab body (plan 10, reshaped by plan 26, Q129): every completed
/// session of the caller's association (plus the ones they played in
/// elsewhere), most recent first. A discreet marker flags the ones the
/// caller played in, a "Mes sessions" filter keeps only those, and a simple
/// city filter remains. No session in progress here: those are on home.
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  String? _cityFilter;
  bool _mineOnly = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entriesAsync = ref.watch(historyEntriesProvider);
    final myPlayerId = ref.watch(myPlayerProvider).value?.id;

    return entriesAsync.when(
      loading: () => const NuniLoading(),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: NuniErrorBanner(
          message: describeError(error, l10n),
          onRetry: () => ref.invalidate(historyEntriesProvider),
        ),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return NuniEmptyState(
            icon: PhosphorIcons.clockCounterClockwise,
            message: l10n.historyEmpty,
          );
        }

        final cities = <String>{
          for (final e in entries)
            if (e.snapshot.session.city case final city? when city.isNotEmpty)
              city,
        }.toList()..sort();
        final visible = [
          for (final e in entries)
            if ((_cityFilter == null ||
                    e.snapshot.session.city == _cityFilter) &&
                (!_mineOnly || e.playedBy(myPlayerId)))
              e,
        ];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                NuniChip(
                  label: l10n.historyFilterMine,
                  selected: _mineOnly,
                  onTap: () => setState(() => _mineOnly = !_mineOnly),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (cities.length > 1) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  NuniChip(
                    label: l10n.historyFilterAllCities,
                    selected: _cityFilter == null,
                    onTap: () => setState(() => _cityFilter = null),
                  ),
                  for (final city in cities)
                    NuniChip(
                      label: city,
                      selected: _cityFilter == city,
                      onTap: () => setState(() => _cityFilter = city),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (visible.isEmpty)
              NuniEmptyState(
                icon: PhosphorIcons.clockCounterClockwise,
                message: l10n.historyEmptyMine,
              ),
            for (final entry in visible) ...[
              _HistoryCard(
                entry: entry,
                playedByMe: entry.playedBy(myPlayerId),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _HistoryCard extends ConsumerWidget {
  const _HistoryCard({required this.entry, required this.playedByMe});

  final HistoryEntry entry;
  final bool playedByMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = entry.snapshot.session;
    final locale = Localizations.localeOf(context).toString();
    final teamById = {for (final t in entry.snapshot.teams) t.id: t};
    final leaders = entry.leaders;

    final subtitleParts = [
      if (session.city != null && session.city!.isNotEmpty) session.city!,
      if (session.zone != null && session.zone!.isNotEmpty) session.zone!,
    ];

    final textTheme = Theme.of(context).textTheme;

    return NuniCard(
      onTap: () => context.push('/history/${session.id}'),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (session.coverPhotoPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(NuniRadius.control),
              child: Image.network(
                ref
                    .read(historyRepositoryProvider)
                    .photoUrl(session.coverPhotoPath!),
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            )
          else
            NuniIconTile(
              icon: session.kind == SessionKind.team
                  ? PhosphorIcons.users
                  : PhosphorIcons.golf,
              tone: session.kind == SessionKind.team
                  ? NuniTone.primary
                  : NuniTone.fairway,
              size: 64,
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        subtitleParts.isEmpty
                            ? session.code
                            : subtitleParts.join(' · '),
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // "I played in it" marker (plan 26, Q129): small and
                    // quiet, the card itself stays the same.
                    if (playedByMe) ...[
                      const SizedBox(width: 6),
                      Tooltip(
                        message: l10n.historyPlayedByMe,
                        child: Icon(
                          PhosphorIcons.userCheck,
                          size: 16,
                          semanticLabel: l10n.historyPlayedByMe,
                          color: context.nuni.primaryInk,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.startedAt == null ? '' : DateFormat.yMMMd(locale).format(session.startedAt!.toLocal())} · '
                  '${sessionKindLabel(l10n, session.kind)} · '
                  '${scoringModeLabel(l10n, session.scoringMode)}',
                  style: textTheme.bodySmall,
                ),
                if (leaders.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.crown,
                        size: 16,
                        color: context.nuni.sunshine.onContainer,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          leaders
                              .map(
                                (s) => teamById[s.teamId]?.playerNames() ?? '',
                              )
                              .join(', '),
                          style: textTheme.labelLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (session.weather != null) ...[
            const SizedBox(width: 8),
            NuniStatusPill(
              label: '${session.weather!.temperatureC.round()}°',
              icon: weatherIcon(session.weather!.code),
              tone: NuniTone.neutral,
            ),
          ],
        ],
      ),
    );
  }
}
