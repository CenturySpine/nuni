import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/phosphor_icons.dart';

/// A loud, permanent warning across the top of a screen: solid danger
/// color, light text, no action, never dismissed. Stronger than
/// `NuniErrorBanner` on purpose -- it states a lasting situation (a
/// super_admin acting outside their own sessions, plan 38), not a passing
/// failure.
class NuniAlertBanner extends StatelessWidget {
  const NuniAlertBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: scheme.error,
          borderRadius: BorderRadius.circular(NuniRadius.control),
        ),
        child: Row(
          children: [
            Icon(PhosphorIcons.warningCircle, color: scheme.onError),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onError,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
