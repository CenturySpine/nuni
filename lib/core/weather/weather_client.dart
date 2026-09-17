import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'weather.dart';

/// Open-Meteo current-conditions forecast (no API key, open CORS). Every
/// failure collapses to `null` -- weather capture is best-effort and silent
/// (plan 07).
class WeatherClient {
  WeatherClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<Weather?> fetch({required double lat, required double lng}) async {
    try {
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '$lat',
        'longitude': '$lng',
        'current': 'temperature_2m,wind_speed_10m,weather_code',
      });
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 3));
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, Object?>;
      final current = json['current'] as Map<String, Object?>?;
      if (current == null) return null;

      final temperature = (current['temperature_2m'] as num?)?.toDouble();
      final wind = (current['wind_speed_10m'] as num?)?.toDouble();
      final code = (current['weather_code'] as num?)?.toInt();
      if (temperature == null || wind == null || code == null) return null;

      return Weather(temperatureC: temperature, windKph: wind, code: code);
    } catch (_) {
      return null;
    }
  }

  /// Historical weather for a past [date] (plan 10: recapture when the
  /// organizer corrects a session's start date/time after the fact). [date]
  /// must be UTC (`DateTime.toUtc()`) -- the request pins the API's own
  /// timezone to UTC so the returned hourly timestamps compare directly
  /// against it, with no local-timezone ambiguity on either side. A
  /// different Open-Meteo API from [fetch]'s "current conditions" one --
  /// the archive only answers for a date range, hourly, so this asks for
  /// [date]'s single day and picks the hour closest to [date]'s own time.
  /// Same best-effort/silent contract as [fetch].
  Future<Weather?> fetchArchive({
    required double lat,
    required double lng,
    required DateTime date,
  }) async {
    try {
      final utc = date.toUtc();
      final day =
          '${utc.year.toString().padLeft(4, '0')}-'
          '${utc.month.toString().padLeft(2, '0')}-'
          '${utc.day.toString().padLeft(2, '0')}';
      final uri = Uri.https('archive-api.open-meteo.com', '/v1/archive', {
        'latitude': '$lat',
        'longitude': '$lng',
        'start_date': day,
        'end_date': day,
        'hourly': 'temperature_2m,wind_speed_10m,weather_code',
        'timezone': 'UTC',
      });
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, Object?>;
      final hourly = json['hourly'] as Map<String, Object?>?;
      if (hourly == null) return null;

      final times = hourly['time'] as List<dynamic>?;
      final temperatures = hourly['temperature_2m'] as List<dynamic>?;
      final winds = hourly['wind_speed_10m'] as List<dynamic>?;
      final codes = hourly['weather_code'] as List<dynamic>?;
      if (times == null ||
          temperatures == null ||
          winds == null ||
          codes == null ||
          times.isEmpty) {
        return null;
      }

      var closestIndex = 0;
      var closestDiff = const Duration(days: 1);
      for (var i = 0; i < times.length; i++) {
        // The API was asked for UTC (above), but returns each timestamp
        // without an offset (e.g. "2026-09-17T14:00") -- Dart's own
        // `DateTime.parse` would read that as local time otherwise, so the
        // "Z" is added explicitly to force a UTC reading.
        final hour = DateTime.parse('${times[i]}Z');
        final diff = (hour.difference(utc)).abs();
        if (diff < closestDiff) {
          closestDiff = diff;
          closestIndex = i;
        }
      }

      final temperature = (temperatures[closestIndex] as num?)?.toDouble();
      final wind = (winds[closestIndex] as num?)?.toDouble();
      final code = (codes[closestIndex] as num?)?.toInt();
      if (temperature == null || wind == null || code == null) return null;

      return Weather(temperatureC: temperature, windKph: wind, code: code);
    } catch (_) {
      return null;
    }
  }
}

final weatherClientProvider = Provider<WeatherClient>((ref) => WeatherClient());
