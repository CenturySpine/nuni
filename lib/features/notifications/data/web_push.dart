/// The browser's notification permission and push subscription (plan 33).
///
/// Conditionally implemented, like `core/web/web_local_storage.dart`: the
/// real one needs `package:web`, unavailable outside a web compile target --
/// tests run on the Dart VM, where notifications are simply unsupported.
library;

export 'web_push_stub.dart' if (dart.library.js_interop) 'web_push_web.dart';
