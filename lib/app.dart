import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/locale_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/palette_controller.dart';
import 'features/badges/ui/badge_announcer.dart';
import 'l10n/generated/app_localizations.dart';

class NuniApp extends ConsumerWidget {
  const NuniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeControllerProvider);
    final palette = ref.watch(paletteControllerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: buildAppTheme(palette),
      routerConfig: router,
      // New badges are announced above any page (plan 21).
      builder: (context, child) => BadgeAnnouncer(
        navigatorKey: router.routerDelegate.navigatorKey,
        child: child ?? const SizedBox.shrink(),
      ),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
