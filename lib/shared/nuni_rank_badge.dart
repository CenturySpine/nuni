import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// A ranking position in a round badge: gold for the leader, violet for the
/// podium, neutral after that. The only way positions are drawn.
class NuniRankBadge extends StatelessWidget {
  const NuniRankBadge({
    super.key,
    required this.label,
    required this.position,
    this.size = 30,
  });

  /// The text shown ("1", "2e", "1st"...), already localised by the caller.
  final String label;
  final int position;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tone = context.nuni.tone(switch (position) {
      1 => NuniTone.sunshine,
      2 || 3 => NuniTone.primary,
      _ => NuniTone.neutral,
    });
    return Container(
      constraints: BoxConstraints(minWidth: size),
      height: size,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: tone.container,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: tone.onContainer,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}
