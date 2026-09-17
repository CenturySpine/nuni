/// Triggers a browser "Save As" for the given bytes (plan 10's image export,
/// desktop fallback when the Web Share API isn't available -- see
/// `web_share_support.dart`, same reasoning). A no-op stub outside a web
/// compile target: nothing on mobile/desktop native ever calls this, since
/// `share_plus`'s native share sheet handles those platforms directly.
library;

export 'web_file_download_stub.dart'
    if (dart.library.js_interop) 'web_file_download_web.dart';
