import 'package:flutter/material.dart';

/// A cartouche: the app's only elevated surface, coloured by the active
/// palette's `card` (`Theme.of(context).colorScheme.surfaceContainerHighest`).
class NuniCard extends StatelessWidget {
  const NuniCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return Card(
      // Otherwise the hover/press ink overlay ignores the card's rounded
      // corners and shows up as a plain rectangle.
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
