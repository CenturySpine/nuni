import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/l10n/locale_controller.dart';
import 'core/supabase/supabase_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Awaited so the initial route decision (see core/router/auth_guard.dart)
  // already knows about a restored session -- no login "flash".
  await initializeSupabase();
  final persistedLocale = await loadPersistedLocale();

  runApp(
    ProviderScope(
      overrides: [persistedLocaleProvider.overrideWithValue(persistedLocale)],
      child: const NuniApp(),
    ),
  );
}
