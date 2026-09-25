// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planning_rights.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the user is [associationId]'s local manager or a super_admin --
/// the same people who tag the championship.

@ProviderFor(canModeratePlanning)
final canModeratePlanningProvider = CanModeratePlanningFamily._();

/// Whether the user is [associationId]'s local manager or a super_admin --
/// the same people who tag the championship.

final class CanModeratePlanningProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the user is [associationId]'s local manager or a super_admin --
  /// the same people who tag the championship.
  CanModeratePlanningProvider._({
    required CanModeratePlanningFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'canModeratePlanningProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$canModeratePlanningHash();

  @override
  String toString() {
    return r'canModeratePlanningProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return canModeratePlanning(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CanModeratePlanningProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$canModeratePlanningHash() =>
    r'c33e3481c0a0fa70b67de9028eed58d954b8a843';

/// Whether the user is [associationId]'s local manager or a super_admin --
/// the same people who tag the championship.

final class CanModeratePlanningFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  CanModeratePlanningFamily._()
    : super(
        retry: null,
        name: r'canModeratePlanningProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the user is [associationId]'s local manager or a super_admin --
  /// the same people who tag the championship.

  CanModeratePlanningProvider call(String associationId) =>
      CanModeratePlanningProvider._(argument: associationId, from: this);

  @override
  String toString() => r'canModeratePlanningProvider';
}

@ProviderFor(eventRights)
final eventRightsProvider = EventRightsFamily._();

final class EventRightsProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventRights>,
          EventRights,
          FutureOr<EventRights>
        >
    with $FutureModifier<EventRights>, $FutureProvider<EventRights> {
  EventRightsProvider._({
    required EventRightsFamily super.from,
    required Event super.argument,
  }) : super(
         retry: null,
         name: r'eventRightsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventRightsHash();

  @override
  String toString() {
    return r'eventRightsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<EventRights> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EventRights> create(Ref ref) {
    final argument = this.argument as Event;
    return eventRights(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventRightsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventRightsHash() => r'385df01f5a8d744dd98a791a40948e30cb6a908d';

final class EventRightsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<EventRights>, Event> {
  EventRightsFamily._()
    : super(
        retry: null,
        name: r'eventRightsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventRightsProvider call(Event event) =>
      EventRightsProvider._(argument: event, from: this);

  @override
  String toString() => r'eventRightsProvider';
}
