// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holes_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myPosition)
final myPositionProvider = MyPositionProvider._();

final class MyPositionProvider
    extends
        $FunctionalProvider<
          AsyncValue<Position?>,
          Position?,
          FutureOr<Position?>
        >
    with $FutureModifier<Position?>, $FutureProvider<Position?> {
  MyPositionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myPositionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myPositionHash();

  @$internal
  @override
  $FutureProviderElement<Position?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Position?> create(Ref ref) {
    return myPosition(ref);
  }
}

String _$myPositionHash() => r'7c3bf115ce74835105934b63b51bb5c20ce7b3f8';

@ProviderFor(nearbyHoles)
final nearbyHolesProvider = NearbyHolesFamily._();

final class NearbyHolesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Hole>>,
          List<Hole>,
          FutureOr<List<Hole>>
        >
    with $FutureModifier<List<Hole>>, $FutureProvider<List<Hole>> {
  NearbyHolesProvider._({
    required NearbyHolesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'nearbyHolesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nearbyHolesHash();

  @override
  String toString() {
    return r'nearbyHolesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Hole>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Hole>> create(Ref ref) {
    final argument = this.argument as int;
    return nearbyHoles(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NearbyHolesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nearbyHolesHash() => r'b0b2b2f5f7987bf65f694d351ed86980b988efb0';

final class NearbyHolesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Hole>>, int> {
  NearbyHolesFamily._()
    : super(
        retry: null,
        name: r'nearbyHolesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NearbyHolesProvider call(int radiusM) =>
      NearbyHolesProvider._(argument: radiusM, from: this);

  @override
  String toString() => r'nearbyHolesProvider';
}

@ProviderFor(myHoles)
final myHolesProvider = MyHolesProvider._();

final class MyHolesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Hole>>,
          List<Hole>,
          FutureOr<List<Hole>>
        >
    with $FutureModifier<List<Hole>>, $FutureProvider<List<Hole>> {
  MyHolesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myHolesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myHolesHash();

  @$internal
  @override
  $FutureProviderElement<List<Hole>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Hole>> create(Ref ref) {
    return myHoles(ref);
  }
}

String _$myHolesHash() => r'f873931b1d75557cd24c007045d8b3f8430f6d48';

@ProviderFor(holeById)
final holeByIdProvider = HoleByIdFamily._();

final class HoleByIdProvider
    extends $FunctionalProvider<AsyncValue<Hole>, Hole, FutureOr<Hole>>
    with $FutureModifier<Hole>, $FutureProvider<Hole> {
  HoleByIdProvider._({
    required HoleByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'holeByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$holeByIdHash();

  @override
  String toString() {
    return r'holeByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Hole> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Hole> create(Ref ref) {
    final argument = this.argument as String;
    return holeById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HoleByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$holeByIdHash() => r'fef8c211e29e27feb1fcfb4c91fb3c401058aa14';

final class HoleByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Hole>, String> {
  HoleByIdFamily._()
    : super(
        retry: null,
        name: r'holeByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HoleByIdProvider call(String id) =>
      HoleByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'holeByIdProvider';
}

/// The last radius the user picked (device-local, `shared_preferences`),
/// falling back to [holesRadiusDefaultM] on first use.

@ProviderFor(HolesRadius)
final holesRadiusProvider = HolesRadiusProvider._();

/// The last radius the user picked (device-local, `shared_preferences`),
/// falling back to [holesRadiusDefaultM] on first use.
final class HolesRadiusProvider
    extends $AsyncNotifierProvider<HolesRadius, int> {
  /// The last radius the user picked (device-local, `shared_preferences`),
  /// falling back to [holesRadiusDefaultM] on first use.
  HolesRadiusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'holesRadiusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$holesRadiusHash();

  @$internal
  @override
  HolesRadius create() => HolesRadius();
}

String _$holesRadiusHash() => r'4a2bd972943f64f4e3b27272d6b4db7e9e9c1de7';

/// The last radius the user picked (device-local, `shared_preferences`),
/// falling back to [holesRadiusDefaultM] on first use.

abstract class _$HolesRadius extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
