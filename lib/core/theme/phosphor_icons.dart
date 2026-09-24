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
  static const arrowSquareOut = IconData(0xe5de, fontFamily: _regular);
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
  static const signOut = IconData(0xe42a, fontFamily: _regular);

  static const plus = IconData(0xe3d4, fontFamily: _regular);
  static const mapPin = IconData(0xe316, fontFamily: _regular);
  static const mapPinFill = IconData(0xe316, fontFamily: _fill);
  static const crosshair = IconData(0xe1d6, fontFamily: _regular);
  static const globe = IconData(0xe288, fontFamily: _regular);
  static const lockSimple = IconData(0xe308, fontFamily: _regular);
  static const camera = IconData(0xe10e, fontFamily: _regular);
  static const trash = IconData(0xe4a6, fontFamily: _regular);
  static const navigationArrow = IconData(0xeade, fontFamily: _regular);
  static const pencilSimple = IconData(0xe3b4, fontFamily: _regular);
  static const list = IconData(0xe2f0, fontFamily: _regular);
  static const mapTrifold = IconData(0xe31a, fontFamily: _regular);

  static const check = IconData(0xe182, fontFamily: _regular);
  static const checkCircle = IconData(0xe184, fontFamily: _regular);
  static const copy = IconData(0xe1ca, fontFamily: _regular);
  static const diceFive = IconData(0xe1ee, fontFamily: _regular);
  static const info = IconData(0xe2ce, fontFamily: _regular);
  static const minusCircle = IconData(0xe32c, fontFamily: _regular);
  static const play = IconData(0xe3d0, fontFamily: _regular);
  static const shuffle = IconData(0xe422, fontFamily: _regular);
  static const userPlus = IconData(0xe4d0, fontFamily: _regular);
  static const users = IconData(0xe4d6, fontFamily: _regular);
  static const usersThree = IconData(0xe68e, fontFamily: _regular);
  static const usersThreeFill = IconData(0xe68e, fontFamily: _fill);
  static const envelopeSimple = IconData(0xe218, fontFamily: _regular);
  static const phone = IconData(0xe3b8, fontFamily: _regular);
  static const hourglass = IconData(0xe2b2, fontFamily: _regular);
  static const globeSimple = IconData(0xe28e, fontFamily: _regular);
  static const sealCheck = IconData(0xe606, fontFamily: _regular);
  static const shieldCheck = IconData(0xe40c, fontFamily: _regular);
  static const mapPinLine = IconData(0xe318, fontFamily: _regular);
  static const xCircle = IconData(0xe4f8, fontFamily: _regular);

  static const crown = IconData(0xe614, fontFamily: _regular);
  static const qrCode = IconData(0xe3e6, fontFamily: _regular);
  static const shareNetwork = IconData(0xe408, fontFamily: _regular);
  static const signIn = IconData(0xe428, fontFamily: _regular);

  // Weather (plan 10): mapped from the WMO code Open-Meteo returns, see
  // `core/weather/weather_icon.dart`.
  static const sun = IconData(0xe472, fontFamily: _regular);
  static const cloudSun = IconData(0xe540, fontFamily: _regular);
  static const cloud = IconData(0xe1aa, fontFamily: _regular);
  static const cloudFog = IconData(0xe53c, fontFamily: _regular);
  static const cloudRain = IconData(0xe1b4, fontFamily: _regular);
  static const cloudLightning = IconData(0xe1b2, fontFamily: _regular);
  static const cloudSnow = IconData(0xe1b8, fontFamily: _regular);

  static const download = IconData(0xe20a, fontFamily: _regular);
  static const fileImage = IconData(0xea24, fontFamily: _regular);
  static const filePdf = IconData(0xe702, fontFamily: _regular);
  static const funnel = IconData(0xe266, fontFamily: _regular);
  static const imageSquare = IconData(0xe2cc, fontFamily: _regular);
  static const star = IconData(0xe46a, fontFamily: _regular);
  static const starFill = IconData(0xe46a, fontFamily: _fill);

  // Plan 26: spectator notice, participation marker, played-hole settings.
  static const eye = IconData(0xe220, fontFamily: _regular);
  static const gear = IconData(0xe270, fontFamily: _regular);
  static const userCheck = IconData(0xeafa, fontFamily: _regular);
}
