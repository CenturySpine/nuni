import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// The championship switch (plan 15, parcours 1), shared between
/// creation, the waiting room and post-completion settings. The session
/// counts for its association's championship (plan 18, Q77): no location
/// needed any more.
class ChampionshipToggle extends StatelessWidget {
  const ChampionshipToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(l10n.championshipToggleLabel),
      value: value,
      onChanged: onChanged == null ? null : (checked) => onChanged!(checked),
    );
  }
}

/// "Cette session compte pour le championnat de [association], saison
/// [saison]" (plan 15, parcours 1): shown right after the checkbox actually
/// takes effect, so the owner sees which championship it counts for before
/// continuing rather than discovering it later.
Future<void> showChampionshipTagConfirmation(
  BuildContext context, {
  required String? associationLabel,
  required String season,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.championshipTagConfirmTitle),
      content: Text(
        l10n.championshipTagConfirmMessage(associationLabel ?? '?', season),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
      ],
    ),
  );
}
