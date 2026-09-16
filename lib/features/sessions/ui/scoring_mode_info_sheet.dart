import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../domain/scoring_mode.dart';

/// "Fiche d'explication" for a scoring mode (plan 07), opened from the info
/// button next to each chip on the creation screen.
class ScoringModeInfoSheet extends StatelessWidget {
  const ScoringModeInfoSheet({super.key, required this.mode});

  final ScoringMode mode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (title, description) = switch (mode) {
      ScoringMode.strokePlay => (
        l10n.sessionsScoringStrokePlay,
        l10n.sessionsScoringInfoStrokePlay,
      ),
      ScoringMode.matchPlay => (
        l10n.sessionsScoringMatchPlay,
        l10n.sessionsScoringInfoMatchPlay,
      ),
      ScoringMode.redistribution => (
        l10n.sessionsScoringRedistribution,
        l10n.sessionsScoringInfoRedistribution,
      ),
      ScoringMode.free => (
        l10n.sessionsScoringFree,
        l10n.sessionsScoringInfoFree,
      ),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
