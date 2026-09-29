// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifications on this device (plan 33): the Settings switch, the
/// phone's permission window at the first touch (Q235), and this device's
/// subscription, kept in step with the account signed in and the app's
/// language.

@ProviderFor(NotificationsController)
final notificationsControllerProvider = NotificationsControllerProvider._();

/// Notifications on this device (plan 33): the Settings switch, the
/// phone's permission window at the first touch (Q235), and this device's
/// subscription, kept in step with the account signed in and the app's
/// language.
final class NotificationsControllerProvider
    extends $NotifierProvider<NotificationsController, NotificationsStatus> {
  /// Notifications on this device (plan 33): the Settings switch, the
  /// phone's permission window at the first touch (Q235), and this device's
  /// subscription, kept in step with the account signed in and the app's
  /// language.
  NotificationsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsControllerHash();

  @$internal
  @override
  NotificationsController create() => NotificationsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationsStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationsStatus>(value),
    );
  }
}

String _$notificationsControllerHash() =>
    r'905e8ad88945018c35497c096893affb45a1ef6f';

/// Notifications on this device (plan 33): the Settings switch, the
/// phone's permission window at the first touch (Q235), and this device's
/// subscription, kept in step with the account signed in and the app's
/// language.

abstract class _$NotificationsController
    extends $Notifier<NotificationsStatus> {
  NotificationsStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NotificationsStatus, NotificationsStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotificationsStatus, NotificationsStatus>,
              NotificationsStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
