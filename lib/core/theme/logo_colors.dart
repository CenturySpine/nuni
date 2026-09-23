import 'package:flutter/painting.dart';

/// Colours of the NUNI logo (Q23, restyled by the 2026-09-23 rebrand): fixed,
/// deliberately NOT read from [Palette] at runtime -- the logo must read the
/// same everywhere, including the PWA icons. Source of truth:
/// `web/icons/nuni_logo.svg`.
const Color nuniLogoNu = Color(0xFFFFFFFF);
const Color nuniLogoNi = Color(0xFFFFC43D);

/// The icon tile: a violet diagonal gradient, the same one as the brand hero.
const Color nuniLogoBackgroundStart = Color(0xFF5B4CF5);
const Color nuniLogoBackgroundEnd = Color(0xFF7B4FF0);
