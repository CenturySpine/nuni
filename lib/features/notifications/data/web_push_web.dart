import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../domain/notifications_status.dart';
import 'push_subscription_keys.dart';

// Every call is guarded: a browser without some part of the Push API, or a
// refusal from its push service, means "no notifications", never a crash.

PushPermission pushPermission() {
  try {
    if (_isIos && !_isStandalone) return PushPermission.needsInstall;
    final navigator = globalContext['navigator'] as JSObject?;
    final supported =
        globalContext.has('Notification') &&
        globalContext.has('PushManager') &&
        navigator != null &&
        navigator.has('serviceWorker');
    if (!supported) return PushPermission.unsupported;
    return _permissionFrom(web.Notification.permission);
  } catch (_) {
    return PushPermission.unsupported;
  }
}

/// Brings up the phone's "Allow / Don't allow" window. Only works right
/// after a touch in the app (browsers require it).
Future<PushPermission> requestPushPermission() async {
  try {
    final answer = await web.Notification.requestPermission().toDart;
    return _permissionFrom(answer.toDart);
  } catch (_) {
    return pushPermission();
  }
}

/// This device's subscription, created if needed with NUNI's public key.
Future<PushSubscriptionKeys?> subscribePush(String vapidPublicKey) async {
  try {
    final manager = (await _registration()).pushManager;
    final subscription =
        await manager.getSubscription().toDart ??
        await manager
            .subscribe(
              web.PushSubscriptionOptionsInit(
                userVisibleOnly: true,
                applicationServerKey: _decodeBase64Url(vapidPublicKey).toJS,
              ),
            )
            .toDart;
    return _keysOf(subscription);
  } catch (_) {
    return null;
  }
}

Future<PushSubscriptionKeys?> currentPushSubscription() async {
  try {
    final subscription = await (await _registration()).pushManager
        .getSubscription()
        .toDart;
    return subscription == null ? null : _keysOf(subscription);
  } catch (_) {
    return null;
  }
}

Future<void> unsubscribePush() async {
  try {
    final subscription = await (await _registration()).pushManager
        .getSubscription()
        .toDart;
    await subscription?.unsubscribe().toDart;
  } catch (_) {
    // Nothing to undo.
  }
}

/// The in-app paths of the notifications touched while NUNI is open
/// (`nuni_sw.js` posts them instead of reloading the page).
Stream<String> notificationOpens() {
  final controller = StreamController<String>.broadcast();
  try {
    web.window.navigator.serviceWorker.addEventListener(
      'message',
      ((web.MessageEvent event) {
        final data = event.data.dartify();
        if (data is Map && data['type'] == 'nuni-open') {
          final path = data['path'];
          if (path is String && path.startsWith('/')) controller.add(path);
        }
      }).toJS,
    );
  } catch (_) {
    // No service worker: notifications can't be touched either.
  }
  return controller.stream;
}

// Registered by flutter_bootstrap.js before the app starts; bounded, since
// `ready` never completes when the registration failed.
Future<web.ServiceWorkerRegistration> _registration() => web
    .window
    .navigator
    .serviceWorker
    .ready
    .toDart
    .timeout(const Duration(seconds: 10));

PushPermission _permissionFrom(String value) => switch (value) {
  'granted' => PushPermission.granted,
  'denied' => PushPermission.denied,
  _ => PushPermission.prompt,
};

PushSubscriptionKeys? _keysOf(web.PushSubscription subscription) {
  final p256dh = subscription.getKey('p256dh');
  final auth = subscription.getKey('auth');
  if (p256dh == null || auth == null) return null;
  return PushSubscriptionKeys(
    endpoint: subscription.endpoint,
    p256dh: _encodeBase64Url(p256dh.toDart.asUint8List()),
    auth: _encodeBase64Url(auth.toDart.asUint8List()),
  );
}

String _encodeBase64Url(Uint8List bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

Uint8List _decodeBase64Url(String value) =>
    base64Url.decode(base64Url.normalize(value.trim()));

bool get _isIos {
  final navigator = web.window.navigator;
  final agent = navigator.userAgent;
  // iPadOS presents itself as a Mac, but a Mac has no touch screen.
  return RegExp('iPhone|iPad|iPod').hasMatch(agent) ||
      (agent.contains('Macintosh') && navigator.maxTouchPoints > 1);
}

bool get _isStandalone {
  if (web.window.matchMedia('(display-mode: standalone)').matches) {
    return true;
  }
  final navigator = globalContext['navigator'] as JSObject;
  return navigator['standalone'].dartify() == true;
}
