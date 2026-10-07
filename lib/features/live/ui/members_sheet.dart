import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_avatar.dart';
import '../../sessions/data/sessions_repository.dart';
import '../../sessions/domain/session_member.dart';
import '../../sessions/ui/co_organizer_crown.dart';
import '../data/live_repository.dart';
import '../domain/live_member.dart';

/// Naming a co-organizer (plan 08's "créateur absent"), or taking the role
/// back (plan 37, Q271): a plain role change (RLS
/// `session_members_owner_update`, any status but completed), no other
/// logic -- lets a session keep going even if the owner's phone drops out.
/// The creator ([creatorId]) and the caller keep theirs.
Future<void> showMembersSheet(
  BuildContext context, {
  required String sessionId,
  required String creatorId,
  required List<LiveMember> members,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (context) => MembersSheet(
    sessionId: sessionId,
    creatorId: creatorId,
    members: members,
  ),
);

class MembersSheet extends ConsumerStatefulWidget {
  const MembersSheet({
    super.key,
    required this.sessionId,
    required this.creatorId,
    required this.members,
  });

  final String sessionId;
  final String creatorId;
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
          .setCoOrganizer(
            sessionId: widget.sessionId,
            userId: member.userId,
            organizer: member.role != MemberRole.owner,
          );
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
    final myId = ref.read(supabaseClientProvider).auth.currentUser?.id;
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
              leading: NuniAvatar(name: member.playerName),
              title: Text(member.playerName),
              subtitle: member.role == MemberRole.owner
                  ? Text(l10n.homeRoleOwner)
                  : null,
              trailing: CoOrganizerCrown(
                role: member.role,
                locked:
                    member.userId == widget.creatorId || member.userId == myId,
                onToggle: _busy ? null : () => _promote(member),
                size: 24,
              ),
            ),
        ],
      ),
    );
  }
}
