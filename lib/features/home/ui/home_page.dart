import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Placeholder home page: proves the deployment pipeline end to end.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.appTitle, style: textTheme.displayLarge),
            const SizedBox(height: 8),
            Text(l10n.tagline, style: textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
