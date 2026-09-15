import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_empty_state.dart';

/// Holes tab body: directory and proximity search (plan 06). Placeholder
/// until that plan lands.
class HolesPage extends StatelessWidget {
  const HolesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NuniEmptyState(
      icon: Icons.golf_course_outlined,
      message: AppLocalizations.of(context)!.holesComingSoon,
    );
  }
}
