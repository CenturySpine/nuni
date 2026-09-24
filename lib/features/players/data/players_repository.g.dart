// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'players_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(playerById)
final playerByIdProvider = PlayerByIdFamily._();

final class PlayerByIdProvider
    extends $FunctionalProvider<AsyncValue<Player?>, Player?, FutureOr<Player?>>
    with $FutureModifier<Player?>, $FutureProvider<Player?> {
  PlayerByIdProvider._({
    required PlayerByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'playerByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playerByIdHash();

  @override
  String toString() {
    return r'playerByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Player?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Player?> create(Ref ref) {
    final argument = this.argument as String;
    return playerById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playerByIdHash() => r'3c64a201f385c9e99805dca7ec2a76dc07cc74eb';

final class PlayerByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Player?>, String> {
  PlayerByIdFamily._()
    : super(
        retry: null,
        name: r'playerByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlayerByIdProvider call(String id) =>
      PlayerByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'playerByIdProvider';
}
