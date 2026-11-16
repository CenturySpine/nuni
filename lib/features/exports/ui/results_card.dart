import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../core/weather/weather_icon.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_logo.dart';
import '../../history/domain/history_entry.dart';
import '../../live/domain/live_team.dart';
import '../../sessions/ui/scoring_mode_label.dart';
import '../../sessions/ui/session_nature.dart';
import '../../stats/domain/eligible_session.dart';

/// The "carte de résultats" (plan 10, Q16 -- both variants kept): a share
/// card that looks like a screen of the app, in the palette the user picked
/// (PO, 2026-11-16) -- the app's page background, the heading, the
/// standings in a card, the signature. With a photo, it sits whole, at its
/// own ratio and never written on, between the heading and the standings,
/// with a thin margin around it. The card is as tall as its content.
/// Earlier versions laid the texts over the photo on translucent panels
/// (which hid faces), then painted the whole card with the brand gradient
/// (too much colour).
///
/// Captured to PNG via a `RepaintBoundary` around this widget (see
/// `image_export.dart`), so it's built at a fixed pixel width rather than
/// filling whatever space its parent gives it.
class ResultsCard extends StatelessWidget {
  const ResultsCard({
    super.key,
    required this.entry,
    this.backgroundImageBytes,
    this.photoAspectRatio,
  });

  final HistoryEntry entry;
  final Uint8List? backgroundImageBytes;

  /// The photo's own width/height ratio (decoded by the caller, which has
  /// the raw bytes before they're ever handed here). Ignored without a
  /// photo.
  final double? photoAspectRatio;

  static const _cardWidth = 1080.0;
  static const _padding = 20.0;

  /// The background left visible on each side of the photo and of the
  /// standings card.
  static const _margin = 12.0;

  /// The black line around the photo.
  static const _photoBorderWidth = 4.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = entry.snapshot.session;
    final locale = Localizations.localeOf(context).toString();
    final teamById = {for (final t in entry.snapshot.teams) t.id: t};
    final photo = backgroundImageBytes;
    final scheme = Theme.of(context).colorScheme;
    final foreground = scheme.onSurface;
    final textTheme = Theme.of(context).textTheme;
    TextStyle? styled(TextStyle? style, {Color? color, FontWeight? weight}) =>
        style?.copyWith(color: color ?? foreground, fontWeight: weight);

    final subtitleParts = [
      sessionHeading(session),
      if (session.startedAt != null)
        DateFormat.yMMMd(locale).format(session.startedAt!),
    ];

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const NuniLogo(size: 64),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                subtitleParts.join(' · '),
                style: styled(textTheme.headlineMedium),
              ),
              Text(
                [
                  // The place, when the name is the title (plan 31).
                  ?sessionSubheading(session),
                  // Without a scorecard, its natures (plan 29).
                  if (session.scoringMode case final mode?)
                    scoringModeLabel(l10n, mode)
                  else
                    sessionNatureLabels(l10n, session).join(' · '),
                ].join(' · '),
                style: styled(
                  textTheme.titleMedium,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (session.weather != null) ...[
          const SizedBox(width: 12),
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
                style: styled(textTheme.titleLarge),
              ),
            ],
          ),
        ],
      ],
    );

    final standings = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!session.hasScoring)
          Text(
            l10n.sessionsAttendeesCount(sessionPlayerCount(entry.snapshot)),
            style: styled(textTheme.titleLarge),
          ),
        for (final standing in entry.standings.take(5))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    '${standing.position}',
                    style: styled(
                      textTheme.headlineSmall,
                      weight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    teamById[standing.teamId]?.playerNames() ?? '',
                    style: styled(textTheme.titleLarge),
                  ),
                ),
                Text(
                  standing.totalPoints != null
                      ? l10n.sessionsLivePointsValue(standing.totalPoints!)
                      : l10n.sessionsLiveStrokesValue(standing.totalStrokes),
                  style: styled(textTheme.titleLarge),
                ),
              ],
            ),
          ),
      ],
    );

    final signature = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(PhosphorIcons.golf, size: 18, color: context.nuni.primaryInk),
        const SizedBox(width: 6),
        Text(
          'NUNI — Never Up, Never In',
          style: styled(
            textTheme.bodyMedium,
            color: context.nuni.primaryInk,
            weight: FontWeight.w700,
          ),
        ),
      ],
    );

    final photoWidth = _cardWidth - 2 * _margin;
    return Container(
      width: _cardWidth,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: _padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _padding),
            child: header,
          ),
          const SizedBox(height: 16),
          if (photo != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(_margin, 0, _margin, _margin),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(NuniRadius.card),
                ),
                // Drawn over the photo's edge, not around it, so the photo
                // keeps its exact ratio.
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(NuniRadius.card),
                  border: Border.all(
                    color: Colors.black,
                    width: _photoBorderWidth,
                  ),
                ),
                child: Image.memory(
                  photo,
                  width: photoWidth,
                  height: photoWidth / (photoAspectRatio ?? 1),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _margin),
            child: NuniCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: standings,
            ),
          ),
          const SizedBox(height: 16),
          signature,
        ],
      ),
    );
  }
}
