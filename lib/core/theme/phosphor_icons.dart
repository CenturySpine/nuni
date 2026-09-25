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
  static const crownFill = IconData(0xe614, fontFamily: _fill);
  static const medalFill = IconData(0xe320, fontFamily: _fill);
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

  // Plan 21: badge medals, each in outline (to earn) and fill (earned)
  // (docs/plans/21_badges.md, "Catalogue retenu"). Const so icon tree
  // shaking keeps working in release builds.
  static const badgeArrowUUpLeft = IconData(0xe08a, fontFamily: _regular);
  static const badgeArrowUUpLeftFill = IconData(0xe08a, fontFamily: _fill);
  static const badgeBird = IconData(0xe72c, fontFamily: _regular);
  static const badgeBirdFill = IconData(0xe72c, fontFamily: _fill);
  static const badgeBlueprint = IconData(0xeda0, fontFamily: _regular);
  static const badgeBlueprintFill = IconData(0xeda0, fontFamily: _fill);
  static const badgeCalendarCheck = IconData(0xe712, fontFamily: _regular);
  static const badgeCalendarCheckFill = IconData(0xe712, fontFamily: _fill);
  static const badgeCalendarDots = IconData(0xe7b4, fontFamily: _regular);
  static const badgeCalendarDotsFill = IconData(0xe7b4, fontFamily: _fill);
  static const badgeCalendarPlus = IconData(0xe714, fontFamily: _regular);
  static const badgeCalendarPlusFill = IconData(0xe714, fontFamily: _fill);
  static const badgeCalendarStar = IconData(0xe8b2, fontFamily: _regular);
  static const badgeCalendarStarFill = IconData(0xe8b2, fontFamily: _fill);
  static const badgeCamera = IconData(0xe10e, fontFamily: _regular);
  static const badgeCameraFill = IconData(0xe10e, fontFamily: _fill);
  static const badgeCloudRain = IconData(0xe1b4, fontFamily: _regular);
  static const badgeCloudRainFill = IconData(0xe1b4, fontFamily: _fill);
  static const badgeCloudSnow = IconData(0xe1b8, fontFamily: _regular);
  static const badgeCloudSnowFill = IconData(0xe1b8, fontFamily: _fill);
  static const badgeCompass = IconData(0xe1c8, fontFamily: _regular);
  static const badgeCompassFill = IconData(0xe1c8, fontFamily: _fill);
  static const badgeHourglass = IconData(0xe2b2, fontFamily: _regular);
  static const badgeHourglassFill = IconData(0xe2b2, fontFamily: _fill);
  static const badgeCastleTurret = IconData(0xe9d0, fontFamily: _regular);
  static const badgeCastleTurretFill = IconData(0xe9d0, fontFamily: _fill);
  static const badgeCrownCross = IconData(0xee5e, fontFamily: _regular);
  static const badgeCrownCrossFill = IconData(0xee5e, fontFamily: _fill);
  static const badgeCrown = IconData(0xe614, fontFamily: _regular);
  static const badgeCrownFill = IconData(0xe614, fontFamily: _fill);
  static const badgeEquals = IconData(0xe21c, fontFamily: _regular);
  static const badgeEqualsFill = IconData(0xe21c, fontFamily: _fill);
  static const badgeFeather = IconData(0xe9c0, fontFamily: _regular);
  static const badgeFeatherFill = IconData(0xe9c0, fontFamily: _fill);
  static const badgeFire = IconData(0xe242, fontFamily: _regular);
  static const badgeFireFill = IconData(0xe242, fontFamily: _fill);
  static const badgeFireSimple = IconData(0xe620, fontFamily: _regular);
  static const badgeFireSimpleFill = IconData(0xe620, fontFamily: _fill);
  static const badgeFlagBanner = IconData(0xe622, fontFamily: _regular);
  static const badgeFlagBannerFill = IconData(0xe622, fontFamily: _fill);
  static const badgeFlagCheckered = IconData(0xea38, fontFamily: _regular);
  static const badgeFlagCheckeredFill = IconData(0xea38, fontFamily: _fill);
  static const badgeFlagPennant = IconData(0xecf0, fontFamily: _regular);
  static const badgeFlagPennantFill = IconData(0xecf0, fontFamily: _fill);
  static const badgeGlobeHemisphereWest = IconData(
    0xe28c,
    fontFamily: _regular,
  );
  static const badgeGlobeHemisphereWestFill = IconData(
    0xe28c,
    fontFamily: _fill,
  );
  static const badgeGolf = IconData(0xea3e, fontFamily: _regular);
  static const badgeGolfFill = IconData(0xea3e, fontFamily: _fill);
  static const badgeHandFist = IconData(0xe57a, fontFamily: _regular);
  static const badgeHandFistFill = IconData(0xe57a, fontFamily: _fill);
  static const badgeHandshake = IconData(0xe582, fontFamily: _regular);
  static const badgeHandshakeFill = IconData(0xe582, fontFamily: _fill);
  static const badgeHourglassHigh = IconData(0xe2b4, fontFamily: _regular);
  static const badgeHourglassHighFill = IconData(0xe2b4, fontFamily: _fill);
  static const badgeLamp = IconData(0xe638, fontFamily: _regular);
  static const badgeLampFill = IconData(0xe638, fontFamily: _fill);
  static const badgeLeaf = IconData(0xe2da, fontFamily: _regular);
  static const badgeLeafFill = IconData(0xe2da, fontFamily: _fill);
  static const badgeLightning = IconData(0xe2de, fontFamily: _regular);
  static const badgeLightningFill = IconData(0xe2de, fontFamily: _fill);
  static const badgeMagicWand = IconData(0xe6b6, fontFamily: _regular);
  static const badgeMagicWandFill = IconData(0xe6b6, fontFamily: _fill);
  static const badgeMagnet = IconData(0xe680, fontFamily: _regular);
  static const badgeMagnetFill = IconData(0xe680, fontFamily: _fill);
  static const badgeMapPinPlus = IconData(0xe314, fontFamily: _regular);
  static const badgeMapPinPlusFill = IconData(0xe314, fontFamily: _fill);
  static const badgeMedal = IconData(0xe320, fontFamily: _regular);
  static const badgeMedalFill = IconData(0xe320, fontFamily: _fill);
  static const badgeMegaphone = IconData(0xe324, fontFamily: _regular);
  static const badgeMegaphoneFill = IconData(0xe324, fontFamily: _fill);
  static const badgeMetronome = IconData(0xec8e, fontFamily: _regular);
  static const badgeMetronomeFill = IconData(0xec8e, fontFamily: _fill);
  static const badgeMoonStars = IconData(0xe58e, fontFamily: _regular);
  static const badgeMoonStarsFill = IconData(0xe58e, fontFamily: _fill);
  static const badgeMountains = IconData(0xe7ae, fontFamily: _regular);
  static const badgeMountainsFill = IconData(0xe7ae, fontFamily: _fill);
  static const badgePersonSimpleRun = IconData(0xe730, fontFamily: _regular);
  static const badgePersonSimpleRunFill = IconData(0xe730, fontFamily: _fill);
  static const badgeRanking = IconData(0xed62, fontFamily: _regular);
  static const badgeRankingFill = IconData(0xed62, fontFamily: _fill);
  static const badgeRepeat = IconData(0xe3f6, fontFamily: _regular);
  static const badgeRepeatFill = IconData(0xe3f6, fontFamily: _fill);
  static const badgeRocketLaunch = IconData(0xe3fe, fontFamily: _regular);
  static const badgeRocketLaunchFill = IconData(0xe3fe, fontFamily: _fill);
  static const badgeRuler = IconData(0xe6b8, fontFamily: _regular);
  static const badgeRulerFill = IconData(0xe6b8, fontFamily: _fill);
  static const badgeShieldCheck = IconData(0xe40c, fontFamily: _regular);
  static const badgeShieldCheckFill = IconData(0xe40c, fontFamily: _fill);
  static const badgeSneakerMove = IconData(0xed60, fontFamily: _regular);
  static const badgeSneakerMoveFill = IconData(0xed60, fontFamily: _fill);
  static const badgeStack = IconData(0xe466, fontFamily: _regular);
  static const badgeStackFill = IconData(0xe466, fontFamily: _fill);
  static const badgeSword = IconData(0xe5ba, fontFamily: _regular);
  static const badgeSwordFill = IconData(0xe5ba, fontFamily: _fill);
  static const badgeStarHalf = IconData(0xe70a, fontFamily: _regular);
  static const badgeStarHalfFill = IconData(0xe70a, fontFamily: _fill);
  static const badgeStar = IconData(0xe46a, fontFamily: _regular);
  static const badgeStarFill = IconData(0xe46a, fontFamily: _fill);
  static const badgeSuitcaseRolling = IconData(0xe9b0, fontFamily: _regular);
  static const badgeSuitcaseRollingFill = IconData(0xe9b0, fontFamily: _fill);
  static const badgeSunHorizon = IconData(0xe5b6, fontFamily: _regular);
  static const badgeSunHorizonFill = IconData(0xe5b6, fontFamily: _fill);
  static const badgeThermometerCold = IconData(0xe5c8, fontFamily: _regular);
  static const badgeThermometerColdFill = IconData(0xe5c8, fontFamily: _fill);
  static const badgeThermometerHot = IconData(0xe5ca, fontFamily: _regular);
  static const badgeThermometerHotFill = IconData(0xe5ca, fontFamily: _fill);
  static const badgeTimer = IconData(0xe492, fontFamily: _regular);
  static const badgeTimerFill = IconData(0xe492, fontFamily: _fill);
  static const badgeTrendDown = IconData(0xe4ac, fontFamily: _regular);
  static const badgeTrendDownFill = IconData(0xe4ac, fontFamily: _fill);
  static const badgeTarget = IconData(0xe47c, fontFamily: _regular);
  static const badgeTargetFill = IconData(0xe47c, fontFamily: _fill);
  static const badgeTrophy = IconData(0xe67e, fontFamily: _regular);
  static const badgeTrophyFill = IconData(0xe67e, fontFamily: _fill);
  static const badgeUsersFour = IconData(0xe68c, fontFamily: _regular);
  static const badgeUsersFourFill = IconData(0xe68c, fontFamily: _fill);
  static const badgeVault = IconData(0xe76e, fontFamily: _regular);
  static const badgeVaultFill = IconData(0xe76e, fontFamily: _fill);
  static const badgeWind = IconData(0xe5d2, fontFamily: _regular);
  static const badgeWindFill = IconData(0xe5d2, fontFamily: _fill);
  static const badgeXCircle = IconData(0xe4f8, fontFamily: _regular);
  static const badgeXCircleFill = IconData(0xe4f8, fontFamily: _fill);
}
