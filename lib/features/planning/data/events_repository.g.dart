// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// My association's planning, or an empty list without an association.

@ProviderFor(myPlanning)
final myPlanningProvider = MyPlanningProvider._();

/// My association's planning, or an empty list without an association.

final class MyPlanningProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Event>>,
          List<Event>,
          FutureOr<List<Event>>
        >
    with $FutureModifier<List<Event>>, $FutureProvider<List<Event>> {
  /// My association's planning, or an empty list without an association.
  MyPlanningProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myPlanningProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myPlanningHash();

  @$internal
  @override
  $FutureProviderElement<List<Event>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Event>> create(Ref ref) {
    return myPlanning(ref);
  }
}

String _$myPlanningHash() => r'9aa90fbc1ad7f54fa5bef0bfb33968e0416b70b4';

@ProviderFor(eventById)
final eventByIdProvider = EventByIdFamily._();

final class EventByIdProvider
    extends $FunctionalProvider<AsyncValue<Event?>, Event?, FutureOr<Event?>>
    with $FutureModifier<Event?>, $FutureProvider<Event?> {
  EventByIdProvider._({
    required EventByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventByIdHash();

  @override
  String toString() {
    return r'eventByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Event?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Event?> create(Ref ref) {
    final argument = this.argument as String;
    return eventById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventByIdHash() => r'ab061904800e5e975586c063d0cb01e339b983ec';

final class EventByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Event?>, String> {
  EventByIdFamily._()
    : super(
        retry: null,
        name: r'eventByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventByIdProvider call(String id) =>
      EventByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'eventByIdProvider';
}

@ProviderFor(eventComments)
final eventCommentsProvider = EventCommentsFamily._();

final class EventCommentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventComment>>,
          List<EventComment>,
          Stream<List<EventComment>>
        >
    with
        $FutureModifier<List<EventComment>>,
        $StreamProvider<List<EventComment>> {
  EventCommentsProvider._({
    required EventCommentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventCommentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventCommentsHash();

  @override
  String toString() {
    return r'eventCommentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<EventComment>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<EventComment>> create(Ref ref) {
    final argument = this.argument as String;
    return eventComments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventCommentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventCommentsHash() => r'55271f57a888ca46eea7f9c8208a70cc9632e3d0';

final class EventCommentsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<EventComment>>, String> {
  EventCommentsFamily._()
    : super(
        retry: null,
        name: r'eventCommentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventCommentsProvider call(String eventId) =>
      EventCommentsProvider._(argument: eventId, from: this);

  @override
  String toString() => r'eventCommentsProvider';
}

@ProviderFor(eventSessions)
final eventSessionsProvider = EventSessionsFamily._();

final class EventSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Session>>,
          List<Session>,
          FutureOr<List<Session>>
        >
    with $FutureModifier<List<Session>>, $FutureProvider<List<Session>> {
  EventSessionsProvider._({
    required EventSessionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventSessionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventSessionsHash();

  @override
  String toString() {
    return r'eventSessionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Session>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Session>> create(Ref ref) {
    final argument = this.argument as String;
    return eventSessions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventSessionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventSessionsHash() => r'ffb9d7f588619f35e7db0eff27bd9e5066e402da';

final class EventSessionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Session>>, String> {
  EventSessionsFamily._()
    : super(
        retry: null,
        name: r'eventSessionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventSessionsProvider call(String eventId) =>
      EventSessionsProvider._(argument: eventId, from: this);

  @override
  String toString() => r'eventSessionsProvider';
}

@ProviderFor(eventLabelSuggestions)
final eventLabelSuggestionsProvider = EventLabelSuggestionsFamily._();

final class EventLabelSuggestionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  EventLabelSuggestionsProvider._({
    required EventLabelSuggestionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventLabelSuggestionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventLabelSuggestionsHash();

  @override
  String toString() {
    return r'eventLabelSuggestionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as String;
    return eventLabelSuggestions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventLabelSuggestionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventLabelSuggestionsHash() =>
    r'1dcefd9d10717004f6bf51743672e9863a4b4fda';

final class EventLabelSuggestionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>>, String> {
  EventLabelSuggestionsFamily._()
    : super(
        retry: null,
        name: r'eventLabelSuggestionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventLabelSuggestionsProvider call(String associationId) =>
      EventLabelSuggestionsProvider._(argument: associationId, from: this);

  @override
  String toString() => r'eventLabelSuggestionsProvider';
}
