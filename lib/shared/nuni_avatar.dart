import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/phosphor_icons.dart';
import 'display_sized_image.dart';

/// A player's round avatar: their photo when there is one, otherwise their
/// initials on a tint picked from the name (stable: the same player always
/// gets the same colour), or a generic person icon when the name is unknown.
class NuniAvatar extends StatelessWidget {
  const NuniAvatar({super.key, this.name, this.imageUrl, this.size = 40});

  final String? name;
  final String? imageUrl;
  final double size;

  static const _tones = [
    NuniTone.primary,
    NuniTone.fairway,
    NuniTone.highlight,
    NuniTone.sunshine,
  ];

  static String initials(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words.first.characters.take(2).toString().toUpperCase();
    }
    return (words.first.characters.first + words.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = name?.trim() ?? '';
    final tone = context.nuni.tone(
      trimmed.isEmpty
          ? NuniTone.neutral
          : _tones[trimmed.codeUnits.fold(0, (a, b) => a + b) % _tones.length],
    );
    final label = initials(trimmed);
    final fallback = Center(
      child: label.isEmpty
          ? Icon(
              PhosphorIcons.userCircle,
              size: size * 0.55,
              color: tone.onContainer,
            )
          : Text(
              label,
              style: TextStyle(
                fontFamily: nuniFontFamily,
                fontSize: size * 0.38,
                fontWeight: FontWeight.w800,
                color: tone.onContainer,
                height: 1,
              ),
            ),
    );

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: tone.container, shape: BoxShape.circle),
      // Initials stay underneath while the photo loads, and whenever it
      // can't be loaded (e.g. a Google photo blocked by the browser).
      child: imageUrl == null
          ? fallback
          : Image(
              image: displaySizedImage(
                context,
                NetworkImage(imageUrl!),
                width: size,
                height: size,
              ),
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
