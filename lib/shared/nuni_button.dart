import 'package:flutter/material.dart';

enum NuniButtonVariant { primary, secondary, danger }

/// The app's only button shape. `primary` is a filled button (accent
/// surface), `secondary` an outlined button, `danger` a filled button on the
/// error colour -- no other button styles exist.
class NuniButton extends StatelessWidget {
  const NuniButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = NuniButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final NuniButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          );

    return switch (variant) {
      NuniButtonVariant.primary => FilledButton(
        onPressed: onPressed,
        child: child,
      ),
      NuniButtonVariant.secondary => OutlinedButton(
        onPressed: onPressed,
        child: child,
      ),
      NuniButtonVariant.danger => FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.error,
          foregroundColor: scheme.onError,
        ),
        onPressed: onPressed,
        child: child,
      ),
    };
  }
}
