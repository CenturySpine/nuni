import 'event.dart';

/// The planning's rules (plan 23), kept apart from the screens so they are
/// unit-tested. Every date is compared in the device's local time: an event
/// "of the day" is the one of the user's own calendar day.

/// The end of [event]'s local calendar day: the moment it stops being the
/// "next event" on home (Q158) and starts being drawn as past (Q162).
DateTime endOfEventDay(Event event) {
  final local = event.startsAt.toLocal();
  return DateTime(local.year, local.month, local.day + 1);
}

/// Whether [event]'s day is over at [now].
bool isEventPast(Event event, DateTime now) =>
    !now.isBefore(endOfEventDay(event));

/// Whether [event] happens on [now]'s local day -- the day "Start the
/// session" is offered (Q164).
bool isEventToday(Event event, DateTime now) {
  final local = event.startsAt.toLocal();
  final today = now.toLocal();
  return local.year == today.year &&
      local.month == today.month &&
      local.day == today.day;
}

/// How far ahead an event shows its weather forecast (plan 32, Q215),
/// counted from the moment one looks at the app.
const forecastHorizon = Duration(days: 7);

/// Whether [event] shows its forecast at [now] (plan 32): it has a point
/// on the map (Q213), its day isn't over, and it starts within
/// [forecastHorizon].
bool showsForecast(Event event, DateTime now) =>
    event.hasLocation &&
    !isEventPast(event, now) &&
    event.startsAt.isBefore(now.add(forecastHorizon));

/// The first event whose day isn't over at [now] (Q158), or null.
Event? nextEvent(Iterable<Event> events, DateTime now) {
  Event? next;
  for (final event in events) {
    if (isEventPast(event, now)) continue;
    if (next == null || event.startsAt.isBefore(next.startsAt)) next = event;
  }
  return next;
}

/// One month of the planning: the list shows a year heading when the year
/// changes, then a month heading (plan 23, decision 12).
class PlanningMonth {
  const PlanningMonth({
    required this.year,
    required this.month,
    required this.events,
  });

  final int year;
  final int month;
  final List<Event> events;
}

/// [events] in date order, grouped by local year and month, oldest first:
/// past and coming events in one list (Q159, Q162).
List<PlanningMonth> groupByMonth(Iterable<Event> events) {
  final sorted = [...events]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  final months = <PlanningMonth>[];
  for (final event in sorted) {
    final local = event.startsAt.toLocal();
    final last = months.isEmpty ? null : months.last;
    if (last != null && last.year == local.year && last.month == local.month) {
      last.events.add(event);
    } else {
      months.add(
        PlanningMonth(year: local.year, month: local.month, events: [event]),
      );
    }
  }
  return months;
}

/// The prefix of a cloned event's label (Q152).
const clonePrefix = 'Clone - ';

/// What the form starts from when cloning [event] (Q152): every field, the
/// label prefixed, one week later -- answers and comments aren't copied.
EventDraft cloneDraft(Event event) => EventDraft(
  startsAt: event.startsAt.toLocal().add(const Duration(days: 7)),
  label: '$clonePrefix${event.label}',
  spot: event.spot,
  spotId: event.spotId,
  lat: event.locationLat,
  lng: event.locationLng,
  managerPlayerId: event.managerPlayerId,
  description: event.description,
  color: event.color,
);

/// Distinct labels already used, most recent first, without the ones a
/// clone left as they were (Q147, Q165). [labels] is most recent first.
List<String> labelSuggestions(Iterable<String> labels) {
  final seen = <String>{};
  return [
    for (final label in labels)
      if (!label.startsWith(clonePrefix) && seen.add(label.trim()))
        label.trim(),
  ];
}

/// An event's one session (PO, 2026-09-29) as I may know it: completed or
/// not, and whether I'm in it -- even while it's in its waiting room,
/// where I can't read it.
class EventSessionState {
  const EventSessionState({required this.completed, required this.isMember});

  final bool completed;
  final bool isMember;
}

/// What an event's page offers about its session (PO, 2026-09-29).
enum EventSessionOffer {
  /// Nothing: no session, and I may not start one.
  none,

  /// "Start the session": none yet, and I may start it.
  start,

  /// "Join the session", by its code or QR code: I answered "Present".
  join,

  /// A session is on, and answering "Present" offers to join it.
  attendToJoin,

  /// The session itself: I'm in it, or it's over.
  open,
}

/// One path for all once the session exists, managers included: whoever
/// isn't in it joins by the code, never directly (PO, 2026-09-29).
EventSessionOffer eventSessionOffer({
  required EventSessionState? session,
  required bool canStart,
  required bool attending,
}) {
  if (session == null) {
    return canStart ? EventSessionOffer.start : EventSessionOffer.none;
  }
  if (session.completed || session.isMember) return EventSessionOffer.open;
  return attending ? EventSessionOffer.join : EventSessionOffer.attendToJoin;
}
