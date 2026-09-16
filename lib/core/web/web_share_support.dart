/// Whether the browser exposes the Web Share API at all. Checked before
/// ever calling `share_plus` (plan 09's invite sheet): on a browser without
/// it (most desktop browsers), `share_plus`'s own web fallback throws in a
/// way that doesn't surface as a catchable Dart exception -- found in
/// testing, an unhandled promise rejection instead. Pre-checking avoids
/// that fallback path entirely rather than trying to catch it.
///
/// Conditionally implemented: the real check needs `dart:js_interop`,
/// unavailable outside a web compile target -- `flutter test` runs on the
/// Dart VM, where the stub (always false, unused there anyway) applies.
library;

export 'web_share_support_stub.dart'
    if (dart.library.js_interop) 'web_share_support_web.dart';
