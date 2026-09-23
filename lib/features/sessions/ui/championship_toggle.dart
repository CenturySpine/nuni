import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// The championship switch (plan 15, parcours 1), shared between
/// creation, the waiting room and post-completion settings: disabled with
/// an explanatory message when the session has no known location yet --
/// mirrors the trigger-side guard (`championship_requires_location`) so the
/// constraint is visible before the owner tries to save.
class ChampionshipToggle extends StatelessWidget {
  const ChampionshipToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.locationKnown,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool locationKnown;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(l10n.championshipToggleLabel),
      subtitle: locationKnown ? null : Text(l10n.championshipToggleNoLocation),
      value: value,
      onChanged: (locationKnown && onChanged != null)
          ? (checked) => onChanged!(checked)
          : null,
    );
  }
}

/// "Cette session compte pour le championnat de [zone], saison [saison]"
/// (plan 15, parcours 1): shown right after the checkbox actually takes
/// effect (the zone is only known once the session row exists and the
/// trigger has assigned it), so the owner sees and can undo the automatic
/// rattachement before continuing rather than discovering it later.
Future<void> showChampionshipTagConfirmation(
  BuildContext context, {
  required String? zoneLabel,
  required String season,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.championshipTagConfirmTitle),
      content: Text(
        l10n.championshipTagConfirmMessage(zoneLabel ?? '?', season),
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
