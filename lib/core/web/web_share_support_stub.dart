/// Only reached outside a web compile target (e.g. `flutter test` on the
/// Dart VM) -- the app itself is web-only, so this value is never read at
/// runtime.
bool get isWebShareSupported => false;
