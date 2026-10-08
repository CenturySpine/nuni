// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show_other_sessions_pref.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// "Voir toutes les sessions" (plan 38, Q278): whether a super_admin's home
/// and history show their "Autres sessions" section -- one setting for both
/// pages, remembered on the device, like `LibreRankingDirectionPref`. On by
/// default.

@ProviderFor(ShowOtherSessionsPref)
final showOtherSessionsPrefProvider = ShowOtherSessionsPrefProvider._();

/// "Voir toutes les sessions" (plan 38, Q278): whether a super_admin's home
/// and history show their "Autres sessions" section -- one setting for both
/// pages, remembered on the device, like `LibreRankingDirectionPref`. On by
/// default.
final class ShowOtherSessionsPrefProvider
    extends $AsyncNotifierProvider<ShowOtherSessionsPref, bool> {
  /// "Voir toutes les sessions" (plan 38, Q278): whether a super_admin's home
  /// and history show their "Autres sessions" section -- one setting for both
  /// pages, remembered on the device, like `LibreRankingDirectionPref`. On by
  /// default.
  ShowOtherSessionsPrefProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showOtherSessionsPrefProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showOtherSessionsPrefHash();

  @$internal
  @override
  ShowOtherSessionsPref create() => ShowOtherSessionsPref();
}

String _$showOtherSessionsPrefHash() =>
    r'3fa7902a4d897168b4fd69ecc0f85c9b51e20477';

/// "Voir toutes les sessions" (plan 38, Q278): whether a super_admin's home
/// and history show their "Autres sessions" section -- one setting for both
/// pages, remembered on the device, like `LibreRankingDirectionPref`. On by
/// default.

abstract class _$ShowOtherSessionsPref extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
