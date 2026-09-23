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

/// The NUNI "Pop" colour set (rebrand, 2026-09-23, docs/design/PALETTE.md):
/// a light neutral base, a deep ink for text, one violet brand colour and
/// three joyful accents (fairway green, tangerine, sunshine yellow) used
/// sparingly for meaning (live, draft, leader, championship...). This is the
/// only file allowed to contain raw `Color(0x...)` values.
@immutable
class Palette {
  const Palette({
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
    required this.tangerine,
    required this.sunshine,
    required this.dangerTone,
    required this.heroStart,
    required this.heroEnd,
  });

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

  /// Brand violet: primary buttons, selection, links, focus.
  final Color primary;
  final Color onPrimary;
  final AccentTone primaryTone;

  /// Green: golf, success, "live".
  final AccentTone fairway;

  /// Orange: warm highlights, "in preparation", the latest played hole.
  final AccentTone tangerine;

  /// Yellow: leader, crown, championship gold.
  final AccentTone sunshine;

  /// Red: errors and destructive actions.
  final AccentTone dangerTone;

  /// Brand gradient (login hero, home banner).
  final Color heroStart;
  final Color heroEnd;

  Color get danger => dangerTone.base;
  Color get success => fairway.onContainer;

  /// Selection / focus fill.
  Color get selectionBackground => primaryTone.container;
}

/// The active palette. Never exposed as a user setting.
const Palette nuniPop = Palette(
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
  tangerine: AccentTone(
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
);

/// Every palette defined in code (checked for contrast by unit test).
const List<Palette> allPalettes = [nuniPop];

/// The palette the app uses.
const Palette activePalette = nuniPop;
