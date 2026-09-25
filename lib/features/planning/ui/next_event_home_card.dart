import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_section_header.dart';
import '../../profile/data/profile_repository.dart';
import '../data/events_repository.dart';
import '../domain/event.dart';
import '../domain/planning.dart';
import 'event_widgets.dart';

/// Home's "Next event" (plan 23, Q158): my association's first event whose
/// day isn't over, with my answer buttons, the present count and the
/// comments. Nothing at all without an association or a coming event.
class NextEventHomeSection extends ConsumerWidget {
  const NextEventHomeSection({super.key});

  Future<void> _answer(
    BuildContext context,
    WidgetRef ref,
    Event event,
    String playerId,
    EventResponse? response,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(eventsRepositoryProvider)
          .answer(eventId: event.id, playerId: playerId, response: response);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(describePlanningError(error, l10n))),
        );
      }
    }
    ref
      ..invalidate(myPlanningProvider)
      ..invalidate(eventByIdProvider(event.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final me = ref.watch(myPlayerProvider).value;
    final events = ref.watch(myPlanningProvider).value;
    if (me == null || me.associationId == null || events == null) {
      return const SizedBox.shrink();
    }
    final now = DateTime.now();
    final event = nextEvent(events, now);
    if (event == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NuniSectionHeader(
            title: l10n.homeNextEventTitle,
            trailing: TextButton(
              onPressed: () => context.go('/planning'),
              child: Text(l10n.homeNextEventSeePlanning),
            ),
          ),
          EventCard(
            event: event,
            myResponse: event.responseOf(me.id),
            onTap: () => context.push('/planning/${event.id}'),
            footer: acceptsAnswers(event, now)
                ? EventResponseButtons(
                    current: event.responseOf(me.id),
                    onChanged: (response) =>
                        _answer(context, ref, event, me.id, response),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
