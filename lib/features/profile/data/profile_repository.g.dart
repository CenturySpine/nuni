// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myProfile)
final myProfileProvider = MyProfileProvider._();

final class MyProfileProvider
    extends $FunctionalProvider<AsyncValue<Profile>, Profile, FutureOr<Profile>>
    with $FutureModifier<Profile>, $FutureProvider<Profile> {
  MyProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myProfileHash();

  @$internal
  @override
  $FutureProviderElement<Profile> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Profile> create(Ref ref) {
    return myProfile(ref);
  }
}

String _$myProfileHash() => r'fb379b464a178b8d05f798d0296a91bed9b9c219';

@ProviderFor(myPlayer)
final myPlayerProvider = MyPlayerProvider._();

final class MyPlayerProvider
    extends $FunctionalProvider<AsyncValue<Player>, Player, FutureOr<Player>>
    with $FutureModifier<Player>, $FutureProvider<Player> {
  MyPlayerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myPlayerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myPlayerHash();

  @$internal
  @override
  $FutureProviderElement<Player> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Player> create(Ref ref) {
    return myPlayer(ref);
  }
}

String _$myPlayerHash() => r'fa3c9ac1c90cf7d75c4abebdaa84ef32674eff00';
