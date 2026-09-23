import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';

/// A square hole photo, or a framed placeholder when the hole has none (or
/// the image fails to load) -- PO, 2026-09-23. Shared by the hole list
/// (small thumbnails) and the hole detail sheet (large ones).
class HolePhotoThumb extends StatelessWidget {
  const HolePhotoThumb({super.key, this.url, this.size, this.iconSize = 24});

  final String? url;

  /// Fixed side length; null fills the available width (square).
  final double? size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(
      size != null && size! < 64 ? NuniRadius.small : NuniRadius.control,
    );
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: radius,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Center(
        child: Icon(
          PhosphorIcons.imageSquare,
          size: iconSize,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
    final content = url == null
        ? placeholder
        : ClipRRect(
            borderRadius: radius,
            child: Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => placeholder,
            ),
          );
    return size == null
        ? AspectRatio(aspectRatio: 1, child: content)
        : SizedBox.square(dimension: size, child: content);
  }
}
