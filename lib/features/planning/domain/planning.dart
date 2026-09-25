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

/// Whether answers are still open: until the event starts (Q157), the rule
/// the base enforces too.
bool acceptsAnswers(Event event, DateTime now) => now.isBefore(event.startsAt);

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
  lat: event.locationLat,
  lng: event.locationLng,
  managerPlayerId: event.managerPlayerId,
  description: event.description,
  color: event.color,
);

/// Distinct labels already used, most recent first, without the ones a
/// clone left as they were (Q148, Q165). [labels] is most recent first.
List<String> labelSuggestions(Iterable<String> labels) {
  final seen = <String>{};
  return [
    for (final label in labels)
      if (!label.startsWith(clonePrefix) && seen.add(label.trim()))
        label.trim(),
  ];
}

/// A spot already used by the association, with the last point known for it
/// (Q150: choosing it pre-fills the map).
class SpotSuggestion {
  const SpotSuggestion({required this.name, this.lat, this.lng});

  final String name;
  final double? lat;
  final double? lng;
}

/// A used spot: an event's spot or a session's zone (Q148), with its point
/// and when it was used.
class UsedSpot {
  const UsedSpot({
    required this.name,
    required this.usedAt,
    this.lat,
    this.lng,
  });

  final String name;
  final DateTime usedAt;
  final double? lat;
  final double? lng;
}

/// Distinct spots, most recently used first, each with its most recent known
/// point (Q148, Q150). Names are compared case-insensitively, trimmed.
List<SpotSuggestion> spotSuggestions(Iterable<UsedSpot> used) {
  final sorted = [...used]..sort((a, b) => b.usedAt.compareTo(a.usedAt));
  final byKey = <String, SpotSuggestion>{};
  for (final spot in sorted) {
    final name = spot.name.trim();
    if (name.isEmpty) continue;
    final key = name.toLowerCase();
    final known = byKey[key];
    if (known == null) {
      byKey[key] = SpotSuggestion(name: name, lat: spot.lat, lng: spot.lng);
    } else if (known.lat == null && spot.lat != null) {
      byKey[key] = SpotSuggestion(
        name: known.name,
        lat: spot.lat,
        lng: spot.lng,
      );
    }
  }
  return byKey.values.toList();
}
