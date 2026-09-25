/// The site's `localStorage`: shared by every tab and window of the app on
/// the device -- the installed app (PWA) as well as the browser -- so it
/// survives the Google sign-in, which may come back in another window.
///
/// Conditionally implemented, like `web_share_support.dart`: the real one
/// needs `package:web`, unavailable outside a web compile target -- tests
/// run on the Dart VM, where an in-memory map stands in for it.
library;

export 'web_local_storage_stub.dart'
    if (dart.library.js_interop) 'web_local_storage_web.dart';
