import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/palettes.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_avatar.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_chip.dart';
import '../../../shared/nuni_status_pill.dart';
import '../../players/data/players_repository.dart';
import '../domain/event.dart';

/// The colour an event is drawn in (Q149), or null without one.
Color? eventHue(EventColor? color) =>
    color == null ? null : eventHues[color.index];

String eventColorName(AppLocalizations l10n, EventColor color) =>
    switch (color) {
      EventColor.red => l10n.planningColorRed,
      EventColor.orange => l10n.planningColorOrange,
      EventColor.yellow => l10n.planningColorYellow,
      EventColor.green => l10n.planningColorGreen,
      EventColor.teal => l10n.planningColorTeal,
      EventColor.blue => l10n.planningColorBlue,
      EventColor.purple => l10n.planningColorPurple,
      EventColor.pink => l10n.planningColorPink,
    };

String responseLabel(AppLocalizations l10n, EventResponse response) =>
    switch (response) {
      EventResponse.yes => l10n.planningResponseYes,
      EventResponse.no => l10n.planningResponseNo,
      EventResponse.maybe => l10n.planningResponseMaybe,
    };

NuniTone responseTone(EventResponse response) => switch (response) {
  EventResponse.yes => NuniTone.fairway,
  EventResponse.no => NuniTone.danger,
  EventResponse.maybe => NuniTone.highlight,
};

/// The planning's own refusals from the base, in words; anything else like
/// every other screen.
String describePlanningError(Object error, AppLocalizations l10n) {
  if (error is PostgrestException) {
    switch (error.message) {
      case 'event_started':
        return l10n.planningAnswersClosed;
      case 'event_not_startable':
        return l10n.planningErrorNotStartable;
      case 'manager_not_member':
        return l10n.planningErrorManagerNotMember;
    }
  }
  return describeError(error, l10n);
}

/// "jeudi 1 octobre · 19:00", in the app's language.
String eventDateTimeLabel(BuildContext context, DateTime startsAt) {
  final locale = Localizations.localeOf(context).toString();
  final local = startsAt.toLocal();
  return '${DateFormat.MMMMEEEEd(locale).format(local)} · '
      '${DateFormat.Hm(locale).format(local)}';
}

/// The number of comments, as a small pill -- nothing at zero (plan 23,
/// decision 8).
class EventCommentCount extends StatelessWidget {
  const EventCommentCount({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return NuniStatusPill(
      label: '$count',
      icon: PhosphorIcons.chatCircleText,
      tone: NuniTone.neutral,
    );
  }
}

/// My three answer buttons (Q157): tapping my current answer withdraws it.
/// Disabled once the event has started.
class EventResponseButtons extends StatelessWidget {
  const EventResponseButtons({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final EventResponse? current;

  /// Null once answers are closed.
  final ValueChanged<EventResponse?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final response in EventResponse.values)
          NuniChip(
            label: responseLabel(l10n, response),
            selected: current == response,
            onTap: onChanged == null
                ? null
                : () => onChanged!(current == response ? null : response),
          ),
      ],
    );
  }
}

/// A condensed event (planning list, home): a stripe of its colour, its day
/// in a tile with the person in charge's avatar under it, label, time and place, my answer, present count and comments.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.myResponse,
    this.onTap,
    this.faded = false,
    this.footer,
  });

  final Event event;
  final EventResponse? myResponse;
  final VoidCallback? onTap;

  /// Past events are drawn quieter (Q162).
  final bool faded;

  /// Extra content under the details (home's answer buttons).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final local = event.startsAt.toLocal();
    final hue = eventHue(event.color) ?? context.nuni.border;
    final details = [
      DateFormat.Hm(locale).format(local),
      event.spot ?? l10n.planningSpotToBeDecided,
    ].join(' · ');

    final card = NuniCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: hue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(NuniRadius.card),
                  bottomLeft: Radius.circular(NuniRadius.card),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            _DayTile(date: local),
                            if (event.managerPlayerId != null) ...[
                              const SizedBox(height: 8),
                              _ManagerAvatar(playerId: event.managerPlayerId!),
                            ],
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.label,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                details,
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  if (myResponse != null)
                                    NuniStatusPill(
                                      label: responseLabel(l10n, myResponse!),
                                      tone: responseTone(myResponse!),
                                    ),
                                  // Number only on the card; the sentence
                                  // stays for screen readers.
                                  Semantics(
                                    label: l10n.planningPresentCount(
                                      event.yesCount,
                                    ),
                                    excludeSemantics: true,
                                    child: NuniStatusPill(
                                      label: '${event.yesCount}',
                                      icon: PhosphorIcons.users,
                                      tone: NuniTone.neutral,
                                    ),
                                  ),
                                  EventCommentCount(count: event.commentCount),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (footer != null) ...[
                      const SizedBox(height: 12),
                      footer!,
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return faded ? Opacity(opacity: 0.55, child: card) : card;
  }
}

/// The day number over the short weekday, like a calendar leaf.
class _DayTile extends StatelessWidget {
  const _DayTile({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final textTheme = Theme.of(context).textTheme;
    final tone = context.nuni.primaryTone;
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: tone.container,
        borderRadius: BorderRadius.circular(NuniRadius.control),
      ),
      child: Column(
        children: [
          Text(
            DateFormat.E(locale).format(date),
            style: textTheme.labelSmall?.copyWith(color: tone.onContainer),
          ),
          Text(
            '${date.day}',
            style: textTheme.titleMedium?.copyWith(
              color: tone.onContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// The event's person in charge, as a small avatar under the day tile; their
/// name on long press and for screen readers.
class _ManagerAvatar extends ConsumerWidget {
  const _ManagerAvatar({required this.playerId});

  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final player = ref.watch(playerByIdProvider(playerId)).value;
    final label = player == null
        ? l10n.planningManager
        : '${l10n.planningManager} · ${player.name}';
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        excludeSemantics: true,
        child: NuniAvatar(
          name: player?.name,
          imageUrl: player?.avatarUrl,
          size: 28,
        ),
      ),
    );
  }
}
