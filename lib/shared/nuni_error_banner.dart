import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/phosphor_icons.dart';

/// Inline error banner (failed load, offline write refused, ...), with an
/// optional retry action.
class NuniErrorBanner extends StatelessWidget {
  const NuniErrorBanner({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(NuniRadius.control),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.warningCircle, color: scheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: Icon(
                PhosphorIcons.arrowClockwise,
                color: scheme.onErrorContainer,
              ),
            ),
        ],
      ),
    );
  }
}
