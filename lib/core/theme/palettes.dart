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
    this._primaryInk,
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

  /// The brand colour drawn as text, icon or thin line on a light surface
  /// (links, selected tab, focus ring, outlines). Same as [primary] unless
  /// the brand colour is too light for that -- then a deeper shade.
  Color get primaryInk => _primaryInk ?? primary;
  final Color? _primaryInk;

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

  /// The "NI" row of the logo, drawn on the brand gradient ("NU" is drawn in
  /// [onPrimary]).
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

/// Amber brand (PO, 2026-09-23: #FFB703, replacing the first orange #E66400).
/// Too light for white labels (1.75:1), so -- unlike the other palettes --
/// labels on it are dark ink (10:1), and text/lines use the deeper
/// [Palette.primaryInk]. Sunshine yellow would be indistinguishable from
/// amber, so the leader/championship accent is orange here. Sky blue
/// highlight, amber's complement.
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
  primary: Color(0xFFFFB703),
  onPrimary: Color(0xFF14172B),
  primaryInk: Color(0xFF8A5F00),
  primaryTone: AccentTone(
    base: Color(0xFFFFB703),
    container: Color(0xFFFFF6E0),
    onContainer: Color(0xFF8A5F00),
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
    base: Color(0xFFE66400),
    container: Color(0xFFFFF0E0),
    onContainer: Color(0xFFB34A00),
  ),
  dangerTone: AccentTone(
    base: Color(0xFFCF2E3A),
    container: Color(0xFFFDECEC),
    onContainer: Color(0xFFB42328),
  ),
  heroStart: Color(0xFFFFB703),
  heroEnd: Color(0xFFFB8500),
  logoNi: Color(0xFFFFFFFF),
);

/// Coral brand (PO, 2026-09-23, from #E76F51, darkened a notch so white
/// labels reach 3:1); sky blue highlight, its complement.
const Palette nuniCoral = Palette(
  id: 'coral',
  name: 'NUNI Coral',
  background: Color(0xFFF4F5FA),
  surface: Color(0xFFFFFFFF),
  surfaceMuted: Color(0xFFF0F1F7),
  border: Color(0xFFE3E5EF),
  text: Color(0xFF14172B),
  textSecondary: Color(0xFF5C6275),
  textDisabled: Color(0xFFA2A6B6),
  primary: Color(0xFFE56545),
  onPrimary: Color(0xFFFFFFFF),
  primaryTone: AccentTone(
    base: Color(0xFFE56545),
    container: Color(0xFFFCE9E4),
    onContainer: Color(0xFFBA3A1A),
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
  heroStart: Color(0xFFE76F51),
  heroEnd: Color(0xFFE6564C),
  logoNi: Color(0xFFFFEFB0),
);

/// Blue brand (PO, 2026-09-23, from #219EBC, darkened a notch so white
/// labels reach 3:1); tangerine highlight, its complement.
const Palette nuniOcean = Palette(
  id: 'ocean',
  name: 'NUNI Ocean',
  background: Color(0xFFF4F5FA),
  surface: Color(0xFFFFFFFF),
  surfaceMuted: Color(0xFFF0F1F7),
  border: Color(0xFFE3E5EF),
  text: Color(0xFF14172B),
  textSecondary: Color(0xFF5C6275),
  textDisabled: Color(0xFFA2A6B6),
  primary: Color(0xFF2099B6),
  onPrimary: Color(0xFFFFFFFF),
  primaryTone: AccentTone(
    base: Color(0xFF2099B6),
    container: Color(0xFFE5F7FB),
    onContainer: Color(0xFF18758B),
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
  heroStart: Color(0xFF219EBC),
  heroEnd: Color(0xFF2080B6),
  logoNi: Color(0xFFFFEFB0),
);

/// Teal brand (PO, 2026-09-23, #2A9D8F as given); tangerine highlight, its
/// complement.
const Palette nuniLagoon = Palette(
  id: 'lagoon',
  name: 'NUNI Lagoon',
  background: Color(0xFFF4F5FA),
  surface: Color(0xFFFFFFFF),
  surfaceMuted: Color(0xFFF0F1F7),
  border: Color(0xFFE3E5EF),
  text: Color(0xFF14172B),
  textSecondary: Color(0xFF5C6275),
  textDisabled: Color(0xFFA2A6B6),
  primary: Color(0xFF2A9D8F),
  onPrimary: Color(0xFFFFFFFF),
  primaryTone: AccentTone(
    base: Color(0xFF2A9D8F),
    container: Color(0xFFE6F9F7),
    onContainer: Color(0xFF20786D),
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
  heroStart: Color(0xFF2CA3A1),
  heroEnd: Color(0xFF28977B),
  logoNi: Color(0xFFFFEFB0),
);

/// Olive brand (PO, 2026-09-23, from #ADC178: same hue and saturation,
/// darkened until white labels reach 3:1 -- the given tint is ~2:1); violet
/// highlight, its complement.
const Palette nuniOlive = Palette(
  id: 'olive',
  name: 'NUNI Olive',
  background: Color(0xFFF4F5FA),
  surface: Color(0xFFFFFFFF),
  surfaceMuted: Color(0xFFF0F1F7),
  border: Color(0xFFE3E5EF),
  text: Color(0xFF14172B),
  textSecondary: Color(0xFF5C6275),
  textDisabled: Color(0xFFA2A6B6),
  primary: Color(0xFF7F9545),
  onPrimary: Color(0xFFFFFFFF),
  primaryTone: AccentTone(
    base: Color(0xFF7F9545),
    container: Color(0xFFF3F6E9),
    onContainer: Color(0xFF617234),
  ),
  fairway: AccentTone(
    base: Color(0xFF12B76A),
    container: Color(0xFFE2F6EA),
    onContainer: Color(0xFF0A7A47),
  ),
  highlight: AccentTone(
    base: Color(0xFF8E7BFF),
    container: Color(0xFFECEAFE),
    onContainer: Color(0xFF3A2DB8),
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
  heroStart: Color(0xFF7E9E49),
  heroEnd: Color(0xFF828C40),
  logoNi: Color(0xFFFFEFB0),
);

/// Every palette the user can pick in the settings (checked for contrast by
/// unit test), in display order: shown two per row, warm (orange, coral),
/// cool (violet, blue), then soft (teal, olive).
const List<Palette> allPalettes = [
  nuniSunset,
  nuniCoral,
  nuniPop,
  nuniOcean,
  nuniLagoon,
  nuniOlive,
];

/// The palette used until the user picks one; also the PWA icons' colours.
const Palette defaultPalette = nuniSunset;

/// The palette saved under [id], or `null` for an unknown or missing id.
Palette? paletteById(String? id) {
  for (final palette in allPalettes) {
    if (palette.id == id) return palette;
  }
  return null;
}
