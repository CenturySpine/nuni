// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'association_rights.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the signed-in user runs [associationId] day to day (plan 27): a
/// super_admin, its approved local manager, or one of its local admins --
/// championship tagging and the planning's moderation, import and "start
/// the session". Editing the association itself stays the manager's and the
/// super_admin's. Only decides what the app shows: the base's
/// `is_association_staff` enforces the same rule.

@ProviderFor(canManageAssociation)
final canManageAssociationProvider = CanManageAssociationFamily._();

/// Whether the signed-in user runs [associationId] day to day (plan 27): a
/// super_admin, its approved local manager, or one of its local admins --
/// championship tagging and the planning's moderation, import and "start
/// the session". Editing the association itself stays the manager's and the
/// super_admin's. Only decides what the app shows: the base's
/// `is_association_staff` enforces the same rule.

final class CanManageAssociationProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the signed-in user runs [associationId] day to day (plan 27): a
  /// super_admin, its approved local manager, or one of its local admins --
  /// championship tagging and the planning's moderation, import and "start
  /// the session". Editing the association itself stays the manager's and the
  /// super_admin's. Only decides what the app shows: the base's
  /// `is_association_staff` enforces the same rule.
  CanManageAssociationProvider._({
    required CanManageAssociationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'canManageAssociationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$canManageAssociationHash();

  @override
  String toString() {
    return r'canManageAssociationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return canManageAssociation(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CanManageAssociationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$canManageAssociationHash() =>
    r'4c36de99990a3f03057af30616c72065db05b444';

/// Whether the signed-in user runs [associationId] day to day (plan 27): a
/// super_admin, its approved local manager, or one of its local admins --
/// championship tagging and the planning's moderation, import and "start
/// the session". Editing the association itself stays the manager's and the
/// super_admin's. Only decides what the app shows: the base's
/// `is_association_staff` enforces the same rule.

final class CanManageAssociationFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  CanManageAssociationFamily._()
    : super(
        retry: null,
        name: r'canManageAssociationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the signed-in user runs [associationId] day to day (plan 27): a
  /// super_admin, its approved local manager, or one of its local admins --
  /// championship tagging and the planning's moderation, import and "start
  /// the session". Editing the association itself stays the manager's and the
  /// super_admin's. Only decides what the app shows: the base's
  /// `is_association_staff` enforces the same rule.

  CanManageAssociationProvider call(String associationId) =>
      CanManageAssociationProvider._(argument: associationId, from: this);

  @override
  String toString() => r'canManageAssociationProvider';
}
