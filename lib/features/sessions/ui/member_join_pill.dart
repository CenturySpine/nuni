import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_status_pill.dart';
import '../domain/session_member.dart';

/// Whether a participant joined the session themselves (code, QR code) or
/// was only added by the organizer or from an event (PO, 2026-09-28).
class MemberJoinPill extends StatelessWidget {
  const MemberJoinPill({super.key, required this.member});

  final SessionMember member;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: member.hasJoined
          ? NuniStatusPill(
              label: l10n.sessionsMemberJoined,
              icon: PhosphorIcons.checkCircle,
              tone: NuniTone.fairway,
            )
          : NuniStatusPill(
              label: l10n.sessionsMemberAdded,
              icon: PhosphorIcons.hourglass,
              tone: NuniTone.sunshine,
            ),
    );
  }
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
