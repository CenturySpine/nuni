import 'package:flutter/material.dart';

import '../../../core/theme/phosphor_icons.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_empty_state.dart';

/// History tab body: past sessions (plan 10). Placeholder until that plan
/// lands.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NuniEmptyState(
      icon: PhosphorIcons.clockCounterClockwise,
      message: AppLocalizations.of(context)!.historyComingSoon,
    );
  }
}
