import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../shared/nuni_badge_medal.dart';
import '../domain/badge.dart';

/// A badge's icon, outline and filled (plan 21, "Catalogue retenu"): a
/// series shares one icon, its tier gives the ring.
(IconData, IconData) badgeIcons(BadgeId id) => switch (id) {
  BadgeId.firstStart => (
    PhosphorIcons.badgeFlagBanner,
    PhosphorIcons.badgeFlagBannerFill,
  ),
  BadgeId.regular ||
  BadgeId.pillar ||
  BadgeId.addict ||
  BadgeId.streetLegend ||
  BadgeId.centurion => (
    PhosphorIcons.badgeCalendarCheck,
    PhosphorIcons.badgeCalendarCheckFill,
  ),
  BadgeId.fiftyHoles || BadgeId.hundredHoles => (
    PhosphorIcons.badgeSneakerMove,
    PhosphorIcons.badgeSneakerMoveFill,
  ),
  BadgeId.appointment => (
    PhosphorIcons.badgeCalendarDots,
    PhosphorIcons.badgeCalendarDotsFill,
  ),
  BadgeId.metronome => (
    PhosphorIcons.badgeMetronome,
    PhosphorIcons.badgeMetronomeFill,
  ),
  BadgeId.busyWeek => (
    PhosphorIcons.badgeFireSimple,
    PhosphorIcons.badgeFireSimpleFill,
  ),
  BadgeId.fourSeasons => (PhosphorIcons.badgeLeaf, PhosphorIcons.badgeLeafFill),
  BadgeId.veteran => (
    PhosphorIcons.badgeHourglassHigh,
    PhosphorIcons.badgeHourglassHighFill,
  ),
  BadgeId.allYear => (
    PhosphorIcons.badgeCalendarStar,
    PhosphorIcons.badgeCalendarStarFill,
  ),
  BadgeId.onPar => (PhosphorIcons.badgeEquals, PhosphorIcons.badgeEqualsFill),
  BadgeId.birdie ||
  BadgeId.eagle ||
  BadgeId.albatross => (PhosphorIcons.badgeBird, PhosphorIcons.badgeBirdFill),
  BadgeId.holeInOne => (PhosphorIcons.badgeGolf, PhosphorIcons.badgeGolfFill),
  BadgeId.birdieFlock || BadgeId.birdieSwarm => (
    PhosphorIcons.badgeFeather,
    PhosphorIcons.badgeFeatherFill,
  ),
  BadgeId.parStreak => (PhosphorIcons.badgeStack, PhosphorIcons.badgeStackFill),
  BadgeId.hotHand => (PhosphorIcons.badgeFire, PhosphorIcons.badgeFireFill),
  BadgeId.clean => (
    PhosphorIcons.badgeShieldCheck,
    PhosphorIcons.badgeShieldCheckFill,
  ),
  BadgeId.underPar => (
    PhosphorIcons.badgeTrendDown,
    PhosphorIcons.badgeTrendDownFill,
  ),
  BadgeId.bounceBack => (
    PhosphorIcons.badgeArrowUUpLeft,
    PhosphorIcons.badgeArrowUUpLeftFill,
  ),
  BadgeId.steady => (PhosphorIcons.badgeRuler, PhosphorIcons.badgeRulerFill),
  BadgeId.firstWin ||
  BadgeId.winner ||
  BadgeId.dominator ||
  BadgeId.teamFirstWin ||
  BadgeId.teamWinner ||
  BadgeId.teamDominator => (
    PhosphorIcons.badgeTrophy,
    PhosphorIcons.badgeTrophyFill,
  ),
  BadgeId.hatTrick || BadgeId.teamHatTrick => (
    PhosphorIcons.badgeLightning,
    PhosphorIcons.badgeLightningFill,
  ),
  BadgeId.onTheBox ||
  BadgeId.podiumRegular ||
  BadgeId.teamOnTheBox ||
  BadgeId.teamPodiumRegular => (
    PhosphorIcons.badgeRanking,
    PhosphorIcons.badgeRankingFill,
  ),
  BadgeId.wireToWire || BadgeId.teamWireToWire => (
    PhosphorIcons.badgeFlagCheckered,
    PhosphorIcons.badgeFlagCheckeredFill,
  ),
  BadgeId.comeback || BadgeId.teamComeback => (
    PhosphorIcons.badgeRocketLaunch,
    PhosphorIcons.badgeRocketLaunchFill,
  ),
  BadgeId.photoFinish || BadgeId.teamPhotoFinish => (
    PhosphorIcons.badgeTimer,
    PhosphorIcons.badgeTimerFill,
  ),
  BadgeId.holdUp || BadgeId.teamHoldUp => (
    PhosphorIcons.badgeVault,
    PhosphorIcons.badgeVaultFill,
  ),
  BadgeId.competitor => (
    PhosphorIcons.badgeFlagPennant,
    PhosphorIcons.badgeFlagPennantFill,
  ),
  BadgeId.fullSeason => (
    PhosphorIcons.badgeCalendarPlus,
    PhosphorIcons.badgeCalendarPlusFill,
  ),
  BadgeId.champion ||
  BadgeId.seasonPodium ||
  BadgeId.topFive => (PhosphorIcons.badgeMedal, PhosphorIcons.badgeMedalFill),
  BadgeId.teammate => (
    PhosphorIcons.badgeHandshake,
    PhosphorIcons.badgeHandshakeFill,
  ),
  BadgeId.gatherer => (
    PhosphorIcons.badgeUsersFour,
    PhosphorIcons.badgeUsersFourFill,
  ),
  BadgeId.dreamTeam => (
    PhosphorIcons.badgeHandFist,
    PhosphorIcons.badgeHandFistFill,
  ),
  BadgeId.curious || BadgeId.explorer => (
    PhosphorIcons.badgeCompass,
    PhosphorIcons.badgeCompassFill,
  ),
  BadgeId.globetrotter => (
    PhosphorIcons.badgeGlobeHemisphereWest,
    PhosphorIcons.badgeGlobeHemisphereWestFill,
  ),
  BadgeId.guest => (
    PhosphorIcons.badgeSuitcaseRolling,
    PhosphorIcons.badgeSuitcaseRollingFill,
  ),
  BadgeId.improviser => (
    PhosphorIcons.badgeMagicWand,
    PhosphorIcons.badgeMagicWandFill,
  ),
  BadgeId.rain => (
    PhosphorIcons.badgeCloudRain,
    PhosphorIcons.badgeCloudRainFill,
  ),
  BadgeId.frosty => (
    PhosphorIcons.badgeThermometerCold,
    PhosphorIcons.badgeThermometerColdFill,
  ),
  BadgeId.heatwave => (
    PhosphorIcons.badgeThermometerHot,
    PhosphorIcons.badgeThermometerHotFill,
  ),
  BadgeId.gust => (PhosphorIcons.badgeWind, PhosphorIcons.badgeWindFill),
  BadgeId.nightOwl => (
    PhosphorIcons.badgeMoonStars,
    PhosphorIcons.badgeMoonStarsFill,
  ),
  BadgeId.earlyBird => (
    PhosphorIcons.badgeSunHorizon,
    PhosphorIcons.badgeSunHorizonFill,
  ),
  BadgeId.marathon => (
    PhosphorIcons.badgePersonSimpleRun,
    PhosphorIcons.badgePersonSimpleRunFill,
  ),
  BadgeId.snow => (
    PhosphorIcons.badgeCloudSnow,
    PhosphorIcons.badgeCloudSnowFill,
  ),
  BadgeId.redLantern || BadgeId.teamRedLantern => (
    PhosphorIcons.badgeLamp,
    PhosphorIcons.badgeLampFill,
  ),
  BadgeId.adultsOnly => (
    PhosphorIcons.badgeXCircle,
    PhosphorIcons.badgeXCircleFill,
  ),
  BadgeId.persistent || BadgeId.teamPersistent => (
    PhosphorIcons.badgeRepeat,
    PhosphorIcons.badgeRepeatFill,
  ),
  BadgeId.rollerCoaster => (
    PhosphorIcons.badgeMountains,
    PhosphorIcons.badgeMountainsFill,
  ),
};

