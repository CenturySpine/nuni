import 'package:web/web.dart' as web;

// Storage can be unavailable (private browsing, blocked site data): the
// app then simply forgets, never fails.
String? readLocalValue(String key) {
  try {
    return web.window.localStorage.getItem(key);
  } catch (_) {
    return null;
  }
}

void writeLocalValue(String key, String? value) {
  try {
    if (value == null) {
      web.window.localStorage.removeItem(key);
    } else {
      web.window.localStorage.setItem(key, value);
    }
  } catch (_) {
    // Nothing to do: see above.
  }
}
