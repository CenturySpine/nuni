// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_forecast.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// An event's weather at its start time (plan 32), or null when Open-Meteo
/// has none (failure, beyond its horizon). Keyed by place and time, not by
/// event, so editing an event's other fields keeps it. Kept one hour in
/// memory: the home card, the planning and the event page share it.

@ProviderFor(eventForecast)
final eventForecastProvider = EventForecastFamily._();

/// An event's weather at its start time (plan 32), or null when Open-Meteo
/// has none (failure, beyond its horizon). Keyed by place and time, not by
/// event, so editing an event's other fields keeps it. Kept one hour in
/// memory: the home card, the planning and the event page share it.

final class EventForecastProvider
    extends
        $FunctionalProvider<AsyncValue<Weather?>, Weather?, FutureOr<Weather?>>
    with $FutureModifier<Weather?>, $FutureProvider<Weather?> {
  /// An event's weather at its start time (plan 32), or null when Open-Meteo
  /// has none (failure, beyond its horizon). Keyed by place and time, not by
  /// event, so editing an event's other fields keeps it. Kept one hour in
  /// memory: the home card, the planning and the event page share it.
  EventForecastProvider._({
    required EventForecastFamily super.from,
    required ({double lat, double lng, DateTime startsAt}) super.argument,
  }) : super(
         retry: null,
         name: r'eventForecastProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventForecastHash();

  @override
  String toString() {
    return r'eventForecastProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Weather?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Weather?> create(Ref ref) {
    final argument =
        this.argument as ({double lat, double lng, DateTime startsAt});
    return eventForecast(
      ref,
      lat: argument.lat,
      lng: argument.lng,
      startsAt: argument.startsAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventForecastProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventForecastHash() => r'74e50a504c77cc021c02ed8de709eea32d80f06c';

/// An event's weather at its start time (plan 32), or null when Open-Meteo
/// has none (failure, beyond its horizon). Keyed by place and time, not by
/// event, so editing an event's other fields keeps it. Kept one hour in
/// memory: the home card, the planning and the event page share it.

final class EventForecastFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Weather?>,
          ({double lat, double lng, DateTime startsAt})
        > {
  EventForecastFamily._()
    : super(
        retry: null,
        name: r'eventForecastProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// An event's weather at its start time (plan 32), or null when Open-Meteo
  /// has none (failure, beyond its horizon). Keyed by place and time, not by
  /// event, so editing an event's other fields keeps it. Kept one hour in
  /// memory: the home card, the planning and the event page share it.

  EventForecastProvider call({
    required double lat,
    required double lng,
    required DateTime startsAt,
  }) => EventForecastProvider._(
    argument: (lat: lat, lng: lng, startsAt: startsAt),
    from: this,
  );

  @override
  String toString() => r'eventForecastProvider';
}
