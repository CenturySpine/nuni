import 'package:flutter/material.dart';

/// A named colour set. Only three colours are chosen by hand (background,
/// text, accent); everything else is derived by opacity or blend, never by a
/// new hue (docs/design/PALETTE.md). This is the only file allowed to
/// contain raw `Color(0x...)` values.
class Palette {
  const Palette({
    required this.name,
    required this.background,
    required this.text,
    required this.accent,
    required this.isDark,
    this.danger = const Color(0xFFE24B4A),
    this.success = const Color(0xFF1D9E75),
  });

  final String name;
  final Color background;
  final Color text;
  final Color accent;

  /// True for the "sombre" repartition (background is the darkest colour of
  /// the trio), false for "claire" (background is the lightest, lightened
  /// toward white).
  final bool isDark;
  final Color danger;
  final Color success;

  /// Cartouche surface: background blended with 6% text on a dark
  /// repartition, plain white on a light one.
  Color get card => isDark ? Color.lerp(background, text, 0.06)! : Colors.white;

  /// Borders, dividers.
  Color get border => text.withValues(alpha: 0.15);

  /// Secondary body text.
  Color get textSecondary => text.withValues(alpha: 0.60);

  /// Disabled text and icons.
  Color get textDisabled => text.withValues(alpha: 0.40);

  /// Selection / focus fill; the outline uses [accent] at full opacity.
  Color get selectionBackground => accent.withValues(alpha: 0.12);
}

/// 01-A "sombre" (docs/design/PALETTE.md, essai 01).
const Palette sunsetDark = Palette(
  name: '01-A sombre',
  background: Color(0xFF272838),
  text: Color(0xFFF3DE8A),
  accent: Color(0xFFEB9486),
  isDark: true,
);

/// 01-B "claire" (docs/design/PALETTE.md, essai 01).
const Palette sunsetLight = Palette(
  name: '01-B claire',
  background: Color(0xFFFCF7E3),
  text: Color(0xFF272838),
  accent: Color(0xFFEB9486),
  isDark: false,
);

/// 02-A "sombre" (docs/design/PALETTE.md, essai 02).
const Palette oceanDark = Palette(
  name: '02-A sombre',
  background: Color(0xFF091540),
  text: Color(0xFFABD2FA),
  accent: Color(0xFF7692FF),
  isDark: true,
);

/// 02-B "claire" (docs/design/PALETTE.md, essai 02).
const Palette oceanLight = Palette(
  name: '02-B claire',
  background: Color(0xFFE6F1FD),
  text: Color(0xFF091540),
  accent: Color(0xFF7692FF),
  isDark: false,
);

/// 03-B "Urban claire" (Q1b, 2026-09-14). The active palette.
const Palette urbanLight = Palette(
  name: '03-B Urban claire',
  background: Color(0xFFE9E6E7),
  text: Color(0xFF5E5653),
  accent: Color(0xFF6B7C98),
  isDark: false,
);

/// The five variants documented as viable in docs/design/PALETTE.md
/// (03-A "sombre" was excluded there: accent/background contrast 1.7:1).
const List<Palette> allPalettes = [
  sunsetDark,
  sunsetLight,
  oceanDark,
  oceanLight,
  urbanLight,
];

/// The palette the app uses. Never exposed as a user setting: switching
/// palette is switching this constant and rebuilding.
const Palette activePalette = urbanLight;
