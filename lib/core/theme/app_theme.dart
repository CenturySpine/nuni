import 'package:flutter/material.dart';

import 'palettes.dart';

/// Provisional theme built from [activePalette]. Plan 04 defines the real
/// design system; this only guarantees the placeholder page uses the palette.
ThemeData buildAppTheme([Palette palette = activePalette]) {
  final colorScheme = ColorScheme.light(
    primary: palette.accent,
    onPrimary: palette.background,
    surface: palette.background,
    onSurface: palette.text,
    error: palette.danger,
  );
  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: palette.background,
    cardColor: palette.card,
    useMaterial3: true,
  );
}
