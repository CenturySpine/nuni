// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A player's sessions, reloaded on every visit (auto-disposed) so a session
/// completed in between is counted. The statistics themselves are computed
/// from it per season choice (`computePlayerStats`, a few milliseconds).

@ProviderFor(playerHistory)
final playerHistoryProvider = PlayerHistoryFamily._();

/// A player's sessions, reloaded on every visit (auto-disposed) so a session
/// completed in between is counted. The statistics themselves are computed
/// from it per season choice (`computePlayerStats`, a few milliseconds).

final class PlayerHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LiveSessionSnapshot>>,
          List<LiveSessionSnapshot>,
          FutureOr<List<LiveSessionSnapshot>>
        >
    with
        $FutureModifier<List<LiveSessionSnapshot>>,
        $FutureProvider<List<LiveSessionSnapshot>> {
  /// A player's sessions, reloaded on every visit (auto-disposed) so a session
  /// completed in between is counted. The statistics themselves are computed
  /// from it per season choice (`computePlayerStats`, a few milliseconds).
  PlayerHistoryProvider._({
    required PlayerHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'playerHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playerHistoryHash();

  @override
  String toString() {
    return r'playerHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<LiveSessionSnapshot>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LiveSessionSnapshot>> create(Ref ref) {
    final argument = this.argument as String;
    return playerHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playerHistoryHash() => r'01d41b5c1cfa46d9d8231d68239654300fce89b9';

/// A player's sessions, reloaded on every visit (auto-disposed) so a session
/// completed in between is counted. The statistics themselves are computed
/// from it per season choice (`computePlayerStats`, a few milliseconds).

final class PlayerHistoryFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<LiveSessionSnapshot>>, String> {
  PlayerHistoryFamily._()
    : super(
        retry: null,
        name: r'playerHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A player's sessions, reloaded on every visit (auto-disposed) so a session
  /// completed in between is counted. The statistics themselves are computed
  /// from it per season choice (`computePlayerStats`, a few milliseconds).

  PlayerHistoryProvider call(String playerId) =>
      PlayerHistoryProvider._(argument: playerId, from: this);

  @override
  String toString() => r'playerHistoryProvider';
}
