import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import 'push_subscription_keys.dart';

/// This device's row in `push_subscriptions` (plan 33), written only
/// through its two RPCs: the table itself is closed to the app.
class PushSubscriptionsRepository {
  PushSubscriptionsRepository(this._client);

  final SupabaseClient _client;

  bool get isSignedIn => _client.auth.currentSession != null;

  /// [locale]: the language the app shows on this device (Q230).
  Future<void> save(PushSubscriptionKeys keys, String locale) =>
      _client.rpc<void>(
        'save_push_subscription',
        params: {
          'p_endpoint': keys.endpoint,
          'p_p256dh': keys.p256dh,
          'p_auth': keys.auth,
          'p_locale': locale,
        },
      );

  Future<void> delete(String endpoint) => _client.rpc<void>(
    'delete_push_subscription',
    params: {'p_endpoint': endpoint},
  );
}

final pushSubscriptionsRepositoryProvider =
    Provider<PushSubscriptionsRepository>(
      (ref) => PushSubscriptionsRepository(ref.watch(supabaseClientProvider)),
    );
