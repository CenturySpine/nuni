// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'association_choice_skip_pref.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the association choice was put off on this device (Q146): the
/// choice is offered at first sign-in, never forced. Remembered on the
/// device -- same pattern as `LibreRankingDirectionPref` -- so a new device
/// offers it once more. Leaving an association sets it too, so the choice
/// doesn't come straight back. Kept alive: `skip` may be called from a page
/// nothing else watches it from.

@ProviderFor(AssociationChoiceSkipped)
final associationChoiceSkippedProvider = AssociationChoiceSkippedProvider._();

/// Whether the association choice was put off on this device (Q146): the
/// choice is offered at first sign-in, never forced. Remembered on the
/// device -- same pattern as `LibreRankingDirectionPref` -- so a new device
/// offers it once more. Leaving an association sets it too, so the choice
/// doesn't come straight back. Kept alive: `skip` may be called from a page
/// nothing else watches it from.
final class AssociationChoiceSkippedProvider
    extends $AsyncNotifierProvider<AssociationChoiceSkipped, bool> {
  /// Whether the association choice was put off on this device (Q146): the
  /// choice is offered at first sign-in, never forced. Remembered on the
  /// device -- same pattern as `LibreRankingDirectionPref` -- so a new device
  /// offers it once more. Leaving an association sets it too, so the choice
  /// doesn't come straight back. Kept alive: `skip` may be called from a page
  /// nothing else watches it from.
  AssociationChoiceSkippedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'associationChoiceSkippedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$associationChoiceSkippedHash();

  @$internal
  @override
  AssociationChoiceSkipped create() => AssociationChoiceSkipped();
}

String _$associationChoiceSkippedHash() =>
    r'54cac573cfb5f1408b9fcdbb9f9c6d842a3af4f3';

/// Whether the association choice was put off on this device (Q146): the
/// choice is offered at first sign-in, never forced. Remembered on the
/// device -- same pattern as `LibreRankingDirectionPref` -- so a new device
/// offers it once more. Leaving an association sets it too, so the choice
/// doesn't come straight back. Kept alive: `skip` may be called from a page
/// nothing else watches it from.

abstract class _$AssociationChoiceSkipped extends $AsyncNotifier<bool> {
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
