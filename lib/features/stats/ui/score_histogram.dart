import 'package:flutter/material.dart';

/// The score distribution of a hole (plan 20, Q134): one bar per number of
/// strokes, from the fewest to the most ever made (empty ones included, so
/// gaps show), the count above each bar and the [par] column in the full
/// primary colour. Plain widgets in the palette's colours, no chart library.
class ScoreHistogram extends StatelessWidget {
  const ScoreHistogram({
    super.key,
    required this.distribution,
    required this.par,
    this.barHeight = 110,
  });

  /// Passages per number of strokes; not empty.
  final Map<int, int> distribution;
  final int par;
  final double barHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final strokes = distribution.keys.toList()..sort();
    final highest = distribution.values.reduce((a, b) => a > b ? a : b);
    final countStyle = textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var s = strokes.first; s <= strokes.last; s++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    distribution[s] == null ? '' : '${distribution[s]}',
                    style: countStyle,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    height: distribution[s] == null
                        ? 0
                        : (barHeight * distribution[s]! / highest).clamp(
                            4,
                            barHeight,
                          ),
                    decoration: BoxDecoration(
                      color: s == par
                          ? scheme.primary
                          : scheme.primary.withValues(alpha: 0.35),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  Divider(height: 1, thickness: 1, color: scheme.outline),
                  const SizedBox(height: 4),
                  Text(
                    '$s',
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: s == par ? FontWeight.w800 : null,
                      color: s == par
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
