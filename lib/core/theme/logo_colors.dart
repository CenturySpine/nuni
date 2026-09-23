import 'package:flutter/painting.dart';

import 'palettes.dart';

/// Colours of the PWA icons and favicon (`tool/generate_icons.dart`,
/// `web/icons/nuni_logo.svg`): one icon per installation, so it uses the
/// default palette whatever the user picked. Inside the app the logo follows
/// the chosen palette (`NuniLogo`).
final Color nuniLogoNu = defaultPalette.onPrimary;
final Color nuniLogoNi = defaultPalette.logoNi;
final Color nuniLogoBackgroundStart = defaultPalette.heroStart;
final Color nuniLogoBackgroundEnd = defaultPalette.heroEnd;
