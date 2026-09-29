/// A device's push subscription, as the send-push Edge Function needs it:
/// the browser's push address and the two keys the message is encrypted
/// with (URL-safe base64, no padding).
class PushSubscriptionKeys {
  const PushSubscriptionKeys({
    required this.endpoint,
    required this.p256dh,
    required this.auth,
  });

  final String endpoint;
  final String p256dh;
  final String auth;
}
