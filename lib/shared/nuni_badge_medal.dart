import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/palettes.dart';
import '../core/theme/phosphor_icons.dart';

/// The ring of a badge in a series (plan 21, Q114): bronze, silver, gold in
/// order of difficulty; a single badge has none.
enum NuniMedalTier { none, bronze, silver, gold }

/// A badge medal (plan 21): a disc in its family's accent with its icon in
/// the middle, ringed in bronze, silver or gold for a series, plus one star
/// per step past gold (A5, A6). A badge still to earn is greyed: neutral
/// disc, outline icon, neutral ring.
class NuniBadgeMedal extends StatelessWidget {
  const NuniBadgeMedal({
    super.key,
    required this.icon,
    required this.earnedIcon,
    this.tone = NuniTone.primary,
    this.tier = NuniMedalTier.none,
    this.stars = 0,
    this.earned = true,
    this.size = 64,
  });

  /// Outline icon, shown while the badge is still to earn.
  final IconData icon;

  /// Filled icon, shown once earned.
  final IconData earnedIcon;
  final NuniTone tone;
  final NuniMedalTier tier;
  final int stars;
  final bool earned;
  final double size;

  static Color? _tierColor(NuniMedalTier tier) => switch (tier) {
    NuniMedalTier.none => null,
    NuniMedalTier.bronze => tierBronze,
    NuniMedalTier.silver => tierSilver,
    NuniMedalTier.gold => tierGold,
  };

  @override
  Widget build(BuildContext context) {
    final nuni = context.nuni;
    final colors = nuni.tone(tone);
    final tierColor = _tierColor(tier);
    final ring = tierColor == null
        ? null
        : Border.all(
            color: earned ? tierColor : nuni.border,
            width: size * 0.08,
          );

    final medal = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: earned ? colors.container : nuni.palette.surfaceMuted,
        border:
            ring ??
            (earned ? null : Border.all(color: nuni.border, width: 1.5)),
      ),
      alignment: Alignment.center,
      child: Icon(
        earned ? earnedIcon : icon,
        size: size * 0.46,
        color: earned ? colors.onContainer : nuni.palette.textDisabled,
      ),
    );
    if (stars == 0) return medal;

    // Stars sit on the bottom of the ring, on a small surface pill so they
    // read on any ring colour.
    final starSize = size * 0.2;
    return SizedBox(
      width: size,
      height: size + starSize * 0.4,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          medal,
          Positioned(
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: starSize * 0.15),
              decoration: BoxDecoration(
                color: nuni.palette.surface,
                borderRadius: BorderRadius.circular(starSize),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < stars; i++)
                    Icon(
                      PhosphorIcons.starFill,
                      size: starSize,
                      color: earned ? tierGold : nuni.palette.textDisabled,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
