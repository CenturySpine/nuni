import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_loading.dart';
import '../../profile/domain/player.dart';
import '../data/sessions_repository.dart';

/// "Ajouter un participant" (Q26): searches every player linked to a user
/// (Q24 -- no ad hoc creation), recent-first, excluding [excludedUserIds]
/// (already in the pool). Returns the picked [Player], or null if dismissed.
Future<Player?> showAddParticipantSheet(
  BuildContext context, {
  required Set<String> excludedUserIds,
}) => showModalBottomSheet<Player>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => _AddParticipantSheet(excludedUserIds: excludedUserIds),
);

class _AddParticipantSheet extends ConsumerStatefulWidget {
  const _AddParticipantSheet({required this.excludedUserIds});

  final Set<String> excludedUserIds;

  @override
  ConsumerState<_AddParticipantSheet> createState() =>
      _AddParticipantSheetState();
}

class _AddParticipantSheetState extends ConsumerState<_AddParticipantSheet> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => setState(() => _query = value.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final results = ref.watch(playerSearchProvider(_query));

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SizedBox(
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.sessionsAddParticipantTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.sessionsAddParticipantSearchLabel,
              ),
              onChanged: _onChanged,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: results.when(
                data: (players) {
                  final visible = [
                    for (final player in players)
                      if (!widget.excludedUserIds.contains(player.userId))
                        player,
                  ];
                  if (visible.isEmpty) {
                    return Center(
                      child: Text(l10n.sessionsAddParticipantEmpty),
                    );
                  }
                  return ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final player = visible[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: player.avatarUrl == null
                              ? null
                              : NetworkImage(player.avatarUrl!),
                          child: player.avatarUrl == null
                              ? Text(
                                  player.name.isEmpty
                                      ? '?'
                                      : player.name[0].toUpperCase(),
                                )
                              : null,
                        ),
                        title: Text(player.name),
                        onTap: () => Navigator.of(context).pop(player),
                      );
                    },
                  );
                },
                loading: () => const NuniLoading(),
                error: (error, _) => Center(child: Text(l10n.errorGeneric)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
