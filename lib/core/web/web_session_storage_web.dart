import 'package:web/web.dart' as web;

// Storage can be unavailable (private browsing, blocked site data): the
// app then simply forgets, never fails.
String? readSessionValue(String key) {
  try {
    return web.window.sessionStorage.getItem(key);
  } catch (_) {
    return null;
  }
}

void writeSessionValue(String key, String? value) {
  try {
    if (value == null) {
      web.window.sessionStorage.removeItem(key);
    } else {
      web.window.sessionStorage.setItem(key, value);
    }
  } catch (_) {
    // Nothing to do: see above.
  }
}
