/// The invite link for a session code (plan 09): `origin/join/CODE`, a
/// plain path (not `origin/#/join/CODE` -- see `usePathUrlStrategy()` in
/// `main.dart`). Built from [origin] (defaulting to `Uri.base`, the running
/// page's own origin) rather than a hardcoded production domain, so it
/// also resolves correctly against a local dev server (PO, 2026-09-16):
/// the debug banner already marks those builds. [origin] is injectable so
/// tests don't depend on `Uri.base`, which has no `http`/`https` scheme
/// (and no `.origin`) in a VM test run.
Uri joinUrl(String code, {Uri? origin}) =>
    Uri.parse('${(origin ?? Uri.base).origin}/join/$code');

/// The session code a scanned QR holds (PO, 2026-09-29), or null when it
/// isn't one of ours: the invite link (`.../join/CODE`, whatever the
/// origin, so a code shown by a dev build still reads) or a bare code.
String? codeFromScan(String raw) {
  final text = raw.trim();
  final uri = Uri.tryParse(text);
  if (uri != null && uri.hasScheme) {
    final segments = uri.pathSegments;
    final at = segments.lastIndexOf('join');
    if (at < 0 || at != segments.length - 2) return null;
    return _asCode(segments.last);
  }
  return _asCode(text);
}

final _codePattern = RegExp(r'^[A-Za-z0-9]{4,12}$');

String? _asCode(String text) =>
    _codePattern.hasMatch(text) ? text.toUpperCase() : null;
