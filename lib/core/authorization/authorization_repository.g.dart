// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authorization_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myAppRole)
final myAppRoleProvider = MyAppRoleProvider._();

final class MyAppRoleProvider
    extends $FunctionalProvider<AsyncValue<AppRole>, AppRole, FutureOr<AppRole>>
    with $FutureModifier<AppRole>, $FutureProvider<AppRole> {
  MyAppRoleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myAppRoleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myAppRoleHash();

  @$internal
  @override
  $FutureProviderElement<AppRole> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AppRole> create(Ref ref) {
    return myAppRole(ref);
  }
}

String _$myAppRoleHash() => r'75b2946154a03b4c8d1d7b30e2a6f03dee39c5dd';

@ProviderFor(isSuperAdmin)
final isSuperAdminProvider = IsSuperAdminProvider._();

final class IsSuperAdminProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  IsSuperAdminProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isSuperAdminProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isSuperAdminHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isSuperAdmin(ref);
  }
}

String _$isSuperAdminHash() => r'2fff56c66389b94c078409584e1c49ce44726b13';
