import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import 'nuni_powered_by.dart';

/// The legal footer shown on the login screen and in settings (plan 04):
/// "Powered by Lyon Street Golf" above the three links (Legal notice, Privacy, About).
class NuniLegalFooter extends StatelessWidget {
  const NuniLegalFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Quiet links: secondary text colour, smaller than a regular action.
    final style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      textStyle: Theme.of(context).textTheme.labelMedium,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const NuniPoweredBy(),
        const SizedBox(height: 4),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 0,
          children: [
            TextButton(
              style: style,
              onPressed: () => context.push('/legal'),
              child: Text(l10n.settingsLegal),
            ),
            TextButton(
              style: style,
              onPressed: () => context.push('/privacy'),
              child: Text(l10n.settingsPrivacy),
            ),
            TextButton(
              style: style,
              onPressed: () => context.push('/about'),
              child: Text(l10n.settingsAbout),
            ),
          ],
        ),
      ],
    );
  }
}
