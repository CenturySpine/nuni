import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_status_pill.dart';
import '../domain/session_member.dart';

/// Whether a participant joined the session themselves (code, QR code,
/// opening it) or was only added by the organizer or from an event (PO,
/// 2026-09-28): a green check or an orange hourglass, icon only (PO,
/// 2026-09-29) -- the words stay as the tooltip and for screen readers.
class MemberJoinIcon extends StatelessWidget {
  const MemberJoinIcon({super.key, required this.member});

  final SessionMember member;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final joined = member.hasJoined;
    final label = joined ? l10n.sessionsMemberJoined : l10n.sessionsMemberAdded;
    return Tooltip(
      message: label,
      child: Icon(
        joined ? PhosphorIcons.checkCircle : PhosphorIcons.hourglass,
        size: 18,
        semanticLabel: label,
        color: context.nuni
            .tone(joined ? NuniTone.fairway : NuniTone.sunshine)
            .onContainer,
      ),
    );
  }
}

/// A participant's name followed by their [MemberJoinIcon].
class MemberNameWithJoin extends StatelessWidget {
  const MemberNameWithJoin({
    super.key,
    required this.name,
    required this.member,
    this.style,
  });

  final String name;
  final SessionMember member;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Flexible(
        child: Text(name, style: style, overflow: TextOverflow.ellipsis),
      ),
      const SizedBox(width: 6),
      MemberJoinIcon(member: member),
    ],
  );
}

/// "3 of 5 joined", for a list header.
class JoinedCountPill extends StatelessWidget {
  const JoinedCountPill({super.key, required this.members});

  final List<SessionMember> members;

  @override
  Widget build(BuildContext context) {
    final joined = members.where((member) => member.hasJoined).length;
    return NuniStatusPill(
      label: AppLocalizations.of(context)!
          .sessionsRoomJoinedCount(joined, members.length),
      tone: joined == members.length ? NuniTone.fairway : NuniTone.sunshine,
    );
  }
}
