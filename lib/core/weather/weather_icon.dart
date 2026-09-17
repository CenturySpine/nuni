import 'package:flutter/widgets.dart';

import '../theme/phosphor_icons.dart';

/// Open-Meteo's `weather_code` follows the WMO table (4677) -- grouped down
/// to the handful of icons this app actually shows (plan 10, first screen
/// to display the weather this app has captured since plan 07).
IconData weatherIcon(int code) => switch (code) {
  0 => PhosphorIcons.sun,
  1 || 2 => PhosphorIcons.cloudSun,
  3 => PhosphorIcons.cloud,
  45 || 48 => PhosphorIcons.cloudFog,
  51 || 53 || 55 || 56 || 57 => PhosphorIcons.cloudRain,
  61 || 63 || 65 || 66 || 67 => PhosphorIcons.cloudRain,
  80 || 81 || 82 => PhosphorIcons.cloudRain,
  71 || 73 || 75 || 77 || 85 || 86 => PhosphorIcons.cloudSnow,
  95 || 96 || 99 => PhosphorIcons.cloudLightning,
  _ => PhosphorIcons.cloud,
};
