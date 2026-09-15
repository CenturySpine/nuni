import 'package:flutter/material.dart';

import 'palettes.dart';

/// The one custom colour Material 3's [ColorScheme] has no role for.
/// Access via `Theme.of(context).extension<NuniColors>()!.success`.
class NuniColors extends ThemeExtension<NuniColors> {
  const NuniColors({required this.success});

  final Color success;

  @override
  NuniColors copyWith({Color? success}) =>
      NuniColors(success: success ?? this.success);

  @override
  NuniColors lerp(ThemeExtension<NuniColors>? other, double t) {
    if (other is! NuniColors) return this;
    return NuniColors(success: Color.lerp(success, other.success, t)!);
  }
}

/// Builds the app theme from [palette]. Deliberately not `ColorScheme.fromSeed`
/// (which fabricates dozens of tonal shades): every role below is one of the
/// palette's five named colours, or one of its opacity/blend derivatives
/// (docs/design/PALETTE.md) -- never a new hue.
ThemeData buildAppTheme([Palette palette = activePalette]) {
  final base = palette.isDark ? ColorScheme.dark() : ColorScheme.light();
  final colorScheme = base.copyWith(
    brightness: palette.isDark ? Brightness.dark : Brightness.light,
    primary: palette.accent,
    onPrimary: palette.background,
    secondary: palette.accent,
    onSecondary: palette.background,
    tertiary: palette.success,
    onTertiary: palette.background,
    error: palette.danger,
    onError: palette.background,
    surface: palette.background,
    onSurface: palette.text,
    onSurfaceVariant: palette.textSecondary,
    // One cartouche tone for the whole app (no elevation ladder): every
    // "container" role Material 3 widgets fall back to (dialogs, segmented
    // buttons, selected chips/nav items, ...) collapses to palette.card,
    // otherwise those widgets silently pull in Flutter's default blue-ish
    // Material baseline for any role left unset here.
    surfaceContainerLowest: palette.card,
    surfaceContainerLow: palette.card,
    surfaceContainer: palette.card,
    surfaceContainerHigh: palette.card,
    surfaceContainerHighest: palette.card,
    primaryContainer: palette.card,
    onPrimaryContainer: palette.text,
    secondaryContainer: palette.selectionBackground,
    onSecondaryContainer: palette.text,
    tertiaryContainer: palette.card,
    onTertiaryContainer: palette.text,
    errorContainer: palette.card,
    onErrorContainer: palette.danger,
    outline: palette.border,
    outlineVariant: palette.border,
    inverseSurface: palette.text,
    onInverseSurface: palette.background,
  );

  final textTheme = TextTheme(
    headlineMedium: TextStyle(
      fontSize: 28,
      height: 1.2,
      fontWeight: FontWeight.w700,
      color: palette.text,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: palette.text,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: palette.text,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      height: 1.3,
      fontWeight: FontWeight.w500,
      color: palette.textSecondary,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: palette.background,
    textTheme: textTheme,
    cardTheme: CardThemeData(
      color: palette.card,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: DividerThemeData(color: palette.border, thickness: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: palette.background,
      foregroundColor: palette.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.card,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: palette.card,
      indicatorColor: palette.selectionBackground,
      surfaceTintColor: Colors.transparent,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: palette.card,
      side: BorderSide(color: palette.border),
    ),
    extensions: [NuniColors(success: palette.success)],
  );
}
