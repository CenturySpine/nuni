import 'package:flutter/material.dart';

import 'palettes.dart';

/// The font bundled in `assets/fonts` (Plus Jakarta Sans, OFL).
const String nuniFontFamily = 'PlusJakartaSans';

/// Corner radii: one value per kind of element, used everywhere.
abstract final class NuniRadius {
  /// Chips-inside-cards, small tiles, thumbnails.
  static const double small = 10;

  /// Buttons, fields, segmented controls.
  static const double control = 14;

  /// Cards (cartouches).
  static const double card = 20;

  /// Dialogs and bottom sheets.
  static const double sheet = 28;
}

/// The palette colours Material 3's [ColorScheme] has no role for (accent
/// tones, brand gradient, muted surface). Access via `context.nuni`.
class NuniColors extends ThemeExtension<NuniColors> {
  const NuniColors(this.palette);

  final Palette palette;

  Color get success => palette.success;
  AccentTone get primaryTone => palette.primaryTone;
  Color get primaryInk => palette.primaryInk;
  AccentTone get fairway => palette.fairway;
  AccentTone get highlight => palette.highlight;
  AccentTone get sunshine => palette.sunshine;
  AccentTone get danger => palette.dangerTone;
  Color get surfaceMuted => palette.surfaceMuted;
  Color get border => palette.border;
  LinearGradient get heroGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [palette.heroStart, palette.heroEnd],
  );

  @override
  NuniColors copyWith({Palette? palette}) =>
      NuniColors(palette ?? this.palette);

  @override
  NuniColors lerp(ThemeExtension<NuniColors>? other, double t) {
    if (other is! NuniColors) return this;
    return t < 0.5 ? this : other;
  }
}

extension NuniThemeContext on BuildContext {
  // Falls back to the default palette when no app theme is installed (bare
  // widget tests).
  NuniColors get nuni =>
      Theme.of(this).extension<NuniColors>() ??
      const NuniColors(defaultPalette);
}

