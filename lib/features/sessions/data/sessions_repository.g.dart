// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionRoom)
final sessionRoomProvider = SessionRoomFamily._();

final class SessionRoomProvider
    extends
        $FunctionalProvider<
          AsyncValue<SessionRoomSnapshot>,
          SessionRoomSnapshot,
          Stream<SessionRoomSnapshot>
        >
    with
        $FutureModifier<SessionRoomSnapshot>,
        $StreamProvider<SessionRoomSnapshot> {
  SessionRoomProvider._({
    required SessionRoomFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'sessionRoomProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionRoomHash();

  @override
  String toString() {
    return r'sessionRoomProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<SessionRoomSnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SessionRoomSnapshot> create(Ref ref) {
    final argument = this.argument as String;
    return sessionRoom(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionRoomProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionRoomHash() => r'8b1be76b08ef9b3decefcf6953e68e4a34a9b50b';

final class SessionRoomFamily extends $Family
    with $FunctionalFamilyOverride<Stream<SessionRoomSnapshot>, String> {
  SessionRoomFamily._()
    : super(
        retry: null,
        name: r'sessionRoomProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SessionRoomProvider call(String sessionId) =>
      SessionRoomProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionRoomProvider';
}

@ProviderFor(playerSearch)
final playerSearchProvider = PlayerSearchFamily._();

final class PlayerSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Player>>,
          List<Player>,
          FutureOr<List<Player>>
        >
    with $FutureModifier<List<Player>>, $FutureProvider<List<Player>> {
  PlayerSearchProvider._({
    required PlayerSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'playerSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playerSearchHash();

  @override
  String toString() {
    return r'playerSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Player>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Player>> create(Ref ref) {
    final argument = this.argument as String;
    return playerSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playerSearchHash() => r'7de94a5ac91de975b448f1e5ea939178d3e6ba7e';

final class PlayerSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Player>>, String> {
  PlayerSearchFamily._()
    : super(
        retry: null,
        name: r'playerSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlayerSearchProvider call(String query) =>
      PlayerSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'playerSearchProvider';
}

@ProviderFor(zoneSuggestions)
final zoneSuggestionsProvider = ZoneSuggestionsFamily._();

final class ZoneSuggestionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  ZoneSuggestionsProvider._({
    required ZoneSuggestionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'zoneSuggestionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$zoneSuggestionsHash();

  @override
  String toString() {
    return r'zoneSuggestionsProvider'
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
    return zoneSuggestions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ZoneSuggestionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$zoneSuggestionsHash() => r'0d9390a5e2c84a699a239ac1ee0bf8569cbab783';

final class ZoneSuggestionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>>, String> {
  ZoneSuggestionsFamily._()
    : super(
        retry: null,
        name: r'zoneSuggestionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ZoneSuggestionsProvider call(String city) =>
      ZoneSuggestionsProvider._(argument: city, from: this);

  @override
  String toString() => r'zoneSuggestionsProvider';
}

@ProviderFor(myOngoingSessions)
final myOngoingSessionsProvider = MyOngoingSessionsProvider._();

final class MyOngoingSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MySessionEntry>>,
          List<MySessionEntry>,
          FutureOr<List<MySessionEntry>>
        >
    with
        $FutureModifier<List<MySessionEntry>>,
        $FutureProvider<List<MySessionEntry>> {
  MyOngoingSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myOngoingSessionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myOngoingSessionsHash();

  @$internal
  @override
  $FutureProviderElement<List<MySessionEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MySessionEntry>> create(Ref ref) {
    return myOngoingSessions(ref);
  }
}

String _$myOngoingSessionsHash() => r'8ebd8b41b0062afa1d7d920cc26793faff9282ed';

@ProviderFor(myRecentSessions)
final myRecentSessionsProvider = MyRecentSessionsProvider._();

final class MyRecentSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MySessionEntry>>,
          List<MySessionEntry>,
          FutureOr<List<MySessionEntry>>
        >
    with
        $FutureModifier<List<MySessionEntry>>,
        $FutureProvider<List<MySessionEntry>> {
  MyRecentSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myRecentSessionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myRecentSessionsHash();

  @$internal
  @override
  $FutureProviderElement<List<MySessionEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MySessionEntry>> create(Ref ref) {
    return myRecentSessions(ref);
  }
}

String _$myRecentSessionsHash() => r'5265b7d1470f51c0b3dea8e4d559a26b83a3a235';
