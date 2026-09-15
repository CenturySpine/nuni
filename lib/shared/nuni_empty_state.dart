import 'package:flutter/material.dart';

import '../core/theme/phosphor_icons.dart';

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
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              message,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
