import 'package:flutter/material.dart';

import '../core/theme/phosphor_icons.dart';
import 'nuni_icon_tile.dart';

/// Placeholder for an empty list ("no live sessions", "no holes nearby", ...).
class NuniEmptyState extends StatelessWidget {
  const NuniEmptyState({
    super.key,
    required this.message,
    this.icon = PhosphorIcons.tray,
    this.action,
  });

  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Scrolls rather than overflowing when shown in a short area (a list
    // region of a bottom sheet).
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NuniIconTile(icon: icon, size: 64),
            const SizedBox(height: 14),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
