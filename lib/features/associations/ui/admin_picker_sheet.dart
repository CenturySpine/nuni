import 'package:flutter/material.dart';

import '../../../core/text/compare_names.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_avatar.dart';
import '../../profile/domain/player.dart';

/// "Ajouter un administrateur local" (plan 27): the association's members
/// who could be named -- the caller leaves out the admins and the manager
/// -- with a search by name. Returns the chosen member, or null.
Future<Player?> showAdminPickerSheet(
  BuildContext context,
  List<Player> candidates,
) => showModalBottomSheet<Player>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => _AdminPickerSheet(candidates: candidates),
);

class _AdminPickerSheet extends StatefulWidget {
  const _AdminPickerSheet({required this.candidates});

  final List<Player> candidates;

  @override
  State<_AdminPickerSheet> createState() => _AdminPickerSheetState();
}

class _AdminPickerSheetState extends State<_AdminPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = foldForSort(_query.trim());
    final shown = [
      for (final player in widget.candidates)
        if (query.isEmpty || foldForSort(player.name).contains(query)) player,
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  l10n.associationsAdminPickTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (widget.candidates.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Text(l10n.associationsAdminPickEmpty),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: l10n.associationsAdminPickSearch,
                    ),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final player in shown)
                        ListTile(
                          leading: NuniAvatar(
                            name: player.name,
                            imageUrl: player.avatarUrl,
                            size: 36,
                          ),
                          title: Text(player.name),
                          onTap: () => Navigator.of(context).pop(player),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
