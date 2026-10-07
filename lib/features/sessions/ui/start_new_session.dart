import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_icon_tile.dart';
import '../../../shared/nuni_list_card.dart';
import '../../../shared/nuni_section_header.dart';
import '../../planning/data/events_repository.dart';
import '../../planning/domain/event.dart';
import '../data/sessions_repository.dart';
import '../domain/drafts.dart';
import '../domain/session.dart';
import '../domain/session_kind.dart';
import 'session_nature.dart';

/// "Create a session" (home) and "Start the session" ([event]'s page), plan
/// 37: straight to the form, unless the caller has drafts to offer
/// ([offerableDrafts]) -- then a sheet offers a new session or one of them.
/// Picking a draft is the only way to publish it (Q256): linked to [event]
/// with its "present" members when started from one (Q259), then its
/// waiting room opens. A failed lookup of the drafts never holds up
/// creating a session: the form opens as before.
Future<void> startNewSession(
  BuildContext context,
  WidgetRef ref, {
  Event? event,
}) async {
  if (_starting) return;
  _starting = true;
  try {
    await _startNewSession(context, ref, event: event);
  } finally {
    _starting = false;
  }
}

/// Set while [startNewSession] looks up the drafts, shows its sheet or
/// publishes the draft picked: a second tap meanwhile does nothing. The
/// lookup is a network round trip without visible feedback; a double tap
/// opened the form, or the sheet, twice (seen in the browser, 2026-10-07).
bool _starting = false;

Future<void> _startNewSession(
  BuildContext context,
  WidgetRef ref, {
  Event? event,
}) async {
  final newPath = event == null
      ? '/session/new'
      : '/session/new?event=${event.id}';
  var drafts = const <Session>[];
  try {
    drafts = offerableDrafts(
      await ref.read(sessionsRepositoryProvider).myDrafts(),
      eventAssociationId: event?.associationId,
    );
  } catch (_) {
    // The form, as before.
  }
  if (!context.mounted) return;
  if (drafts.isEmpty) {
    unawaited(context.push(newPath));
    return;
  }

  final choice = await showModalBottomSheet<_Choice>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _DraftChoiceSheet(drafts: drafts),
  );
  if (choice == null || !context.mounted) return;
  final draft = choice.draft;
  if (draft == null) {
    unawaited(context.push(newPath));
    return;
  }

  final l10n = AppLocalizations.of(context)!;
  try {
    await ref
        .read(sessionsRepositoryProvider)
        .publishSession(draft.id, eventId: event?.id);
  } on PostgrestException catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(switch (error.message) {
            // Plan 23, Q164: no longer the event's day, or in charge of it.
            'event_not_startable' => l10n.planningErrorNotStartable,
            // One session per event (Q223), started meanwhile.
            'event_has_session' => l10n.planningErrorHasSession,
            _ => describeError(error, l10n),
          }),
        ),
      );
    }
    return;
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeError(error, l10n))));
    }
    return;
  }
  // The calling screen may have been left meanwhile: its ref goes with it.
  if (!context.mounted) return;
  ref.invalidate(myOngoingSessionsProvider);
  if (event != null) {
    ref
      ..invalidate(eventSessionsProvider(event.id))
      ..invalidate(eventSessionStateProvider(event.id));
  }
  unawaited(context.push('/session/${draft.id}'));
}

/// The sheet's answer: [draft] picked, or null for a new session.
typedef _Choice = ({Session? draft});

class _DraftChoiceSheet extends StatelessWidget {
  const _DraftChoiceSheet({required this.drafts});

  final List<Session> drafts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Text(l10n.sessionsDraftChoiceTitle, style: textTheme.titleLarge),
            const SizedBox(height: 16),
            NuniButton(
              icon: PhosphorIcons.plus,
              label: l10n.sessionsDraftChoiceNew,
              onPressed: () => Navigator.of(context).pop((draft: null)),
            ),
            const SizedBox(height: 20),
            NuniSectionHeader(title: l10n.sessionsDraftChoiceDrafts),
            Text(
              l10n.sessionsDraftChoiceHint,
              style: textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            for (final draft in drafts) ...[
              NuniListCard(
                leading: NuniIconTile(
                  icon: !draft.hasScoring && draft.tags.isNotEmpty
                      ? sessionTagIcon(draft.tags.first)
                      : draft.kind == SessionKind.team
                      ? PhosphorIcons.users
                      : PhosphorIcons.golf,
                  tone: draft.kind == SessionKind.team
                      ? NuniTone.primary
                      : NuniTone.fairway,
                ),
                title: sessionHeading(draft),
                subtitle: [
                  ...sessionNatureLabels(l10n, draft),
                  DateFormat.yMMMd(locale).format(draft.createdAt.toLocal()),
                ].join(' · '),
                onTap: () => Navigator.of(context).pop((draft: draft)),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
