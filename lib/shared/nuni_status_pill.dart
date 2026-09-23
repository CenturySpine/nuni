import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// A small tinted label ("En direct", "En préparation", "Championnat", a
/// count...). [dot] adds a leading coloured dot, used for live states.
class NuniStatusPill extends StatelessWidget {
  const NuniStatusPill({
    super.key,
    required this.label,
    this.tone = NuniTone.primary,
    this.icon,
    this.dot = false,
  });

  final String label;
  final NuniTone tone;
  final IconData? icon;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final colors = context.nuni.tone(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: colors.base,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, size: 14, color: colors.onContainer),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.onContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
