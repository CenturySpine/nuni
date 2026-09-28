import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather.freezed.dart';
part 'weather.g.dart';

/// A snapshot fetched from Open-Meteo at session creation (plan 07), stored
/// as-is in `sessions.weather` (jsonb). Read back verbatim by a future plan
/// (session header, exports) -- this plan only captures and stores it.
/// Also an event's forecast (plan 32), never stored, the only one with a
/// [rainChance].
@freezed
abstract class Weather with _$Weather {
  const factory Weather({
    @JsonKey(name: 'temperature_c') required double temperatureC,
    @JsonKey(name: 'wind_kph') required double windKph,
    required int code,
    // Precipitation probability in %, forecasts only (plan 32): left out of
    // the json so a session's stored weather keeps its shape.
    @JsonKey(name: 'rain_chance', includeIfNull: false) int? rainChance,
  }) = _Weather;

  factory Weather.fromJson(Map<String, Object?> json) =>
      _$WeatherFromJson(json);
}
