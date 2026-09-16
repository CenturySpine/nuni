import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather.freezed.dart';
part 'weather.g.dart';

/// A snapshot fetched from Open-Meteo at session creation (plan 07), stored
/// as-is in `sessions.weather` (jsonb). Read back verbatim by a future plan
/// (session header, exports) -- this plan only captures and stores it.
@freezed
abstract class Weather with _$Weather {
  const factory Weather({
    @JsonKey(name: 'temperature_c') required double temperatureC,
    @JsonKey(name: 'wind_kph') required double windKph,
    required int code,
  }) = _Weather;

  factory Weather.fromJson(Map<String, Object?> json) =>
      _$WeatherFromJson(json);
}
