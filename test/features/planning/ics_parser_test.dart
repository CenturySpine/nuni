import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/planning/domain/ics/ics_parser.dart';

String _fixture(String name) =>
    File('test/fixtures/ics/$name').readAsStringSync();

void main() {
  // The import happens on 25 September 2026 at noon (UTC).
  final now = DateTime.utc(2026, 9, 25, 12);

  group('Google Agenda export', () {
    late List<IcsEvent> events;
    setUp(() => events = parseIcs(_fixture('google.ics'), now: now));

    List<IcsEvent> titled(String label) =>
        events.where((event) => event.label == label).toList();

    test('spreads a weekly outing over 12 months, one event per date', () {
      final thursdays = titled('Session du jeudi');
      // 52 Thursdays from 1 October 2026 to 23 September 2027, minus the
      // excluded date and the occurrence moved to a Saturday.
      expect(thursdays, hasLength(50));
      expect(thursdays.first.startsAt, DateTime.utc(2026, 10, 1, 17));
      expect(thursdays.last.startsAt, DateTime.utc(2027, 9, 23, 17));
    });

    test('keeps the wall-clock time across a daylight-saving change', () {
      final starts = titled('Session du jeudi').map((e) => e.startsAt);
      // 19:00 in Paris: 17:00 UTC in summer time, 18:00 UTC in winter time.
      expect(starts, contains(DateTime.utc(2026, 10, 22, 17)));
      expect(starts, contains(DateTime.utc(2026, 11, 5, 18)));
    });

    test('skips excluded dates and the ones moved elsewhere', () {
      final starts = titled('Session du jeudi').map((e) => e.startsAt);
      expect(starts, isNot(contains(DateTime.utc(2026, 10, 29, 18))));
      expect(starts, isNot(contains(DateTime.utc(2026, 10, 8, 17))));
      final moved = titled('Session du jeudi (décalée au samedi)');
      expect(moved.single.startsAt, DateTime.utc(2026, 10, 10, 8));
    });

    test('reads text fields unescaped and folded lines joined', () {
      final first = titled('Session du jeudi').first;
      expect(first.spot, "Parc de la Tête d'Or, Lyon");
      expect(
        first.description,
        'Rendez-vous devant la fontaine, apportez vos balles.\nInfos : '
        'https://lyonstreetgolf.fr',
      );
    });

    test('reads a UTC time and a GEO point', () {
      final dinner = titled('Repas de Noël').single;
      expect(dinner.startsAt, DateTime.utc(2026, 12, 12, 18));
      expect(dinner.lat, 45.7640);
      expect(dinner.lng, 4.8357);
      expect(dinner.spot, isNull);
    });

    test('starts an all-day event at local midnight', () {
      expect(
        titled('Assemblée générale').single.startsAt,
        DateTime(2026, 11, 21).toUtc(),
      );
    });

    test('leaves out cancelled and past events, sorts by date', () {
      expect(titled('Sortie annulée'), isEmpty);
      expect(titled('Sortie passée'), isEmpty);
      final starts = events.map((e) => e.startsAt).toList();
      expect(starts, [...starts]..sort());
    });
  });

  test('Apple Calendar export: monthly rank weekday with a count', () {
    final events = parseIcs(_fixture('apple.ics'), now: now);
    expect(events.map((e) => e.startsAt), [
      DateTime.utc(2026, 10, 3, 12),
      DateTime.utc(2026, 11, 7, 13),
      DateTime.utc(2026, 12, 5, 13),
    ]);
    expect(events.first.label, 'Tournoi du premier samedi');
    expect(events.first.spot, 'Berges du Rhône');
  });

  test('Outlook export: Windows zone name, quoted, interval and end date', () {
    final events = parseIcs(_fixture('outlook.ics'), now: now);
    final meeting = events.singleWhere((e) => e.label == 'Réunion du bureau');
    expect(meeting.startsAt, DateTime.utc(2026, 11, 5, 19));
    expect(
      meeting.description,
      'Ordre du jour : bilan de la saison, élections.',
    );
    expect(events.where((e) => e.label == 'Stage').map((e) => e.startsAt), [
      DateTime.utc(2026, 10, 20, 16, 30),
      DateTime.utc(2026, 10, 22, 16, 30),
      DateTime.utc(2026, 10, 24, 16, 30),
    ]);
  });

  test('an event without a title keeps a null label', () {
    const text =
        'BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\nDTSTART:20261001T100000Z\r\n'
        'END:VEVENT\r\nEND:VCALENDAR\r\n';
    expect(parseIcs(text, now: now).single.label, isNull);
  });

  group('icsTextsFromFile', () {
    test('reads an .ics file as is', () {
      final bytes = Uint8List.fromList(utf8.encode('BEGIN:VCALENDAR'));
      expect(icsTextsFromFile('agenda.ics', bytes), ['BEGIN:VCALENDAR']);
    });

    test('reads every .ics of a Google .zip export', () {
      final archive = Archive()
        ..addFile(ArchiveFile.string('Club_abc@group.ics', 'A'))
        ..addFile(ArchiveFile.string('Perso_xyz@gmail.com.ics', 'B'))
        ..addFile(ArchiveFile.string('readme.txt', 'C'));
      final bytes = Uint8List.fromList(ZipEncoder().encode(archive));
      expect(icsTextsFromFile('export.zip', bytes), ['A', 'B']);
    });
  });
}
