import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_long_text_page.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NuniLongTextPage(
      title: l10n.privacyTitle,
      sections: [
        NuniLongTextSection(
          heading: l10n.privacyDataHeading,
          body: l10n.privacyDataBody,
        ),
        NuniLongTextSection(
          heading: l10n.privacyPurposeHeading,
          body: l10n.privacyPurposeBody,
        ),
        NuniLongTextSection(
          heading: l10n.privacyRetentionHeading,
          body: l10n.privacyRetentionBody,
        ),
        NuniLongTextSection(
          heading: l10n.privacyRightsHeading,
          body: l10n.privacyRightsBody,
        ),
        NuniLongTextSection(
          heading: l10n.privacyTrackingHeading,
          body: l10n.privacyTrackingBody,
        ),
      ],
    );
  }
}
