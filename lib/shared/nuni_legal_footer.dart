import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';

/// The three legal links, shown on the login screen and in settings
/// (plan 04): Legal notice, Privacy, About.
class NuniLegalFooter extends StatelessWidget {
  const NuniLegalFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        TextButton(
          onPressed: () => context.push('/legal'),
          child: Text(l10n.settingsLegal),
        ),
        TextButton(
          onPressed: () => context.push('/privacy'),
          child: Text(l10n.settingsPrivacy),
        ),
        TextButton(
          onPressed: () => context.push('/about'),
          child: Text(l10n.settingsAbout),
        ),
      ],
    );
  }
}
