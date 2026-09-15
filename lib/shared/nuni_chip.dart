import 'package:flutter/material.dart';

/// A selectable chip (scoring mode, game mode, quick radius, ...).
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
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
      selectedColor: scheme.primary.withValues(alpha: 0.12),
      side: BorderSide(color: scheme.outline),
      showCheckmark: false,
    );
  }
}
