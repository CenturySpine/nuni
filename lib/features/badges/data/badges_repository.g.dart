// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badges_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What [playerId]'s account added to the app (plan 21, family H), whoever
/// asks; empty for a player without an account.

@ProviderFor(playerContributions)
final playerContributionsProvider = PlayerContributionsFamily._();

/// What [playerId]'s account added to the app (plan 21, family H), whoever
/// asks; empty for a player without an account.

final class PlayerContributionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlayerContributions>,
          PlayerContributions,
          FutureOr<PlayerContributions>
        >
    with
        $FutureModifier<PlayerContributions>,
        $FutureProvider<PlayerContributions> {
  /// What [playerId]'s account added to the app (plan 21, family H), whoever
  /// asks; empty for a player without an account.
  PlayerContributionsProvider._({
    required PlayerContributionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'playerContributionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playerContributionsHash();

  @override
  String toString() {
    return r'playerContributionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PlayerContributions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PlayerContributions> create(Ref ref) {
    final argument = this.argument as String;
    return playerContributions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerContributionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playerContributionsHash() =>
    r'ae78200bc48e6370fa8ce4e8b0332f49ed4963f6';

/// What [playerId]'s account added to the app (plan 21, family H), whoever
/// asks; empty for a player without an account.

final class PlayerContributionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PlayerContributions>, String> {
  PlayerContributionsFamily._()
    : super(
        retry: null,
        name: r'playerContributionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What [playerId]'s account added to the app (plan 21, family H), whoever
  /// asks; empty for a player without an account.

  PlayerContributionsProvider call(String playerId) =>
      PlayerContributionsProvider._(argument: playerId, from: this);

  @override
  String toString() => r'playerContributionsProvider';
}

/// A player's badges (plan 21), recomputed from what is already readable:
/// their history (`player_history`, plan 19), what their account added
/// (`player_contributions`), the history of every hole they played or own
/// (`holes_history`, for H3 and the records) and, for E3 to E5, the
/// classement of every finished championship season they played in. No
/// badge is stored (decision 8). Hiding badges is a display choice only
/// (Q133): this never looks at `badges_public`.

@ProviderFor(playerBadges)
final playerBadgesProvider = PlayerBadgesFamily._();

/// A player's badges (plan 21), recomputed from what is already readable:
/// their history (`player_history`, plan 19), what their account added
/// (`player_contributions`), the history of every hole they played or own
/// (`holes_history`, for H3 and the records) and, for E3 to E5, the
/// classement of every finished championship season they played in. No
/// badge is stored (decision 8). Hiding badges is a display choice only
/// (Q133): this never looks at `badges_public`.

final class PlayerBadgesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BadgeResult>>,
          List<BadgeResult>,
          FutureOr<List<BadgeResult>>
        >
    with
        $FutureModifier<List<BadgeResult>>,
        $FutureProvider<List<BadgeResult>> {
  /// A player's badges (plan 21), recomputed from what is already readable:
  /// their history (`player_history`, plan 19), what their account added
  /// (`player_contributions`), the history of every hole they played or own
  /// (`holes_history`, for H3 and the records) and, for E3 to E5, the
  /// classement of every finished championship season they played in. No
  /// badge is stored (decision 8). Hiding badges is a display choice only
  /// (Q133): this never looks at `badges_public`.
  PlayerBadgesProvider._({
    required PlayerBadgesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'playerBadgesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playerBadgesHash();

  @override
  String toString() {
    return r'playerBadgesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<BadgeResult>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BadgeResult>> create(Ref ref) {
    final argument = this.argument as String;
    return playerBadges(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerBadgesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playerBadgesHash() => r'9396a7c0d4e8c9e6b94c6627860b45eba4ec228f';

/// A player's badges (plan 21), recomputed from what is already readable:
/// their history (`player_history`, plan 19), what their account added
/// (`player_contributions`), the history of every hole they played or own
/// (`holes_history`, for H3 and the records) and, for E3 to E5, the
/// classement of every finished championship season they played in. No
/// badge is stored (decision 8). Hiding badges is a display choice only
/// (Q133): this never looks at `badges_public`.

final class PlayerBadgesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<BadgeResult>>, String> {
  PlayerBadgesFamily._()
    : super(
        retry: null,
        name: r'playerBadgesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A player's badges (plan 21), recomputed from what is already readable:
  /// their history (`player_history`, plan 19), what their account added
  /// (`player_contributions`), the history of every hole they played or own
  /// (`holes_history`, for H3 and the records) and, for E3 to E5, the
  /// classement of every finished championship season they played in. No
  /// badge is stored (decision 8). Hiding badges is a display choice only
  /// (Q133): this never looks at `badges_public`.

  PlayerBadgesProvider call(String playerId) =>
      PlayerBadgesProvider._(argument: playerId, from: this);

  @override
  String toString() => r'playerBadgesProvider';
}

/// My own badges, for announcing new ones (plan 21): null until I have
/// chosen an association (plan 18), so nothing is announced over the
/// association choice of a first sign-in.

@ProviderFor(myBadges)
final myBadgesProvider = MyBadgesProvider._();

/// My own badges, for announcing new ones (plan 21): null until I have
/// chosen an association (plan 18), so nothing is announced over the
/// association choice of a first sign-in.

final class MyBadgesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BadgeResult>?>,
          List<BadgeResult>?,
          FutureOr<List<BadgeResult>?>
        >
    with
        $FutureModifier<List<BadgeResult>?>,
        $FutureProvider<List<BadgeResult>?> {
  /// My own badges, for announcing new ones (plan 21): null until I have
  /// chosen an association (plan 18), so nothing is announced over the
  /// association choice of a first sign-in.
  MyBadgesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myBadgesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myBadgesHash();

  @$internal
  @override
  $FutureProviderElement<List<BadgeResult>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BadgeResult>?> create(Ref ref) {
    return myBadges(ref);
  }
}

String _$myBadgesHash() => r'1a2aab55e22586971ad4b915e5323d0042915d40';

/// The badges already seen in my badges section when the app started: read
/// once and kept, so the "New" marks survive the section being rebuilt
/// while it marks them seen for next time.

@ProviderFor(viewedBadgesAtStart)
final viewedBadgesAtStartProvider = ViewedBadgesAtStartFamily._();

/// The badges already seen in my badges section when the app started: read
/// once and kept, so the "New" marks survive the section being rebuilt
/// while it marks them seen for next time.

final class ViewedBadgesAtStartProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<BadgeId>>,
          Set<BadgeId>,
          FutureOr<Set<BadgeId>>
        >
    with $FutureModifier<Set<BadgeId>>, $FutureProvider<Set<BadgeId>> {
  /// The badges already seen in my badges section when the app started: read
  /// once and kept, so the "New" marks survive the section being rebuilt
  /// while it marks them seen for next time.
  ViewedBadgesAtStartProvider._({
    required ViewedBadgesAtStartFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'viewedBadgesAtStartProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$viewedBadgesAtStartHash();

  @override
  String toString() {
    return r'viewedBadgesAtStartProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Set<BadgeId>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<BadgeId>> create(Ref ref) {
    final argument = this.argument as String;
    return viewedBadgesAtStart(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ViewedBadgesAtStartProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$viewedBadgesAtStartHash() =>
    r'9ed2b65180db88b3779fe5699032382620242e92';

/// The badges already seen in my badges section when the app started: read
/// once and kept, so the "New" marks survive the section being rebuilt
/// while it marks them seen for next time.

final class ViewedBadgesAtStartFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Set<BadgeId>>, String> {
  ViewedBadgesAtStartFamily._()
    : super(
        retry: null,
        name: r'viewedBadgesAtStartProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// The badges already seen in my badges section when the app started: read
  /// once and kept, so the "New" marks survive the section being rebuilt
  /// while it marks them seen for next time.

  ViewedBadgesAtStartProvider call(String userId) =>
      ViewedBadgesAtStartProvider._(argument: userId, from: this);

  @override
  String toString() => r'viewedBadgesAtStartProvider';
}
