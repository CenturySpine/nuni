// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'championship_rights.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the signed-in user may tag or untag a session of
/// [associationId] for the championship (plan 26, decision 11): a
/// super_admin, or that association's approved local manager. Only decides
/// what the app shows -- the `set_session_championship` RPC enforces it.

@ProviderFor(canTagChampionship)
final canTagChampionshipProvider = CanTagChampionshipFamily._();

/// Whether the signed-in user may tag or untag a session of
/// [associationId] for the championship (plan 26, decision 11): a
/// super_admin, or that association's approved local manager. Only decides
/// what the app shows -- the `set_session_championship` RPC enforces it.

final class CanTagChampionshipProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the signed-in user may tag or untag a session of
  /// [associationId] for the championship (plan 26, decision 11): a
  /// super_admin, or that association's approved local manager. Only decides
  /// what the app shows -- the `set_session_championship` RPC enforces it.
  CanTagChampionshipProvider._({
    required CanTagChampionshipFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'canTagChampionshipProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$canTagChampionshipHash();

  @override
  String toString() {
    return r'canTagChampionshipProvider'
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
    return canTagChampionship(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CanTagChampionshipProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$canTagChampionshipHash() =>
    r'8c7d9855093e65f999570ab869b988c2521026d7';

/// Whether the signed-in user may tag or untag a session of
/// [associationId] for the championship (plan 26, decision 11): a
/// super_admin, or that association's approved local manager. Only decides
/// what the app shows -- the `set_session_championship` RPC enforces it.

final class CanTagChampionshipFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  CanTagChampionshipFamily._()
    : super(
        retry: null,
        name: r'canTagChampionshipProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the signed-in user may tag or untag a session of
  /// [associationId] for the championship (plan 26, decision 11): a
  /// super_admin, or that association's approved local manager. Only decides
  /// what the app shows -- the `set_session_championship` RPC enforces it.

  CanTagChampionshipProvider call(String associationId) =>
      CanTagChampionshipProvider._(argument: associationId, from: this);

  @override
  String toString() => r'canTagChampionshipProvider';
}
