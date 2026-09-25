// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spots_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(associationSpots)
final associationSpotsProvider = AssociationSpotsFamily._();

final class AssociationSpotsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Spot>>,
          List<Spot>,
          FutureOr<List<Spot>>
        >
    with $FutureModifier<List<Spot>>, $FutureProvider<List<Spot>> {
  AssociationSpotsProvider._({
    required AssociationSpotsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'associationSpotsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$associationSpotsHash();

  @override
  String toString() {
    return r'associationSpotsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Spot>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Spot>> create(Ref ref) {
    final argument = this.argument as String;
    return associationSpots(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AssociationSpotsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$associationSpotsHash() => r'7780f91551a4f5469aad058584fde986756ce0ef';

final class AssociationSpotsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Spot>>, String> {
  AssociationSpotsFamily._()
    : super(
        retry: null,
        name: r'associationSpotsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AssociationSpotsProvider call(String associationId) =>
      AssociationSpotsProvider._(argument: associationId, from: this);

  @override
  String toString() => r'associationSpotsProvider';
}
