// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'championship_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myChampionshipMemberships)
final myChampionshipMembershipsProvider = MyChampionshipMembershipsProvider._();

final class MyChampionshipMembershipsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChampionshipMembership>>,
          List<ChampionshipMembership>,
          FutureOr<List<ChampionshipMembership>>
        >
    with
        $FutureModifier<List<ChampionshipMembership>>,
        $FutureProvider<List<ChampionshipMembership>> {
  MyChampionshipMembershipsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myChampionshipMembershipsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myChampionshipMembershipsHash();

  @$internal
  @override
  $FutureProviderElement<List<ChampionshipMembership>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ChampionshipMembership>> create(Ref ref) {
    return myChampionshipMemberships(ref);
  }
}

String _$myChampionshipMembershipsHash() =>
    r'dc1d3c44647610659d5d2df843c006c8801ad77b';

/// A championship's name (plan 18, Q77): its association's abbreviation, or
/// its name when it has none.

@ProviderFor(championshipAssociationLabel)
final championshipAssociationLabelProvider =
    ChampionshipAssociationLabelFamily._();

/// A championship's name (plan 18, Q77): its association's abbreviation, or
/// its name when it has none.

final class ChampionshipAssociationLabelProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// A championship's name (plan 18, Q77): its association's abbreviation, or
  /// its name when it has none.
  ChampionshipAssociationLabelProvider._({
    required ChampionshipAssociationLabelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'championshipAssociationLabelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$championshipAssociationLabelHash();

  @override
  String toString() {
    return r'championshipAssociationLabelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return championshipAssociationLabel(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChampionshipAssociationLabelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$championshipAssociationLabelHash() =>
    r'57d15ae2d8432af4bc4f9f78f218824123f667e5';

/// A championship's name (plan 18, Q77): its association's abbreviation, or
/// its name when it has none.

final class ChampionshipAssociationLabelFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  ChampionshipAssociationLabelFamily._()
    : super(
        retry: null,
        name: r'championshipAssociationLabelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A championship's name (plan 18, Q77): its association's abbreviation, or
  /// its name when it has none.

  ChampionshipAssociationLabelProvider call(String associationId) =>
      ChampionshipAssociationLabelProvider._(
        argument: associationId,
        from: this,
      );

  @override
  String toString() => r'championshipAssociationLabelProvider';
}

@ProviderFor(championshipStandings)
final championshipStandingsProvider = ChampionshipStandingsFamily._();

final class ChampionshipStandingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PlayerStanding>>,
          List<PlayerStanding>,
          FutureOr<List<PlayerStanding>>
        >
    with
        $FutureModifier<List<PlayerStanding>>,
        $FutureProvider<List<PlayerStanding>> {
  ChampionshipStandingsProvider._({
    required ChampionshipStandingsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'championshipStandingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$championshipStandingsHash();

  @override
  String toString() {
    return r'championshipStandingsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<PlayerStanding>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PlayerStanding>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return championshipStandings(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ChampionshipStandingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$championshipStandingsHash() =>
    r'536e0dc12b63bca5f005f5bded354f708366145e';

final class ChampionshipStandingsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PlayerStanding>>,
          (String, String)
        > {
  ChampionshipStandingsFamily._()
    : super(
        retry: null,
        name: r'championshipStandingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChampionshipStandingsProvider call(String associationId, String season) =>
      ChampionshipStandingsProvider._(
        argument: (associationId, season),
        from: this,
      );

  @override
  String toString() => r'championshipStandingsProvider';
}
