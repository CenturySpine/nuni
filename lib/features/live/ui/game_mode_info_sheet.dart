import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Explains the three team game modes (plan 08: "choix du mode de jeu ...
/// défaut Scramble, info"), reached from the "Ajouter un trou" sheet.
/// Individual sessions never show this -- their only game mode is fixed.
void showGameModeInfoSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Entry(
            l10n.sessionsLiveGameModeScramble,
            l10n.sessionsLiveGameModeInfoScramble,
          ),
          const SizedBox(height: 12),
          _Entry(
            l10n.sessionsLiveGameModeGreensome,
            l10n.sessionsLiveGameModeInfoGreensome,
          ),
          const SizedBox(height: 12),
          _Entry(
            l10n.sessionsLiveGameModeBestBall,
            l10n.sessionsLiveGameModeInfoBestBall,
          ),
        ],
      ),
    ),
  );
}

class _Entry extends StatelessWidget {
  const _Entry(this.title, this.description);

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 2),
      Text(description, style: Theme.of(context).textTheme.bodyMedium),
    ],
  );
}
