import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../sessions/data/sessions_repository.dart';
import '../../sessions/domain/session_member.dart';
import '../data/live_repository.dart';
import '../domain/live_member.dart';

/// Promoting a co-organizer (plan 08's "créateur absent"): a plain role
/// change (RLS `session_members_owner_update`, any status but completed),
/// no other logic -- lets a session keep going even if the owner's phone
/// drops out.
Future<void> showMembersSheet(
  BuildContext context, {
  required String sessionId,
  required List<LiveMember> members,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (context) => MembersSheet(sessionId: sessionId, members: members),
);

class MembersSheet extends ConsumerStatefulWidget {
  const MembersSheet({
    super.key,
    required this.sessionId,
    required this.members,
  });

  final String sessionId;
  final List<LiveMember> members;

  @override
  ConsumerState<MembersSheet> createState() => _MembersSheetState();
}

class _MembersSheetState extends ConsumerState<MembersSheet> {
  bool _busy = false;

  Future<void> _promote(LiveMember member) async {
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(sessionsRepositoryProvider)
          .promoteToOwner(sessionId: widget.sessionId, userId: member.userId);
      ref.invalidate(liveSessionProvider(widget.sessionId));
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(describeError(error, l10n))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sessionsLiveMembersAction,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          for (final member in widget.members)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(member.playerName),
              subtitle: member.role == MemberRole.owner
                  ? Text(l10n.homeRoleOwner)
                  : null,
              trailing: member.role == MemberRole.owner
                  ? null
                  : IconButton(
                      icon: const Icon(PhosphorIcons.crown),
                      tooltip: l10n.sessionsRoomPromote,
                      onPressed: _busy ? null : () => _promote(member),
                    ),
            ),
        ],
      ),
    );
  }
}
