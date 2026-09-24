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

@ProviderFor(associationPlayers)
final associationPlayersProvider = AssociationPlayersFamily._();

final class AssociationPlayersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Player>>,
          List<Player>,
          FutureOr<List<Player>>
        >
    with $FutureModifier<List<Player>>, $FutureProvider<List<Player>> {
  AssociationPlayersProvider._({
    required AssociationPlayersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'associationPlayersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$associationPlayersHash();

  @override
  String toString() {
    return r'associationPlayersProvider'
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
    return associationPlayers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AssociationPlayersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$associationPlayersHash() =>
    r'76b9c65d2d13d8bdb9db6a69ea3decb2f4cbd9f0';

final class AssociationPlayersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Player>>, String> {
  AssociationPlayersFamily._()
    : super(
        retry: null,
        name: r'associationPlayersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AssociationPlayersProvider call(String associationId) =>
      AssociationPlayersProvider._(argument: associationId, from: this);

  @override
  String toString() => r'associationPlayersProvider';
}
