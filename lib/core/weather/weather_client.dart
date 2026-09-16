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
}

final weatherClientProvider = Provider<WeatherClient>((ref) => WeatherClient());
