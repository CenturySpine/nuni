import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/weather/weather.dart';
import '../../../core/weather/weather_client.dart';

part 'event_forecast.g.dart';

/// How long a fetched forecast is reused before asking Open-Meteo again.
const _forecastLifetime = Duration(hours: 1);

/// An event's weather at its start time (plan 32), or null when Open-Meteo
/// has none (failure, beyond its horizon). Keyed by place and time, not by
/// event, so editing an event's other fields keeps it. Kept one hour in
/// memory: the home card, the planning and the event page share it.
@riverpod
Future<Weather?> eventForecast(
  Ref ref, {
  required double lat,
  required double lng,
  required DateTime startsAt,
}) {
  final link = ref.keepAlive();
  final timer = Timer(_forecastLifetime, link.close);
  ref.onDispose(timer.cancel);
  return ref
      .watch(weatherClientProvider)
      .fetchForecast(lat: lat, lng: lng, date: startsAt);
}
