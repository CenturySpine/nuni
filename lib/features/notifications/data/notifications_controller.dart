import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/notifications_status.dart';
import 'push_subscriptions_repository.dart';
import 'web_push.dart';

part 'notifications_controller.g.dart';

const _enabledKey = 'nuni.notifications.enabled';
const _askedKey = 'nuni.notifications.asked';

/// The public half of the notification keys (plan 33, docs/DEV.md), from
/// env/*.json like the Supabase keys. Empty = this build sends no
/// notifications, and the Settings switch says the browser can't.
const _vapidPublicKey = String.fromEnvironment('VAPID_PUBLIC_KEY');

/// The user's choices on this device, loaded once before the app starts
/// (see `main.dart`), like the language and the palette.
typedef NotificationPrefs = ({bool enabled, bool asked});

final persistedNotificationPrefsProvider = Provider<NotificationPrefs>(
  (ref) => (enabled: true, asked: false),
);

Future<NotificationPrefs> loadNotificationPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  return (
    // On by default (Q225).
    enabled: prefs.getBool(_enabledKey) ?? true,
    asked: prefs.getBool(_askedKey) ?? false,
  );
}

/// Notifications on this device (plan 33): the Settings switch, the
/// phone's permission window at the first touch (Q235), and this device's
/// subscription, kept in step with the account signed in and the app's
/// language.
@Riverpod(keepAlive: true)
class NotificationsController extends _$NotificationsController {
  late bool _enabled;
  late bool _asked;
  String? _locale;

  @override
  NotificationsStatus build() {
    final prefs = ref.watch(persistedNotificationPrefsProvider);
    _enabled = prefs.enabled;
    _asked = prefs.asked;
    return _status();
  }

  PushPermission get _permission =>
      _vapidPublicKey.isEmpty ? PushPermission.unsupported : pushPermission();

  NotificationsStatus _status() =>
      notificationsStatus(permission: _permission, enabled: _enabled);

  PushSubscriptionsRepository get _repository =>
      ref.read(pushSubscriptionsRepositoryProvider);

  /// Re-reads the browser's permission, which the user may have changed in
  /// the phone's settings while NUNI was in the background.
  void refresh() => state = _status();

  /// Called on every touch in the app; asks only once per device.
  Future<void> askOnFirstTouch() async {
    if (!shouldAskOnFirstTouch(
      permission: _permission,
      enabled: _enabled,
      alreadyAsked: _asked,
      signedIn: _repository.isSignedIn,
    )) {
      return;
    }
    _asked = true;
    // Asked before anything is awaited: the browser only shows its window
    // while the touch is fresh.
    final answer = requestPushPermission();
    await (await SharedPreferences.getInstance()).setBool(_askedKey, true);
    await answer;
    refresh();
    await sync();
  }

  /// The Settings switch turned on: brings up the phone's window if it was
  /// never answered (a touch, so the browser allows it).
  Future<void> turnOn() async {
    _enabled = true;
    if (_permission == PushPermission.prompt) {
      final answer = requestPushPermission();
      await _saveEnabled();
      await answer;
    } else {
      await _saveEnabled();
    }
    refresh();
    await sync();
  }

  Future<void> turnOff() async {
    _enabled = false;
    await _saveEnabled();
    refresh();
    final keys = await currentPushSubscription();
    if (keys != null) {
      await _forget(keys.endpoint);
      await unsubscribePush();
    }
  }

  /// Registers this device for the account signed in, in [locale] (the
  /// app's language, Q230) or the last one given. Does nothing unless
  /// notifications are on and allowed.
  Future<void> sync([String? locale]) async {
    _locale = locale ?? _locale;
    if (state != NotificationsStatus.on ||
        !_repository.isSignedIn ||
        _locale == null) {
      return;
    }
    final keys = await subscribePush(_vapidPublicKey);
    if (keys == null) return;
    try {
      await _repository.save(keys, _locale!);
    } catch (_) {
      // Retried at the next opening; a notification is a courtesy.
    }
  }

  /// Before signing out: the next account on this phone must not receive
  /// this one's notifications.
  Future<void> forgetDevice() async {
    final keys = await currentPushSubscription();
    if (keys != null) await _forget(keys.endpoint);
  }

  Future<void> _forget(String endpoint) async {
    try {
      await _repository.delete(endpoint);
    } catch (_) {
      // Signed out or offline: the server drops the row once the browser
      // reports the subscription gone.
    }
  }

  Future<void> _saveEnabled() async =>
      (await SharedPreferences.getInstance()).setBool(_enabledKey, _enabled);
}
