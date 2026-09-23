import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// A selectable pill (scoring mode, game mode, quick radius, city
/// filter...): white with a hairline when idle, primary tint and outline
/// when selected.
class NuniChip extends StatelessWidget {
  const NuniChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final nuni = context.nuni;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
      selectedColor: nuni.primaryTone.container,
      side: BorderSide(
        color: selected ? nuni.palette.primary : nuni.border,
        width: 1.5,
      ),
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: selected ? nuni.primaryTone.onContainer : null,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
      ),
      showCheckmark: false,
    );
  }
}
