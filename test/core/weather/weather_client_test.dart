import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nuni/core/weather/weather.dart';
import 'package:nuni/core/weather/weather_client.dart';

http.Response _hourly(Map<String, Object?> hourly) =>
    http.Response(jsonEncode({'hourly': hourly}), 200);

void main() {
  group('fetchForecast', () {
    test('asks for the start hour in UTC and reads the closest one', () async {
      late Uri asked;
      final client = WeatherClient(
        httpClient: MockClient((request) async {
          asked = request.url;
          return _hourly({
            'time': ['2026-10-02T12:00', '2026-10-02T13:00'],
            'temperature_2m': [14.2, 15.6],
            'precipitation_probability': [20, 40],
            'wind_speed_10m': [11.0, 13.4],
            'weather_code': [3, 61],
          });
        }),
      );

      final weather = await client.fetchForecast(
        lat: 45.76,
        lng: 4.83,
        date: DateTime.utc(2026, 10, 2, 12, 50),
      );

      expect(asked.host, 'api.open-meteo.com');
      expect(asked.queryParameters['start_hour'], '2026-10-02T12:00');
      expect(asked.queryParameters['end_hour'], '2026-10-02T13:00');
      expect(asked.queryParameters['timezone'], 'UTC');
      expect(
        weather,
        const Weather(
          temperatureC: 15.6,
          windKph: 13.4,
          code: 61,
          rainChance: 40,
        ),
      );
    });

    test('null when no hour is within an hour of the start', () async {
      final client = WeatherClient(
        httpClient: MockClient(
          (_) async => _hourly({
            'time': ['2026-10-02T09:00'],
            'temperature_2m': [14.0],
            'precipitation_probability': [0],
            'wind_speed_10m': [5.0],
            'weather_code': [0],
          }),
        ),
      );
      expect(
        await client.fetchForecast(
          lat: 45.76,
          lng: 4.83,
          date: DateTime.utc(2026, 10, 2, 12),
        ),
        isNull,
      );
    });

    test('null on a missing value or a failure, never an error', () async {
      final missing = WeatherClient(
        httpClient: MockClient(
          (_) async => _hourly({
            'time': ['2026-10-02T12:00'],
            'temperature_2m': [null],
            'wind_speed_10m': [5.0],
            'weather_code': [0],
          }),
        ),
      );
      final failing = WeatherClient(
        httpClient: MockClient((_) async => http.Response('', 400)),
      );
      final date = DateTime.utc(2026, 10, 2, 12);
      expect(await missing.fetchForecast(lat: 0, lng: 0, date: date), isNull);
      expect(await failing.fetchForecast(lat: 0, lng: 0, date: date), isNull);
    });
  });

  test('a session weather keeps its stored shape (no rain chance)', () {
    expect(const Weather(temperatureC: 12, windKph: 8, code: 2).toJson(), {
      'temperature_c': 12.0,
      'wind_kph': 8.0,
      'code': 2,
    });
  });
}
