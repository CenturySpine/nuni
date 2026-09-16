// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Weather _$WeatherFromJson(Map<String, dynamic> json) => _Weather(
  temperatureC: (json['temperature_c'] as num).toDouble(),
  windKph: (json['wind_kph'] as num).toDouble(),
  code: (json['code'] as num).toInt(),
);

Map<String, dynamic> _$WeatherToJson(_Weather instance) => <String, dynamic>{
  'temperature_c': instance.temperatureC,
  'wind_kph': instance.windKph,
  'code': instance.code,
};
