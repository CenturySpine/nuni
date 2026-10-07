import 'package:flutter/material.dart';

import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/session_member.dart';

/// A session member's co-organizer crown, shown to the session's
/// organizers (plan 37, Q271): an outlined crown names a participant
/// co-organizer, a filled one takes the role back -- whether they have
/// joined the session or not. [locked] (the creator, and the caller
/// themself) shows the filled crown without letting it be touched: the
/// creator stays an organizer, and no one strips their own rights by
/// mistake.
class CoOrganizerCrown extends StatelessWidget {
  const CoOrganizerCrown({
    super.key,
    required this.role,
    required this.locked,
    required this.onToggle,
    this.size = 18,
  });

  final MemberRole role;
  final bool locked;

  /// Null while busy.
  final VoidCallback? onToggle;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOrganizer = role == MemberRole.owner;
    if (locked) {
      if (!isOrganizer) return const SizedBox.shrink();
      return Tooltip(
        message: l10n.homeRoleOwner,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            PhosphorIcons.crownFill,
            size: size,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return IconButton(
      icon: Icon(
        isOrganizer ? PhosphorIcons.crownFill : PhosphorIcons.crown,
        size: size,
      ),
      tooltip: isOrganizer ? l10n.sessionsRoomDemote : l10n.sessionsRoomPromote,
      onPressed: onToggle,
    );
  }
}
