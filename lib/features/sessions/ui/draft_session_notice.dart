import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_status_pill.dart';

/// A draft's waiting room (plan 37): who sees it, and how to play it --
/// pick it when creating a session (Q256, Q261), since it can't be started
/// from here.
class DraftSessionNotice extends StatelessWidget {
  const DraftSessionNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NuniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NuniStatusPill(
            label: l10n.sessionsDraftLabel,
            tone: NuniTone.neutral,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.sessionsDraftNotice,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
