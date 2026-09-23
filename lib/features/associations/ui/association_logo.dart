import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/nuni_avatar.dart';
import '../data/associations_repository.dart';
import '../domain/association.dart';

/// An association's logo on a rounded square tile, or -- while it has none
/// (plan 18: empty until a local manager uploads one) -- its abbreviation
/// ("LSG") or, without one, its initials, on a tint.
class AssociationLogo extends ConsumerWidget {
  const AssociationLogo({super.key, required this.association, this.size = 44});

  final Association association;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tone = context.nuni.primaryTone;
    final short = association.shortName?.trim() ?? '';
    final text = short.isNotEmpty && short.length <= 4
        ? short.toUpperCase()
        : NuniAvatar.initials(association.name);
    final fallback = Center(
      child: Text(
        text,
        style: TextStyle(
          fontFamily: nuniFontFamily,
          fontSize: size * (text.length > 2 ? 0.27 : 0.34),
          fontWeight: FontWeight.w800,
          color: tone.onContainer,
          height: 1,
        ),
      ),
    );
    final path = association.logoPath;

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tone.container,
        borderRadius: BorderRadius.circular(size * 0.26),
      ),
      child: path == null
          ? fallback
          : Image.network(
              ref.watch(associationsRepositoryProvider).logoUrl(path),
              width: size,
              height: size,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : fallback,
              errorBuilder: (context, error, stackTrace) => fallback,
            ),
    );
  }
}
