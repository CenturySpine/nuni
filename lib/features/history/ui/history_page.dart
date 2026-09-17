import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../core/weather/weather_icon.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_loading.dart';
import '../../live/domain/live_team.dart';
import '../../sessions/ui/scoring_mode_label.dart';
import '../data/history_repository.dart';
import '../domain/history_entry.dart';

/// History tab body (plan 10): every completed session the caller is a
/// member of, most recent first, with a simple city filter.
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  String? _cityFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entriesAsync = ref.watch(historyEntriesProvider);

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
        final visible = _cityFilter == null
            ? entries
            : [
                for (final e in entries)
                  if (e.snapshot.session.city == _cityFilter) e,
              ];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            if (cities.length > 1) ...[
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.historyFilterAllCities),
                    selected: _cityFilter == null,
                    onSelected: (_) => setState(() => _cityFilter = null),
                  ),
                  for (final city in cities)
                    ChoiceChip(
                      label: Text(city),
                      selected: _cityFilter == city,
                      onSelected: (_) => setState(() => _cityFilter = city),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            for (final entry in visible) ...[
              _HistoryCard(entry: entry),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _HistoryCard extends ConsumerWidget {
  const _HistoryCard({required this.entry});

  final HistoryEntry entry;

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

    return NuniCard(
      onTap: () => context.push('/history/${session.id}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (session.coverPhotoPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                ref
                    .read(historyRepositoryProvider)
                    .photoUrl(session.coverPhotoPath!),
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                PhosphorIcons.golf,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitleParts.isEmpty
                      ? session.code
                      : subtitleParts.join(' · '),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '${session.startedAt == null ? '' : DateFormat.yMMMd(locale).format(session.startedAt!.toLocal())} · '
                  '${scoringModeLabel(l10n, session.scoringMode)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (leaders.isNotEmpty)
                  Text(
                    leaders
                        .map((s) => teamById[s.teamId]?.playerNames() ?? '')
                        .join(', '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
          if (session.weather != null) ...[
            Icon(
              weatherIcon(session.weather!.code),
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              '${session.weather!.temperatureC.round()}°',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
