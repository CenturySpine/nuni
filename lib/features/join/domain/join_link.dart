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
