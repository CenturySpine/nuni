import 'package:flutter/material.dart';

/// One accent hue with the two derived tones every accent needs: a pale
/// [container] fill (tinted badges, selected rows, icon tiles) and a deep
/// [onContainer] for text and icons drawn on that fill.
@immutable
class AccentTone {
  const AccentTone({
    required this.base,
    required this.container,
    required this.onContainer,
  });

  final Color base;
  final Color container;
  final Color onContainer;
}

/// A NUNI colour set (rebrand, 2026-09-23, docs/design/PALETTE.md): a light
/// neutral base, a deep ink for text, one brand colour and three joyful
/// accents (fairway green, a highlight hue, sunshine yellow) used sparingly
/// for meaning (live, draft, leader, championship...). This is the only file
/// allowed to contain raw `Color(0x...)` values.
@immutable
class Palette {
  const Palette({
    required this.id,
    required this.name,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.text,
    required this.textSecondary,
    required this.textDisabled,
    required this.primary,
    required this.onPrimary,
    required this.primaryTone,
    required this.fairway,
    required this.highlight,
    required this.sunshine,
    required this.dangerTone,
    required this.heroStart,
    required this.heroEnd,
    required this.logoNi,
  });

  /// Stable key saved on the device when the user picks this palette.
  final String id;
  final String name;

  /// Page background.
  final Color background;

  /// Cards, sheets, dialogs, navigation bar.
  final Color surface;

  /// Input fills and quiet tiles sitting on a [surface].
  final Color surfaceMuted;

  /// Hairlines: card outlines, dividers, unfocused field borders.
  final Color border;

  final Color text;
  final Color textSecondary;
  final Color textDisabled;

  /// Brand colour: primary buttons, selection, links, focus.
  final Color primary;
  final Color onPrimary;
  final AccentTone primaryTone;

  /// Green: golf, success, "live".
  final AccentTone fairway;

  /// Second hue, contrasting with the brand colour: "in preparation",
  /// notification badges, some avatar and icon tints.
  final AccentTone highlight;

  /// Yellow: leader, crown, championship gold.
  final AccentTone sunshine;

  /// Red: errors and destructive actions.
  final AccentTone dangerTone;

  /// Brand gradient (login hero, home banner).
  final Color heroStart;
  final Color heroEnd;

  /// The "NI" row of the logo, drawn on the brand gradient ("NU" is white).
  final Color logoNi;

  Color get danger => dangerTone.base;
  Color get success => fairway.onContainer;

  /// Selection / focus fill.
  Color get selectionBackground => primaryTone.container;
}

/// The first rebrand palette: violet brand, tangerine highlight.
const Palette nuniPop = Palette(
  id: 'pop',
  name: 'NUNI Pop',
  background: Color(0xFFF4F5FA),
  surface: Color(0xFFFFFFFF),
  surfaceMuted: Color(0xFFF0F1F7),
  border: Color(0xFFE3E5EF),
  text: Color(0xFF14172B),
  textSecondary: Color(0xFF5C6275),
  textDisabled: Color(0xFFA2A6B6),
  primary: Color(0xFF5B4CF5),
  onPrimary: Color(0xFFFFFFFF),
  primaryTone: AccentTone(
    base: Color(0xFF5B4CF5),
    container: Color(0xFFECEAFE),
    onContainer: Color(0xFF3A2DB8),
  ),
  fairway: AccentTone(
    base: Color(0xFF12B76A),
    container: Color(0xFFE2F6EA),
    onContainer: Color(0xFF0A7A47),
  ),
  highlight: AccentTone(
    base: Color(0xFFFF7A45),
    container: Color(0xFFFFEDE3),
    onContainer: Color(0xFFB2441A),
  ),
  sunshine: AccentTone(
    base: Color(0xFFFFC43D),
    container: Color(0xFFFFF4D4),
    onContainer: Color(0xFF855D00),
  ),
  dangerTone: AccentTone(
    base: Color(0xFFCF2E3A),
    container: Color(0xFFFDECEC),
    onContainer: Color(0xFFB42328),
  ),
  heroStart: Color(0xFF5B4CF5),
  heroEnd: Color(0xFF7B4FF0),
  logoNi: Color(0xFFFFC43D),
);

/// Same design with a true orange brand colour (PO, 2026-09-23: "un vrai
/// orange", not red-leaning). A real orange caps white labels at ~3.4:1, so
/// the brand fills are held to WCAG AA for bold/large text (3:1) instead of
/// 4.5:1; small text on tints still uses the deep [primaryTone.onContainer].
/// The highlight hue becomes a sky blue (orange's complement) so orange is
/// not used twice.
const Palette nuniSunset = Palette(
  id: 'sunset',
  name: 'NUNI Sunset',
  background: Color(0xFFF4F5FA),
  surface: Color(0xFFFFFFFF),
  surfaceMuted: Color(0xFFF0F1F7),
  border: Color(0xFFE3E5EF),
  text: Color(0xFF14172B),
  textSecondary: Color(0xFF5C6275),
  textDisabled: Color(0xFFA2A6B6),
  primary: Color(0xFFE66400),
  onPrimary: Color(0xFFFFFFFF),
  primaryTone: AccentTone(
    base: Color(0xFFE66400),
    container: Color(0xFFFFF0E0),
    onContainer: Color(0xFFB34A00),
  ),
  fairway: AccentTone(
    base: Color(0xFF12B76A),
    container: Color(0xFFE2F6EA),
    onContainer: Color(0xFF0A7A47),
  ),
  highlight: AccentTone(
    base: Color(0xFF2E90FA),
    container: Color(0xFFE3F0FF),
    onContainer: Color(0xFF1B5FB8),
  ),
  sunshine: AccentTone(
    base: Color(0xFFFFC43D),
    container: Color(0xFFFFF4D4),
    onContainer: Color(0xFF855D00),
  ),
  dangerTone: AccentTone(
    base: Color(0xFFCF2E3A),
    container: Color(0xFFFDECEC),
    onContainer: Color(0xFFB42328),
  ),
  heroStart: Color(0xFFEC7000),
  heroEnd: Color(0xFFE25A00),
  logoNi: Color(0xFFFFEFB0),
);

/// Every palette the user can pick in the settings, in display order
/// (checked for contrast by unit test).
const List<Palette> allPalettes = [nuniSunset, nuniPop];

/// The palette used until the user picks one; also the PWA icons' colours.
const Palette defaultPalette = nuniSunset;

/// The palette saved under [id], or `null` for an unknown or missing id.
Palette? paletteById(String? id) {
  for (final palette in allPalettes) {
    if (palette.id == id) return palette;
  }
  return null;
}
