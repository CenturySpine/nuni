import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/planning/domain/event.dart';
import 'package:nuni/features/planning/domain/planning.dart';

Event _event(
  String id,
  DateTime startsAt, {
  String label = 'Session',
  List<EventAnswer> answers = const [],
}) => Event(
  id: id,
  associationId: 'a',
  createdBy: 'u',
  startsAt: startsAt,
  label: label,
  answers: answers,
);

void main() {
  // Local times throughout: the rules follow the device's calendar day.
  final now = DateTime(2026, 10, 1, 20);

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

  test('isEventToday and acceptsAnswers', () {
    final tonight = _event('tonight', DateTime(2026, 10, 1, 21));
    expect(isEventToday(tonight, now), isTrue);
    expect(isEventToday(tonight, DateTime(2026, 10, 2, 9)), isFalse);
    expect(acceptsAnswers(tonight, now), isTrue);
    expect(acceptsAnswers(tonight, DateTime(2026, 10, 1, 21)), isFalse);
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

  test('spotSuggestions: most recent first, last known point kept', () {
    final spots = spotSuggestions([
      UsedSpot(name: 'Parc', usedAt: DateTime(2026, 9, 1), lat: 1, lng: 2),
      UsedSpot(name: 'parc ', usedAt: DateTime(2026, 9, 20)),
      UsedSpot(name: 'Quais', usedAt: DateTime(2026, 9, 10), lat: 3, lng: 4),
      UsedSpot(name: ' ', usedAt: DateTime(2026, 9, 30)),
    ]);
    expect(spots.map((s) => s.name), ['parc', 'Quais']);
    expect((spots.first.lat, spots.first.lng), (1.0, 2.0));
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
