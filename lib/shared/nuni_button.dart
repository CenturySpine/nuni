import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

enum NuniButtonVariant {
  primary,
  secondary,
  danger,

  /// White button on the brand gradient ([NuniHero]).
  onHero,

  /// Translucent button on the brand gradient, next to an [onHero] one.
  onHeroSecondary,
}

/// The app's only button shape. `primary` is a filled violet button (one
/// main action per screen), `secondary` a white outlined button, `danger` a
/// soft red button for destructive actions (the confirmation dialog that
/// follows carries the solid red one) -- no other button styles exist.
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
    final danger = context.nuni.danger;
    final scheme = Theme.of(context).colorScheme;
    // One text run with the icon inline, not a Row: it keeps its natural
    // width when unconstrained and ends with an ellipsis instead of
    // overflowing when the button is narrower than its label (half-width
    // buttons on a phone, PO 2026-09-23). A Flexible inside a Row would
    // throw wherever a button gets no width bound (e.g. a plain Row child).
    final child = Text.rich(
      TextSpan(
        children: [
          if (icon != null)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(icon, size: 18),
              ),
            ),
          TextSpan(text: label),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
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
          backgroundColor: danger.container,
          foregroundColor: danger.onContainer,
        ),
        onPressed: onPressed,
        child: child,
      ),
      NuniButtonVariant.onHero => FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.onPrimary,
          foregroundColor: scheme.primary,
        ),
        onPressed: onPressed,
        child: child,
      ),
      NuniButtonVariant.onHeroSecondary => FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.onPrimary.withValues(alpha: 0.18),
          foregroundColor: scheme.onPrimary,
        ),
        onPressed: onPressed,
        child: child,
      ),
    };
  }
}
