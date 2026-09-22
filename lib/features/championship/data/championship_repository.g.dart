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

@ProviderFor(championshipZoneLabel)
final championshipZoneLabelProvider = ChampionshipZoneLabelFamily._();

final class ChampionshipZoneLabelProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  ChampionshipZoneLabelProvider._({
    required ChampionshipZoneLabelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'championshipZoneLabelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$championshipZoneLabelHash();

  @override
  String toString() {
    return r'championshipZoneLabelProvider'
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
    return championshipZoneLabel(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChampionshipZoneLabelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$championshipZoneLabelHash() =>
    r'ae468bfe0623ddc33d39c40cb05a617fba09be98';

final class ChampionshipZoneLabelFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  ChampionshipZoneLabelFamily._()
    : super(
        retry: null,
        name: r'championshipZoneLabelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChampionshipZoneLabelProvider call(String zoneId) =>
      ChampionshipZoneLabelProvider._(argument: zoneId, from: this);

  @override
  String toString() => r'championshipZoneLabelProvider';
}

@ProviderFor(championshipZoneStandings)
final championshipZoneStandingsProvider = ChampionshipZoneStandingsFamily._();

final class ChampionshipZoneStandingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PlayerStanding>>,
          List<PlayerStanding>,
          FutureOr<List<PlayerStanding>>
        >
    with
        $FutureModifier<List<PlayerStanding>>,
        $FutureProvider<List<PlayerStanding>> {
  ChampionshipZoneStandingsProvider._({
    required ChampionshipZoneStandingsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'championshipZoneStandingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$championshipZoneStandingsHash();

  @override
  String toString() {
    return r'championshipZoneStandingsProvider'
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
    return championshipZoneStandings(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ChampionshipZoneStandingsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$championshipZoneStandingsHash() =>
    r'0935bd4edd37403fa5974a424476be9f97f9a955';

final class ChampionshipZoneStandingsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PlayerStanding>>,
          (String, String)
        > {
  ChampionshipZoneStandingsFamily._()
    : super(
        retry: null,
        name: r'championshipZoneStandingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChampionshipZoneStandingsProvider call(String zoneId, String season) =>
      ChampionshipZoneStandingsProvider._(
        argument: (zoneId, season),
        from: this,
      );

  @override
  String toString() => r'championshipZoneStandingsProvider';
}
