import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Home tab body: "my live sessions, create, join" (plan 07+). Placeholder
/// until those plans land.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.appTitle, style: textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(l10n.tagline, style: textTheme.titleLarge),
        ],
      ),
    );
  }
}
