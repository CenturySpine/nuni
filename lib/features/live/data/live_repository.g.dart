// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(liveSession)
final liveSessionProvider = LiveSessionFamily._();

final class LiveSessionProvider
    extends
        $FunctionalProvider<
          AsyncValue<LiveSessionSnapshot>,
          LiveSessionSnapshot,
          Stream<LiveSessionSnapshot>
        >
    with
        $FutureModifier<LiveSessionSnapshot>,
        $StreamProvider<LiveSessionSnapshot> {
  LiveSessionProvider._({
    required LiveSessionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'liveSessionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveSessionHash();

  @override
  String toString() {
    return r'liveSessionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<LiveSessionSnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<LiveSessionSnapshot> create(Ref ref) {
    final argument = this.argument as String;
    return liveSession(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LiveSessionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveSessionHash() => r'e18f5aa731676a1e2973cc3806868c4ea6aa91cd';

final class LiveSessionFamily extends $Family
    with $FunctionalFamilyOverride<Stream<LiveSessionSnapshot>, String> {
  LiveSessionFamily._()
    : super(
        retry: null,
        name: r'liveSessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LiveSessionProvider call(String sessionId) =>
      LiveSessionProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'liveSessionProvider';
}
