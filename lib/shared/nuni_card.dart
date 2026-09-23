import 'package:flutter/material.dart';

/// A cartouche: the app's only raised surface (white, hairline border,
/// large radius, from the theme's `cardTheme`). [color] tints it for the
/// rare card that must stand out (the latest played hole, a leader...).
class NuniCard extends StatelessWidget {
  const NuniCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    final themeShape = Theme.of(context).cardTheme.shape;
    return Card(
      color: color,
      shape: borderColor != null && themeShape is RoundedRectangleBorder
          ? themeShape.copyWith(
              side: BorderSide(color: borderColor!, width: 1.5),
            )
          : null,
      // Otherwise the hover/press ink overlay ignores the card's rounded
      // corners and shows up as a plain rectangle.
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
