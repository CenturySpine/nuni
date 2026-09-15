import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_empty_state.dart';

/// My player profile (plan 05). Placeholder until that plan lands.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: NuniEmptyState(
        icon: Icons.person_outline,
        message: l10n.profileComingSoon,
      ),
    );
  }
}
