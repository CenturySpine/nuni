import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../core/weather/weather.dart';
import '../../../core/weather/weather_icon.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_status_pill.dart';
import '../data/event_forecast.dart';
import '../domain/event.dart';
import '../domain/planning.dart';

/// [event]'s forecast when it shows one (plan 32), null otherwise --
/// meanwhile too: nothing is drawn while it loads.
Weather? _watchForecast(WidgetRef ref, Event event) {
  if (!showsForecast(event, DateTime.now())) return null;
  return ref
      .watch(
        eventForecastProvider(
          lat: event.locationLat!,
          lng: event.locationLng!,
          startsAt: event.startsAt,
        ),
      )
      .value;
}

/// The forecast icon on an event's card (plan 32): nothing without one.
class EventForecastPill extends ConsumerWidget {
  const EventForecastPill({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = _watchForecast(ref, event);
    if (weather == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.planningForecastSemantics(weather.temperatureC.round()),
      excludeSemantics: true,
      child: NuniStatusPill(
        label: '',
        icon: weatherIcon(weather.code),
        tone: NuniTone.neutral,
      ),
    );
  }
}

/// "Forecast" on an event's page (plan 32, Q214): the weather at its start
/// time -- temperature, chance of rain, wind. Nothing without one.
class EventForecastBlock extends ConsumerWidget {
  const EventForecastBlock({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = _watchForecast(ref, event);
    if (weather == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    Widget measure(IconData icon, String value, String semantics) => Semantics(
      label: semantics,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(value, style: textTheme.titleSmall),
        ],
      ),
    );

    final temperature = weather.temperatureC.round();
    final wind = weather.windKph.round();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: NuniCard(
        child: Row(
          children: [
            Icon(
              weatherIcon(weather.code),
              size: 32,
              color: context.nuni.primaryInk,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.planningForecastTitle,
                    style: textTheme.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      measure(
                        PhosphorIcons.thermometerSimple,
                        l10n.planningForecastTemperature(temperature),
                        l10n.planningForecastSemantics(temperature),
                      ),
                      if (weather.rainChance != null)
                        measure(
                          PhosphorIcons.drop,
                          l10n.planningForecastRain(weather.rainChance!),
                          l10n.planningForecastRainSemantics(
                            weather.rainChance!,
                          ),
                        ),
                      measure(
                        PhosphorIcons.wind,
                        l10n.planningForecastWind(wind),
                        l10n.planningForecastWindSemantics(wind),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
