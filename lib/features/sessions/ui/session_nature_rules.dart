import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/nuni_card.dart';
import '../domain/session.dart';
import '../domain/session_tag.dart';

/// The message for a refusal of `set_session_tags`, `set_session_report` or
/// `set_session_championship` about a session's natures (plan 29).
String sessionNatureErrorMessage(Object error, AppLocalizations l10n) =>
    switch (error) {
      PostgrestException(message: 'session_nature_frozen') =>
        l10n.sessionsNatureFrozen,
      PostgrestException(message: 'session_tag_locked') =>
        l10n.sessionsNatureLocked,
      PostgrestException(message: 'championship_session') =>
        l10n.sessionsChampionshipFirst,
      PostgrestException(message: 'not_game_session') =>
        l10n.sessionsChampionshipGameOnly,
      PostgrestException(message: 'session_nature_required') =>
        l10n.sessionsCreateNatureRequired,
      _ => describeError(error, l10n),
    };

/// Whether [tag] may still change on [session] (plan 29, Q197), for its
/// organizer or, with [isStaff], the association's staff: "simulator" is
/// frozen with a scorecard, "training" with a scorecard is the staff's once
/// the session is completed, and neither is allowed on a championship
/// session. `null` when allowed, else why not.
String? sessionTagLock(
  AppLocalizations l10n,
  Session session,
  SessionTag tag, {
  required bool isStaff,
}) {
  if (session.hasScoring && tag == SessionTag.simulator) {
    return l10n.sessionsNatureFrozen;
  }
  if (session.isChampionship &&
      !session.hasTag(tag) &&
      (tag == SessionTag.training || tag == SessionTag.simulator)) {
    return l10n.sessionsChampionshipFirst;
  }
  if (session.hasScoring &&
      tag == SessionTag.training &&
      session.status == SessionStatus.completed &&
      !isStaff) {
    return l10n.sessionsNatureLocked;
  }
  return null;
}

/// A session's report (plan 29), shown on every session: its text, or a
/// quiet "none yet" when [onEdit] is offered, and nothing otherwise.
class SessionReportCard extends StatelessWidget {
  const SessionReportCard({super.key, required this.report, this.onEdit});

  final String? report;

  /// The organizer or the association's staff; null for anyone else.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = report?.trim() ?? '';
    if (text.isEmpty && onEdit == null) return const SizedBox.shrink();
    return NuniCard(
      color: context.nuni.surfaceMuted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.sessionsReportTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(PhosphorIcons.notePencil, size: 20),
                  tooltip: l10n.sessionsReportEdit,
                  visualDensity: VisualDensity.compact,
                  onPressed: onEdit,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            text.isEmpty ? l10n.sessionsReportEmpty : text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: text.isEmpty
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
