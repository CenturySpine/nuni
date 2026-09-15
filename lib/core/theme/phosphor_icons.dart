import 'package:flutter/widgets.dart';

/// Phosphor Icons (MIT, phosphoricons.com) -- the same icon family used by
/// the PO's other app, Ridgegear (`src/components/ui/Icon.tsx`, backed by
/// `@phosphor-icons/web`). Vendored as plain [IconData] constants rather
/// than via the `phosphor_flutter` package: that package declares
/// `class PhosphorIconData extends IconData`, and current Flutter marks
/// `IconData` a `final class`, which forbids extending it outside its own
/// library -- the package fails to compile on this Flutter version.
///
/// Only the icons this app actually uses are listed; add more by name and
/// codepoint from https://phosphoricons.com as needed (regular font:
/// assets/fonts/Phosphor.ttf, fill font: assets/fonts/Phosphor-Fill.ttf).
abstract final class PhosphorIcons {
  static const _regular = 'PhosphorRegular';
  static const _fill = 'PhosphorFill';

  static const house = IconData(0xe2c2, fontFamily: _regular);
  static const houseFill = IconData(0xe2c2, fontFamily: _fill);

  static const golf = IconData(0xea3e, fontFamily: _regular);
  static const golfFill = IconData(0xea3e, fontFamily: _fill);

  static const clockCounterClockwise = IconData(0xe1a0, fontFamily: _regular);
  static const clockCounterClockwiseFill = IconData(0xe1a0, fontFamily: _fill);

  static const userCircle = IconData(0xe4c4, fontFamily: _regular);
  static const caretRight = IconData(0xe13a, fontFamily: _regular);
  static const tray = IconData(0xe4aa, fontFamily: _regular);
  static const warningCircle = IconData(0xe4e2, fontFamily: _regular);
  static const arrowClockwise = IconData(0xe036, fontFamily: _regular);
  static const signpost = IconData(0xe89c, fontFamily: _regular);
  static const googleLogo = IconData(0xe292, fontFamily: _regular);
}
