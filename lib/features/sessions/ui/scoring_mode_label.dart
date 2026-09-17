import '../../../l10n/generated/app_localizations.dart';
import '../domain/scoring_mode.dart';

String scoringModeLabel(AppLocalizations l10n, ScoringMode mode) =>
    switch (mode) {
      ScoringMode.strokePlay => l10n.sessionsScoringStrokePlay,
      ScoringMode.matchPlay => l10n.sessionsScoringMatchPlay,
      ScoringMode.redistribution => l10n.sessionsScoringRedistribution,
      ScoringMode.free => l10n.sessionsScoringFree,
    };