/// Builds the app theme from [palette]: every Material component the app
/// uses is styled here, so screens only pick widgets, never colours or
/// shapes (docs/design/PALETTE.md, "Composants").
ThemeData buildAppTheme([Palette palette = defaultPalette]) {
  final colorScheme = ColorScheme.light(
    primary: palette.primary,
    onPrimary: palette.onPrimary,
    primaryContainer: palette.primaryTone.container,
    onPrimaryContainer: palette.primaryTone.onContainer,
    secondary: palette.highlight.base,
    onSecondary: palette.text,
    secondaryContainer: palette.primaryTone.container,
    onSecondaryContainer: palette.primaryTone.onContainer,
    tertiary: palette.fairway.base,
    onTertiary: palette.onPrimary,
    tertiaryContainer: palette.fairway.container,
    onTertiaryContainer: palette.fairway.onContainer,
    error: palette.danger,
    onError: palette.onPrimary,
    errorContainer: palette.dangerTone.container,
    onErrorContainer: palette.dangerTone.onContainer,
    surface: palette.background,
    onSurface: palette.text,
    onSurfaceVariant: palette.textSecondary,
    surfaceContainerLowest: palette.surface,
    surfaceContainerLow: palette.surface,
    surfaceContainer: palette.surface,
    surfaceContainerHigh: palette.surface,
    surfaceContainerHighest: palette.surfaceMuted,
    surfaceTint: Colors.transparent,
    outline: palette.border,
    outlineVariant: palette.border,
    inverseSurface: palette.text,
    onInverseSurface: palette.surface,
    inversePrimary: palette.primaryTone.container,
    shadow: palette.text,
    scrim: palette.text,
  );

  TextStyle style(
    double size,
    FontWeight weight, {
    double height = 1.35,
    double spacing = 0,
    Color? color,
  }) => TextStyle(
    fontFamily: nuniFontFamily,
    fontSize: size,
    height: height,
    fontWeight: weight,
    letterSpacing: spacing,
    color: color ?? palette.text,
  );

  final textTheme = TextTheme(
    displaySmall: style(36, FontWeight.w800, height: 1.1, spacing: -0.8),
    headlineLarge: style(32, FontWeight.w800, height: 1.15, spacing: -0.6),
    headlineMedium: style(28, FontWeight.w800, height: 1.15, spacing: -0.5),
    headlineSmall: style(24, FontWeight.w700, height: 1.2, spacing: -0.3),
    titleLarge: style(20, FontWeight.w700, height: 1.25, spacing: -0.2),
    titleMedium: style(17, FontWeight.w700, height: 1.3, spacing: -0.1),
    titleSmall: style(15, FontWeight.w600, height: 1.3),
    bodyLarge: style(17, FontWeight.w400, height: 1.45),
    bodyMedium: style(15, FontWeight.w400, height: 1.45),
    bodySmall: style(13, FontWeight.w500, color: palette.textSecondary),
    labelLarge: style(15, FontWeight.w600, height: 1.2),
    labelMedium: style(13, FontWeight.w600, color: palette.textSecondary),
    labelSmall: style(11, FontWeight.w700, spacing: 0.6),
  );

  final controlShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(NuniRadius.control),
  );
  const buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 14);
  const buttonMinSize = Size(48, 52);
  final buttonText = style(16, FontWeight.w700, height: 1.2);

  OutlineInputBorder fieldBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(NuniRadius.control),
        borderSide: BorderSide(color: color, width: width),
      );

  WidgetStateProperty<Color?> whenSelected(Color selected, Color other) =>
      WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? selected : other,
      );

  return ThemeData(
    useMaterial3: true,
    fontFamily: nuniFontFamily,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: palette.background,
    canvasColor: palette.background,
    textTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    iconTheme: IconThemeData(color: palette.text, size: 22),
    dividerColor: palette.border,
    dividerTheme: DividerThemeData(
      color: palette.border,
      thickness: 1,
      space: 1,
    ),

    // --- Buttons -----------------------------------------------------------
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: controlShape,
        padding: buttonPadding,
        minimumSize: buttonMinSize,
        textStyle: buttonText,
        disabledBackgroundColor: palette.border,
        disabledForegroundColor: palette.textDisabled,
        elevation: 0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: controlShape,
        padding: buttonPadding,
        minimumSize: buttonMinSize,
        textStyle: buttonText,
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: controlShape,
        padding: buttonPadding,
        minimumSize: buttonMinSize,
        textStyle: buttonText,
        backgroundColor: palette.surface,
        foregroundColor: palette.text,
        disabledForegroundColor: palette.textDisabled,
        side: BorderSide(color: palette.border, width: 1.5),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: palette.primaryInk,
        textStyle: style(15, FontWeight.w700, height: 1.2),
        shape: controlShape,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: palette.text,
        disabledForegroundColor: palette.textDisabled,
        shape: const CircleBorder(),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: palette.primary,
      foregroundColor: palette.onPrimary,
      elevation: 3,
      focusElevation: 3,
      hoverElevation: 4,
      highlightElevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      extendedTextStyle: buttonText,
    ),

    // --- Surfaces ----------------------------------------------------------
    cardTheme: CardThemeData(
      color: palette.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NuniRadius.card),
        side: BorderSide(color: palette.border),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: palette.background,
      foregroundColor: palette.text,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      toolbarHeight: 60,
      titleTextStyle: style(20, FontWeight.w800, spacing: -0.3),
      iconTheme: IconThemeData(color: palette.text, size: 22),
      actionsIconTheme: IconThemeData(color: palette.text, size: 22),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NuniRadius.sheet),
      ),
      titleTextStyle: style(20, FontWeight.w800, spacing: -0.2),
      contentTextStyle: style(15, FontWeight.w400, height: 1.45),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.surface,
      modalBackgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: palette.border,
      dragHandleSize: const Size(40, 5),
      elevation: 0,
      modalElevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(NuniRadius.sheet),
        ),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: palette.text,
      contentTextStyle: style(15, FontWeight.w500, color: palette.surface),
      actionTextColor: palette.primaryTone.container,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NuniRadius.control),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: palette.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shadowColor: palette.text.withValues(alpha: 0.18),
      textStyle: style(15, FontWeight.w500),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NuniRadius.control),
        side: BorderSide(color: palette.border),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: palette.text,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: style(12, FontWeight.w600, color: palette.surface),
    ),

    // --- Navigation --------------------------------------------------------
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 68,
      indicatorColor: palette.primaryTone.container,
      indicatorShape: const StadiumBorder(),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 24,
          color: states.contains(WidgetState.selected)
              ? palette.primaryInk
              : palette.textSecondary,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? style(12, FontWeight.w700, color: palette.primaryInk)
            : style(12, FontWeight.w600, color: palette.textSecondary),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: palette.primaryTone.onContainer,
      unselectedLabelColor: palette.textSecondary,
      labelStyle: style(14, FontWeight.w700),
      unselectedLabelStyle: style(14, FontWeight.w600),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      indicator: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(NuniRadius.control - 4),
        boxShadow: [
          BoxShadow(
            color: palette.text.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: palette.textSecondary,
      textColor: palette.text,
      titleTextStyle: style(15, FontWeight.w600),
      subtitleTextStyle: style(
        13,
        FontWeight.w500,
        color: palette.textSecondary,
      ),
      leadingAndTrailingTextStyle: style(
        14,
        FontWeight.w600,
        color: palette.textSecondary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minVerticalPadding: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NuniRadius.control),
      ),
    ),

    // --- Inputs ------------------------------------------------------------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surfaceMuted,
      hoverColor: Colors.transparent,
      labelStyle: style(15, FontWeight.w500, color: palette.textSecondary),
      floatingLabelStyle: style(14, FontWeight.w700, color: palette.primaryInk),
      hintStyle: style(15, FontWeight.w400, color: palette.textDisabled),
      helperStyle: style(12, FontWeight.w500, color: palette.textSecondary),
      errorStyle: style(12, FontWeight.w600, color: palette.danger),
      prefixIconColor: palette.textSecondary,
      suffixIconColor: palette.textSecondary,
      border: fieldBorder(Colors.transparent),
      enabledBorder: fieldBorder(Colors.transparent),
      disabledBorder: fieldBorder(Colors.transparent),
      focusedBorder: fieldBorder(palette.primaryInk, 2),
      errorBorder: fieldBorder(palette.danger, 1.5),
      focusedErrorBorder: fieldBorder(palette.danger, 2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: palette.primaryInk,
      selectionColor: palette.primary.withValues(alpha: 0.25),
      selectionHandleColor: palette.primaryInk,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? palette.surfaceMuted
            : palette.surface,
      ),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return palette.border;
        return states.contains(WidgetState.selected)
            ? palette.primary
            : palette.textDisabled;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      thumbIcon: WidgetStateProperty.all(null),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (!states.contains(WidgetState.selected)) return Colors.transparent;
        return states.contains(WidgetState.disabled)
            ? palette.textDisabled
            : palette.primary;
      }),
      checkColor: WidgetStateProperty.all(palette.onPrimary),
      side: BorderSide(color: palette.textDisabled, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    radioTheme: RadioThemeData(
      fillColor: whenSelected(palette.primaryInk, palette.textDisabled),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: palette.primaryInk,
      inactiveTrackColor: palette.primaryTone.container,
      thumbColor: palette.primaryInk,
      overlayColor: palette.primary.withValues(alpha: 0.12),
      valueIndicatorColor: palette.text,
      valueIndicatorTextStyle: style(
        13,
        FontWeight.w700,
        color: palette.surface,
      ),
      trackHeight: 6,
      activeTickMarkColor: Colors.transparent,
      inactiveTickMarkColor: Colors.transparent,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(controlShape),
        side: WidgetStateProperty.all(
          BorderSide(color: palette.border, width: 1.5),
        ),
        backgroundColor: whenSelected(
          palette.primaryTone.container,
          palette.surface,
        ),
        foregroundColor: whenSelected(
          palette.primaryTone.onContainer,
          palette.textSecondary,
        ),
        textStyle: WidgetStateProperty.all(style(14, FontWeight.w700)),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        visualDensity: VisualDensity.standard,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: palette.surface,
      selectedColor: palette.primaryTone.container,
      disabledColor: palette.surfaceMuted,
      side: BorderSide(color: palette.border, width: 1.5),
      shape: const StadiumBorder(),
      labelStyle: style(14, FontWeight.w600),
      secondaryLabelStyle: style(
        14,
        FontWeight.w700,
        color: palette.primaryTone.onContainer,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      showCheckmark: false,
      elevation: 0,
      pressElevation: 0,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: palette.primaryInk,
      linearTrackColor: palette.primaryTone.container,
      circularTrackColor: Colors.transparent,
    ),
    badgeTheme: BadgeThemeData(
      backgroundColor: palette.highlight.base,
      textColor: palette.text,
    ),
    extensions: [NuniColors(palette)],
  );
}

/// The accent a status, badge or icon tile is drawn in.
enum NuniTone { primary, fairway, highlight, sunshine, danger, neutral }

extension NuniToneColors on NuniColors {
  AccentTone tone(NuniTone tone) => switch (tone) {
    NuniTone.primary => palette.primaryTone,
    NuniTone.fairway => palette.fairway,
    NuniTone.highlight => palette.highlight,
    NuniTone.sunshine => palette.sunshine,
    NuniTone.danger => palette.dangerTone,
    NuniTone.neutral => AccentTone(
      base: palette.textSecondary,
      container: palette.border,
      onContainer: palette.textSecondary,
    ),
  };
}
