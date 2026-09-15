import 'package:flutter/material.dart';

/// A named colour set. Only five roles exist (see docs/design/PALETTE.md):
/// background, text, accent, plus the semantic danger and success colours.
/// The card colour is derived from the background.
///
/// This is the only file allowed to contain raw `Color(0x...)` values.
class Palette {
  const Palette({
    required this.name,
    required this.background,
    required this.text,
    required this.accent,
    required this.card,
    this.danger = const Color(0xFFE24B4A),
    this.success = const Color(0xFF1D9E75),
  });

  final String name;
  final Color background;
  final Color text;
  final Color accent;
  final Color card;
  final Color danger;
  final Color success;
}

/// 03-B "Urban claire" (Q1b, 2026-09-14).
const Palette urbanLight = Palette(
  name: '03-B Urban claire',
  background: Color(0xFFE9E6E7),
  text: Color(0xFF5E5653),
  accent: Color(0xFF6B7C98),
  card: Color(0xFFFFFFFF),
);

/// The palette the app uses. Never exposed as a user setting.
/// The four other viable variants (01-A, 01-B, 02-A, 02-B) are added in plan 04.
const Palette activePalette = urbanLight;
