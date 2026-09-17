import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/phosphor_icons.dart';
import '../../../core/weather/weather_icon.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_logo.dart';
import '../../history/domain/history_entry.dart';
import '../../live/domain/live_team.dart';
import '../../sessions/ui/scoring_mode_label.dart';

/// The "carte de résultats" (plan 10, Q16 -- both variants kept): a square
/// share card, either on the app's own themed background or overlaid on a
/// chosen photo. Captured to PNG via a `RepaintBoundary` around this widget
/// (see `image_export.dart`), so it's built at a fixed pixel size rather
/// than filling whatever space its parent gives it.
///
/// On a photo (PO feedback, 2026-09-17): the photo itself is never dimmed --
/// a first version darkened the whole image to keep the text legible, which
/// altered the photo too much. Instead, each text group sits on its own
/// small translucent backing panel, the photo unchanged everywhere else.
class ResultsCard extends StatelessWidget {
  const ResultsCard({
    super.key,
    required this.entry,
    this.backgroundImageBytes,
  });

  final HistoryEntry entry;
  final Uint8List? backgroundImageBytes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = entry.snapshot.session;
    final locale = Localizations.localeOf(context).toString();
    final teamById = {for (final t in entry.snapshot.teams) t.id: t};
    final onPhoto = backgroundImageBytes != null;
    final foreground = onPhoto ? Colors.white : null;

    final subtitleParts = [
      if (session.city != null && session.city!.isNotEmpty) session.city!,
      if (session.zone != null && session.zone!.isNotEmpty) session.zone!,
      if (session.startedAt != null)
        DateFormat.yMMMd(locale).format(session.startedAt!),
    ];

    Widget panel(Widget child) => !onPhoto
        ? child
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.38),
              borderRadius: BorderRadius.circular(12),
            ),
            child: child,
          );

    return Container(
      width: 1080,
      height: 1080,
      decoration: BoxDecoration(
        // With a photo, `contain` never crops it -- its own aspect ratio is
        // always kept, letterboxed on this black backdrop instead of the
        // square canvas stretching or cropping it to fit (PO feedback,
        // 2026-09-17). Without one, this same colour is just the flat card
        // background.
        color: onPhoto
            ? Colors.black
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        image: onPhoto
            ? DecorationImage(
                image: MemoryImage(backgroundImageBytes!),
                fit: BoxFit.contain,
              )
            : null,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const NuniLogo(size: 64),
              const SizedBox(width: 16),
              Expanded(
                child: panel(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        subtitleParts.isEmpty
                            ? session.code
                            : subtitleParts.join(' · '),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: foreground),
                      ),
                      Text(
                        scoringModeLabel(l10n, session.scoringMode),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: foreground?.withValues(alpha: 0.9),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              if (session.weather != null) ...[
                const SizedBox(width: 12),
                panel(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        weatherIcon(session.weather!.code),
                        size: 32,
                        color: foreground,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${session.weather!.temperatureC.round()}°C',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(color: foreground),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          panel(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final standing in entry.standings.take(5))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 56,
                          child: Text(
                            '${standing.position}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color:
                                      foreground ??
                                      Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            teamById[standing.teamId]?.playerNames() ?? '',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: foreground),
                          ),
                        ),
                        Text(
                          standing.totalPoints != null
                              ? l10n.sessionsLivePointsValue(
                                  standing.totalPoints!,
                                )
                              : l10n.sessionsLiveStrokesValue(
                                  standing.totalStrokes,
                                ),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: foreground),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.golf, size: 18, color: foreground),
                    const SizedBox(width: 6),
                    Text(
                      'NUNI — Never Up, Never In',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: foreground),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
