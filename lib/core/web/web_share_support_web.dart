import 'dart:js_interop';
import 'dart:js_interop_unsafe';

// `.has()` (dart:js_interop_unsafe) checks property existence directly on
// the JS object, unlike a plain `@JS('navigator.share') external get`,
// which in testing did not reliably read back `null`/`undefined` through
// dartdevc for an absent property. share_plus's own capability check calls
// both `navigator.share` and `navigator.canShare`; a browser can expose one
// without the other (found in testing, some headless/automation Chromium
// builds), which makes share_plus's internal check throw and fall down its
// broken web fallback path (see `invite_sheet.dart`). Both are required.
bool get isWebShareSupported {
  try {
    final navigator = globalContext['navigator'] as JSObject?;
    if (navigator == null) return false;
    return navigator.has('share') && navigator.has('canShare');
  } catch (_) {
    return false;
  }
}
