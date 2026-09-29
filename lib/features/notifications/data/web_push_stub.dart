import '../domain/notifications_status.dart';
import 'push_subscription_keys.dart';

PushPermission pushPermission() => PushPermission.unsupported;

Future<PushPermission> requestPushPermission() async =>
    PushPermission.unsupported;

Future<PushSubscriptionKeys?> subscribePush(String vapidPublicKey) async =>
    null;

Future<PushSubscriptionKeys?> currentPushSubscription() async => null;

Future<void> unsubscribePush() async {}

Stream<String> notificationOpens() => const Stream.empty();
