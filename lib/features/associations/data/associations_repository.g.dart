// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'associations_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(associations)
final associationsProvider = AssociationsProvider._();

final class AssociationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Association>>,
          List<Association>,
          FutureOr<List<Association>>
        >
    with
        $FutureModifier<List<Association>>,
        $FutureProvider<List<Association>> {
  AssociationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'associationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$associationsHash();

  @$internal
  @override
  $FutureProviderElement<List<Association>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Association>> create(Ref ref) {
    return associations(ref);
  }
}

String _$associationsHash() => r'a002c2bcebb36877aacc7c7e7b6bad6b0e10d211';

@ProviderFor(associationManagers)
final associationManagersProvider = AssociationManagersProvider._();

final class AssociationManagersProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, ManagerSummary>>,
          Map<String, ManagerSummary>,
          FutureOr<Map<String, ManagerSummary>>
        >
    with
        $FutureModifier<Map<String, ManagerSummary>>,
        $FutureProvider<Map<String, ManagerSummary>> {
  AssociationManagersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'associationManagersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$associationManagersHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, ManagerSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, ManagerSummary>> create(Ref ref) {
    return associationManagers(ref);
  }
}

String _$associationManagersHash() =>
    r'7d5853af6f1c6dfead58ad241c75c00b0f29cbf5';

@ProviderFor(associationAdmins)
final associationAdminsProvider = AssociationAdminsProvider._();

final class AssociationAdminsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, Set<String>>>,
          Map<String, Set<String>>,
          FutureOr<Map<String, Set<String>>>
        >
    with
        $FutureModifier<Map<String, Set<String>>>,
        $FutureProvider<Map<String, Set<String>>> {
  AssociationAdminsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'associationAdminsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$associationAdminsHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, Set<String>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, Set<String>>> create(Ref ref) {
    return associationAdmins(ref);
  }
}

String _$associationAdminsHash() => r'16d64a9b65065288a5a46582c976f41001517161';

@ProviderFor(myManagerRows)
final myManagerRowsProvider = MyManagerRowsProvider._();

final class MyManagerRowsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AssociationManager>>,
          List<AssociationManager>,
          FutureOr<List<AssociationManager>>
        >
    with
        $FutureModifier<List<AssociationManager>>,
        $FutureProvider<List<AssociationManager>> {
  MyManagerRowsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myManagerRowsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myManagerRowsHash();

  @$internal
  @override
  $FutureProviderElement<List<AssociationManager>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AssociationManager>> create(Ref ref) {
    return myManagerRows(ref);
  }
}

String _$myManagerRowsHash() => r'49d158437f71fdfb9c7a2e1bbb3b3eac623a52be';

@ProviderFor(pendingRequests)
final pendingRequestsProvider = PendingRequestsProvider._();

final class PendingRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PendingRequest>>,
          List<PendingRequest>,
          FutureOr<List<PendingRequest>>
        >
    with
        $FutureModifier<List<PendingRequest>>,
        $FutureProvider<List<PendingRequest>> {
  PendingRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingRequestsHash();

  @$internal
  @override
  $FutureProviderElement<List<PendingRequest>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PendingRequest>> create(Ref ref) {
    return pendingRequests(ref);
  }
}

String _$pendingRequestsHash() => r'f9fc00134f67cab640b3d086c13fd8dc3ba0a1e3';

/// One association by id among those I can see, or null.

@ProviderFor(associationById)
final associationByIdProvider = AssociationByIdFamily._();

/// One association by id among those I can see, or null.

final class AssociationByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<Association?>,
          Association?,
          FutureOr<Association?>
        >
    with $FutureModifier<Association?>, $FutureProvider<Association?> {
  /// One association by id among those I can see, or null.
  AssociationByIdProvider._({
    required AssociationByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'associationByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$associationByIdHash();

  @override
  String toString() {
    return r'associationByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Association?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Association?> create(Ref ref) {
    final argument = this.argument as String;
    return associationById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AssociationByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$associationByIdHash() => r'86ce6c3624d6a751518a0feab573581a89559510';

/// One association by id among those I can see, or null.

final class AssociationByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Association?>, String> {
  AssociationByIdFamily._()
    : super(
        retry: null,
        name: r'associationByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One association by id among those I can see, or null.

  AssociationByIdProvider call(String id) =>
      AssociationByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'associationByIdProvider';
}

/// My creation request still awaiting review, if any (Q81).

@ProviderFor(myPendingRequest)
final myPendingRequestProvider = MyPendingRequestProvider._();

/// My creation request still awaiting review, if any (Q81).

final class MyPendingRequestProvider
    extends
        $FunctionalProvider<
          AsyncValue<Association?>,
          Association?,
          FutureOr<Association?>
        >
    with $FutureModifier<Association?>, $FutureProvider<Association?> {
  /// My creation request still awaiting review, if any (Q81).
  MyPendingRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myPendingRequestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myPendingRequestHash();

  @$internal
  @override
  $FutureProviderElement<Association?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Association?> create(Ref ref) {
    return myPendingRequest(ref);
  }
}

String _$myPendingRequestHash() => r'51758137876e25bef37b9c804ec2e85f10addffa';
