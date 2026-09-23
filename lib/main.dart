import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'core/l10n/locale_controller.dart';
import 'core/supabase/supabase_providers.dart';
import 'core/theme/palette_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Plain paths (`/join/CODE`), not `/#/join/CODE`: the invite link and QR
  // code (plan 09) are written as literal URLs. Vercel's catch-all rewrite
  // to index.html (vercel.json) exists to support exactly this.
  usePathUrlStrategy();
  _registerFontLicences();
  // Awaited so the initial route decision (see core/router/auth_guard.dart)
  // already knows about a restored session -- no login "flash".
  await initializeSupabase();
  final persistedLocale = await loadPersistedLocale();
  final persistedPalette = await loadPersistedPalette();

  runApp(
    ProviderScope(
      overrides: [
        persistedLocaleProvider.overrideWithValue(persistedLocale),
        persistedPaletteProvider.overrideWithValue(persistedPalette),
      ],
      child: const NuniApp(),
    ),
  );
}

/// Fonts are bundled as assets, not Dart packages, so Flutter's licence page
/// (Legal notice > Credits) would miss them without this.
void _registerFontLicences() {
  LicenseRegistry.addLicense(() async* {
    for (final (package, asset) in [
      ('Phosphor Icons', 'assets/fonts/LICENSE-phosphor.txt'),
      ('Plus Jakarta Sans', 'assets/fonts/LICENSE-plus-jakarta-sans.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([
        package,
      ], await rootBundle.loadString(asset));
    }
  });
}
