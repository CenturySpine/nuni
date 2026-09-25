/// The browser tab's `sessionStorage`: it survives the page reload of the
/// Google sign-in redirect, and is forgotten when the tab closes.
///
/// Conditionally implemented, like `web_share_support.dart`: the real one
/// needs `package:web`, unavailable outside a web compile target -- tests
/// run on the Dart VM, where an in-memory map stands in for it.
library;

export 'web_session_storage_stub.dart'
    if (dart.library.js_interop) 'web_session_storage_web.dart';
