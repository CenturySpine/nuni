import 'package:flutter/material.dart';

import '../../../core/theme/phosphor_icons.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_empty_state.dart';

/// Home tab body: "my live sessions, create, join" (plan 07+). Placeholder
/// until those plans land -- deliberately NOT the NUNI/tagline branding
/// block, which is the login page's alone (the two are separate pages: a
/// landing page before sign-in, a dashboard after).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return NuniEmptyState(
      icon: PhosphorIcons.golf,
      message: AppLocalizations.of(context)!.homeComingSoon,
    );
  }
}