/// A family's accent (plan 21, "Couleur de famille"): a palette has four
/// accents for eleven families, so they are grouped.
NuniTone badgeTone(BadgeFamily family) => switch (family) {
  BadgeFamily.attendance ||
  BadgeFamily.regularity ||
  BadgeFamily.conditions => NuniTone.fairway,
  BadgeFamily.strokes => NuniTone.primary,
  BadgeFamily.wins || BadgeFamily.championship => NuniTone.sunshine,
  BadgeFamily.team ||
  BadgeFamily.explorer ||
  BadgeFamily.fun => NuniTone.highlight,
};

NuniMedalTier _tier(BadgeTier tier) => switch (tier) {
  BadgeTier.none => NuniMedalTier.none,
  BadgeTier.bronze => NuniMedalTier.bronze,
  BadgeTier.silver => NuniMedalTier.silver,
  BadgeTier.gold => NuniMedalTier.gold,
};

/// The medal of one badge, earned or still to earn.
class BadgeMedal extends StatelessWidget {
  const BadgeMedal({
    super.key,
    required this.id,
    required this.earned,
    this.size = 64,
  });

  final BadgeId id;
  final bool earned;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (icon, earnedIcon) = badgeIcons(id);
    return NuniBadgeMedal(
      icon: icon,
      earnedIcon: earnedIcon,
      tone: badgeTone(id.family),
      tier: _tier(id.tier),
      stars: id.stars,
      earned: earned,
      size: size,
    );
  }
}
