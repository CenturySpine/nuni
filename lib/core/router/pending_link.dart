import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../web/web_local_storage.dart';

const _key = 'nuni.pendingLink';

/// The page a signed-out visitor asked for -- an invitation `/join/CODE`
/// (plan 09) or a shared event `/planning/ID` (plan 23, Q168) -- kept while
/// they sign in, then opened instead of home.
///
/// Stored in the site's local storage, not the tab's: on a phone, the Google
/// sign-in often comes back in another window than the one the link opened
/// (installed app vs. browser tab). Forgotten after [lifetime], so a link
/// left halfway never hijacks a much later sign-in.
abstract final class PendingLink {
  /// How long a remembered link stays valid (PO, 2026-09-25).
  static const lifetime = Duration(minutes: 5);

  @visibleForTesting
  static DateTime Function() clock = DateTime.now;

  static void remember(String location) => writeLocalValue(
    _key,
    jsonEncode({'location': location, 'at': clock().millisecondsSinceEpoch}),
  );

  /// Returns the pending page, if any and still valid, and forgets it.
  static String? take() {
    final raw = readLocalValue(_key);
    if (raw == null) return null;
    writeLocalValue(_key, null);
    try {
      final value = jsonDecode(raw) as Map<String, dynamic>;
      final at = DateTime.fromMillisecondsSinceEpoch(value['at'] as int);
      if (clock().difference(at) > lifetime) return null;
      return value['location'] as String;
    } catch (_) {
      return null;
    }
  }
}
