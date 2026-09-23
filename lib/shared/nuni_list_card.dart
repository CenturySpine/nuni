import 'package:flutter/material.dart';

import '../core/theme/phosphor_icons.dart';
import 'nuni_card.dart';

/// The app's standard tappable row card (a session, a hole, a past
/// championship...): leading visual, title, optional subtitle and badge,
/// trailing widget (a chevron by default when tappable).
class NuniListCard extends StatelessWidget {
  const NuniListCard({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.badge,
    this.trailing,
    this.onTap,
    this.color,
    this.borderColor,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;

  /// Shown under the title, before the subtitle (a status pill).
  final Widget? badge;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final trailingWidget =
        trailing ??
        (onTap == null
            ? null
            : Icon(
                PhosphorIcons.caretRight,
                size: 18,
                color: scheme.onSurfaceVariant,
              ));

    return NuniCard(
      onTap: onTap,
      color: color,
      borderColor: borderColor,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 14)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (badge != null) ...[const SizedBox(height: 6), badge!],
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (trailingWidget != null) ...[
            const SizedBox(width: 8),
            trailingWidget,
          ],
        ],
      ),
    );
  }
}
