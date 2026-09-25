import '../web/web_session_storage.dart';

const _key = 'nuni.pendingLink';

/// The page a signed-out visitor asked for -- an invitation `/join/CODE`
/// (plan 09) or a shared event `/planning/ID` (plan 23, Q168) -- kept while
/// they sign in, then opened instead of home. Stored in the tab's session
/// storage, since the Google sign-in comes back by reloading the app.
abstract final class PendingLink {
  static String? read() => readSessionValue(_key);

  static void remember(String location) => writeSessionValue(_key, location);

  /// Returns the pending page, if any, and forgets it.
  static String? take() {
    final location = read();
    if (location != null) writeSessionValue(_key, null);
    return location;
  }
}
