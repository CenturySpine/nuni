import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/planning/domain/event.dart';
import 'package:nuni/features/planning/domain/planning.dart';

Event _event(
  String id,
  DateTime startsAt, {
  String label = 'Session',
  List<EventAnswer> answers = const [],
  double? lat,
  double? lng,
}) => Event(
  id: id,
  associationId: 'a',
  createdBy: 'u',
  startsAt: startsAt,
  label: label,
  answers: answers,
  locationLat: lat,
  locationLng: lng,
);

void main() {
  // Local times throughout: the rules follow the device's calendar day.
  final now = DateTime(2026, 10, 1, 20);

  group('showsForecast', () {
    Event at(DateTime startsAt, {bool located = true}) => _event(
      'e',
      startsAt,
      lat: located ? 45.76 : null,
      lng: located ? 4.83 : null,
    );

    test('within 7 days of now, with a point', () {
      expect(showsForecast(at(DateTime(2026, 10, 2, 14)), now), isTrue);
      expect(showsForecast(at(DateTime(2026, 10, 8, 19)), now), isTrue);
    });

    test('never beyond 7 days from now', () {
      expect(showsForecast(at(DateTime(2026, 10, 8, 20)), now), isFalse);
      expect(showsForecast(at(DateTime(2026, 10, 20)), now), isFalse);
    });

    test('never without a point (Q213)', () {
      expect(
        showsForecast(at(DateTime(2026, 10, 2), located: false), now),
        isFalse,
      );
    });

    test('until the end of the event day, never after', () {
      final today = at(DateTime(2026, 10, 1, 14));
      expect(showsForecast(today, now), isTrue);
      expect(showsForecast(today, DateTime(2026, 10, 2, 0, 1)), isFalse);
    });
  });

  group('nextEvent', () {
    test('keeps an event of today until the end of its day', () {
      final tonight = _event('tonight', DateTime(2026, 10, 1, 19));
      final later = _event('later', DateTime(2026, 10, 8, 19));
      expect(nextEvent([later, tonight], now)?.id, 'tonight');
      expect(
        nextEvent([later, tonight], DateTime(2026, 10, 2, 0, 1))?.id,
        'later',
      );
    });

    test('is null without any coming event', () {
      expect(nextEvent([_event('old', DateTime(2026, 9, 1))], now), isNull);
    });
  });

  group('eventSessionOffer', () {
    const live = EventSessionState(completed: false, isMember: false);

    test('offers to start only without a session', () {
      expect(
        eventSessionOffer(session: null, canStart: true, attending: true),
        EventSessionOffer.start,
      );
      expect(
        eventSessionOffer(session: null, canStart: false, attending: true),
        EventSessionOffer.none,
      );
    });

    test('once started, a manager outside it joins like anyone', () {
      expect(
        eventSessionOffer(session: live, canStart: true, attending: true),
        EventSessionOffer.join,
      );
      expect(
        eventSessionOffer(session: live, canStart: true, attending: false),
        EventSessionOffer.attendToJoin,
      );
    });

    test('opens it for its members, and for all once over', () {
      expect(
        eventSessionOffer(
          session: const EventSessionState(completed: false, isMember: true),
          canStart: true,
          attending: true,
        ),
        EventSessionOffer.open,
      );
      expect(
        eventSessionOffer(
          session: const EventSessionState(completed: true, isMember: false),
          canStart: true,
          attending: false,
        ),
        EventSessionOffer.open,
      );
    });
  });

  test('isEventToday', () {
    final tonight = _event('tonight', DateTime(2026, 10, 1, 21));
    expect(isEventToday(tonight, now), isTrue);
    expect(isEventToday(tonight, DateTime(2026, 10, 2, 9)), isFalse);
  });

  test('groupByMonth sorts and groups by local year and month', () {
    final months = groupByMonth([
      _event('jan', DateTime(2027, 1, 7)),
      _event('oct2', DateTime(2026, 10, 15)),
      _event('dec', DateTime(2026, 12, 12)),
      _event('oct1', DateTime(2026, 10, 1)),
    ]);
    expect(
      [for (final m in months) (m.year, m.month)],
      [(2026, 10), (2026, 12), (2027, 1)],
    );
    expect(months.first.events.map((e) => e.id), ['oct1', 'oct2']);
  });

  test('cloneDraft copies every field, prefixes the label, one week later', () {
    final source = Event(
      id: 'e',
      associationId: 'a',
      createdBy: 'u',
      startsAt: DateTime(2026, 10, 1, 19),
      label: 'Session du jeudi',
      spot: 'Parc',
      locationLat: 45.7,
      locationLng: 4.8,
      managerPlayerId: 'p',
      description: 'Balles',
      color: EventColor.teal,
      answers: const [EventAnswer(playerId: 'p', response: EventResponse.yes)],
    );
    final draft = cloneDraft(source);
    expect(draft.label, 'Clone - Session du jeudi');
    expect(draft.startsAt, DateTime(2026, 10, 8, 19));
    expect(draft.spot, 'Parc');
    expect((draft.lat, draft.lng), (45.7, 4.8));
    expect(draft.managerPlayerId, 'p');
    expect(draft.description, 'Balles');
    expect(draft.color, EventColor.teal);
  });

  test('labelSuggestions dedupes and leaves untouched clone labels out', () {
    expect(
      labelSuggestions([
        'Session du jeudi',
        'Clone - Session du jeudi',
        'AG',
        'Session du jeudi',
      ]),
      ['Session du jeudi', 'AG'],
    );
  });

  test('Event reads its answers and comment count from one row', () {
    final event = Event.fromJson({
      'id': 'e',
      'association_id': 'a',
      'created_by': 'u',
      'starts_at': '2026-10-01T17:00:00+00:00',
      'label': 'Session',
      'origin': 'imported',
      'color': 'purple',
      'event_responses': [
        {'player_id': 'p1', 'response': 'yes'},
        {'player_id': 'p2', 'response': 'maybe'},
      ],
      'event_comments': [
        {'count': 3},
      ],
    });
    expect(event.origin, EventOrigin.imported);
    expect(event.color, EventColor.purple);
    expect(event.yesCount, 1);
    expect(event.responseOf('p2'), EventResponse.maybe);
    expect(event.responseOf('p3'), isNull);
    expect(event.commentCount, 3);
  });

  test('EventDraft.toRow trims and writes the point as EWKT', () {
    final row = EventDraft(
      startsAt: DateTime.utc(2026, 10, 1, 17),
      label: ' Session ',
      spot: '  ',
      lat: 45.7,
      lng: 4.8,
      color: EventColor.blue,
    ).toRow();
    expect(row['label'], 'Session');
    expect(row['spot'], isNull);
    expect(row['location'], 'SRID=4326;POINT(4.8 45.7)');
    expect(row['color'], 'blue');
    expect(row['starts_at'], '2026-10-01T17:00:00.000Z');
  });
}
