import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_chip.dart';

/// The season choice of a statistics block: [allTime] once the viewer
/// picked "all time", else the season they picked, else the most recent
/// season played (PO, 2026-09-24: open on the current season, so records and
/// kings are back in play every September). A new season with no session yet
/// falls back to the last one played rather than an empty block. Null means
/// all time; [seasons] is most recent first.
String? displayedSeason({
  required List<String> seasons,
  required bool allTime,
  required String? picked,
}) {
  if (allTime || seasons.isEmpty) return null;
  return seasons.contains(picked) ? picked : seasons.first;
}

/// All time or one season (PO, 2026-09-24), shared by the player's and the
/// hole's statistics: "all time" ([selected] null) then each of [seasons].
/// Shown even for a single season: it also says which season the numbers
/// come from.
class SeasonChips extends StatelessWidget {
  const SeasonChips({
    super.key,
    required this.seasons,
    required this.selected,
    required this.onSelected,
  });

  final List<String> seasons;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        NuniChip(
          label: l10n.statsAllTime,
          selected: selected == null,
          onTap: () => onSelected(null),
        ),
        for (final s in seasons)
          NuniChip(
            label: s,
            selected: s == selected,
            onTap: () => onSelected(s),
          ),
      ],
    );
  }
}

/// A number and its label, for the key figures rows.
class StatFigure extends StatelessWidget {
  const StatFigure({super.key, required this.value, required this.label});

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
