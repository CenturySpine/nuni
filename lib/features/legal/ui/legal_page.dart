import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_long_text_page.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NuniLongTextPage(
      title: l10n.legalTitle,
      sections: [
        NuniLongTextSection(
          heading: l10n.legalPublisherHeading,
          body: l10n.legalPublisherBody,
        ),
        NuniLongTextSection(
          heading: l10n.legalHostingHeading,
          body: l10n.legalHostingBody,
        ),
      ],
    );
  }
}
