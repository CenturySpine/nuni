import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// One event read from an agenda file (plan 23), ready to import: a single
/// dated occurrence -- NUNI has no notion of repetition (Q154), a repeated
/// event of the file becomes one of these per date (Q167).
class IcsEvent {
  const IcsEvent({
    required this.startsAt,
    this.label,
    this.spot,
    this.lat,
    this.lng,
    this.description,
  });

  /// In UTC.
  final DateTime startsAt;

  /// Null when the file's event has no title: the import screen names it.
  final String? label;
  final String? spot;
  final double? lat;
  final double? lng;
  final String? description;
}

/// The agenda texts of a picked file (Q153): an `.ics` as is, or every
/// `.ics` inside a `.zip` (Google Agenda's export, one file per agenda).
List<String> icsTextsFromFile(String fileName, Uint8List bytes) {
  if (fileName.toLowerCase().endsWith('.zip')) {
    final archive = ZipDecoder().decodeBytes(bytes);
    return [
      for (final file in archive.files)
        if (file.isFile && file.name.toLowerCase().endsWith('.ics'))
          utf8.decode(file.content, allowMalformed: true),
    ];
  }
  return [utf8.decode(bytes, allowMalformed: true)];
}

/// How far ahead a repeated event is spread (Q167).
const repeatHorizon = Duration(days: 366);

/// Reads every event of [text] (iCalendar, RFC 5545) that starts after
/// [now]: past ones are left out (plan 23, decision 14), a repeated event
/// gives one [IcsEvent] per date up to [now] + [repeatHorizon], its excluded
/// dates skipped, and a single occurrence edited in the source agenda
/// (`RECURRENCE-ID`) replaces the date it was moved from. Cancelled events
/// are left out. Sorted by date.
///
/// Times are converted exactly: in UTC (`...Z`), in a named time zone
/// (`TZID=Europe/Paris`, or a Windows zone name as Outlook writes them) or,
/// with neither, in the device's own time. An all-day event starts at
/// midnight.
List<IcsEvent> parseIcs(String text, {required DateTime now}) {
  _ensureTimeZones();
  final components = _components(_unfold(text));
  final horizon = now.add(repeatHorizon);

  // Occurrences edited on their own, per series: their original date is
  // skipped when the series is spread.
  final overridden = <String, Set<DateTime>>{};
  for (final c in components) {
    final recurrenceId = c.first('RECURRENCE-ID');
    final uid = c.value('UID');
    if (recurrenceId == null || uid == null) continue;
    final at = _parseDate(recurrenceId);
    if (at != null) (overridden[uid] ??= {}).add(at);
  }

  final events = <IcsEvent>[];
  for (final c in components) {
    if (c.value('STATUS')?.toUpperCase() == 'CANCELLED') continue;
    final startProperty = c.first('DTSTART');
    if (startProperty == null) continue;
    final start = _parseWall(startProperty);
    if (start == null) continue;

    final geo = _parseGeo(c.value('GEO'));
    IcsEvent occurrence(DateTime at) => IcsEvent(
      startsAt: at,
      label: _text(c.value('SUMMARY')),
      spot: _text(c.value('LOCATION')),
      lat: geo?.$1,
      lng: geo?.$2,
      description: _text(c.value('DESCRIPTION')),
    );

    final rule = c.value('RRULE');
    if (rule == null || c.first('RECURRENCE-ID') != null) {
      final at = start.toUtc();
      if (at.isAfter(now)) events.add(occurrence(at));
      continue;
    }

    final excluded = <DateTime>{
      ...?overridden[c.value('UID')],
      for (final property in c.all('EXDATE'))
        for (final part in property.value.split(','))
          ?_parseDate(_Property(property.name, property.params, part)),
    };
    for (final at in _expand(start, _Rule.parse(rule), horizon)) {
      if (!at.isAfter(now) || excluded.contains(at)) continue;
      events.add(occurrence(at));
    }
  }
  events.sort((a, b) => a.startsAt.compareTo(b.startsAt));
  return events;
}

// ---------------------------------------------------------------------------
// Lines and components
// ---------------------------------------------------------------------------

/// Joins folded lines: a line starting with a space or a tab continues the
/// previous one (RFC 5545, 3.1).
List<String> _unfold(String text) {
  final lines = <String>[];
  for (final raw in text.split(RegExp(r'\r\n|\n|\r'))) {
    if ((raw.startsWith(' ') || raw.startsWith('\t')) && lines.isNotEmpty) {
      lines.last += raw.substring(1);
    } else if (raw.isNotEmpty) {
      lines.add(raw);
    }
  }
  return lines;
}

class _Property {
  const _Property(this.name, this.params, this.value);

  final String name;
  final Map<String, String> params;
  final String value;

  static _Property? parse(String line) {
    // The value starts after the first colon outside a quoted parameter.
    var inQuotes = false;
    var colon = -1;
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') inQuotes = !inQuotes;
      if (char == ':' && !inQuotes) {
        colon = i;
        break;
      }
    }
    if (colon < 0) return null;
    final head = line.substring(0, colon).split(';');
    final params = <String, String>{};
    for (final param in head.skip(1)) {
      final equals = param.indexOf('=');
      if (equals < 0) continue;
      params[param.substring(0, equals).toUpperCase()] = param
          .substring(equals + 1)
          .replaceAll('"', '');
    }
    return _Property(
      head.first.toUpperCase(),
      params,
      line.substring(colon + 1),
    );
  }
}

class _Component {
  final List<_Property> properties = [];

  _Property? first(String name) {
    for (final property in properties) {
      if (property.name == name) return property;
    }
    return null;
  }

  Iterable<_Property> all(String name) =>
      properties.where((property) => property.name == name);

  String? value(String name) => first(name)?.value;
}

/// The VEVENT components, their nested ones (alarms) left out.
List<_Component> _components(List<String> lines) {
  final events = <_Component>[];
  _Component? current;
  var nested = 0;
  for (final line in lines) {
    final upper = line.toUpperCase();
    if (upper == 'BEGIN:VEVENT') {
      current = _Component();
      nested = 0;
    } else if (upper == 'END:VEVENT') {
      if (current != null) events.add(current);
      current = null;
    } else if (current != null) {
      if (upper.startsWith('BEGIN:')) {
        nested++;
      } else if (upper.startsWith('END:')) {
        nested--;
      } else if (nested == 0) {
        final property = _Property.parse(line);
        if (property != null) current.properties.add(property);
      }
    }
  }
  return events;
}

/// A TEXT value unescaped (RFC 5545, 3.3.11), null when blank.
String? _text(String? value) {
  if (value == null) return null;
  final buffer = StringBuffer();
  for (var i = 0; i < value.length; i++) {
    final char = value[i];
    if (char == r'\' && i + 1 < value.length) {
      final next = value[++i];
      buffer.write(switch (next) {
        'n' || 'N' => '\n',
        _ => next,
      });
    } else {
      buffer.write(char);
    }
  }
  final text = buffer.toString().trim();
  return text.isEmpty ? null : text;
}

(double, double)? _parseGeo(String? value) {
  if (value == null) return null;
  final parts = value.split(RegExp('[;,]'));
  if (parts.length != 2) return null;
  final lat = double.tryParse(parts[0].trim());
  final lng = double.tryParse(parts[1].trim());
  if (lat == null || lng == null) return null;
  return (lat, lng);
}

// ---------------------------------------------------------------------------
// Dates
// ---------------------------------------------------------------------------

bool _timeZonesReady = false;

void _ensureTimeZones() {
  if (_timeZonesReady) return;
  tz_data.initializeTimeZones();
  _timeZonesReady = true;
}

/// Windows time zone names, as Outlook writes them in `TZID`, for the zones
/// NUNI's associations live in; any other unknown name falls back to the
/// device's time.
const _windowsZones = {
  'romance standard time': 'Europe/Paris',
  'w. europe standard time': 'Europe/Berlin',
  'central europe standard time': 'Europe/Budapest',
  'central european standard time': 'Europe/Warsaw',
  'gmt standard time': 'Europe/London',
  'greenwich standard time': 'Atlantic/Reykjavik',
  'utc': 'UTC',
};

/// A date-time as written in the file: its wall-clock fields and how to
/// turn them into an instant. Repeats are computed on the wall clock, so a
/// weekly 19:00 stays at 19:00 across a daylight-saving change.
class _Wall {
  const _Wall(this.fields, this.zone);

  /// Year to second, as a UTC [DateTime] used as a plain field holder.
  final DateTime fields;

  /// 'UTC', a time zone, or null for the device's own time.
  final tz.Location? zone;
  static final utc = tz.UTC;

  DateTime toUtc() {
    final f = fields;
    if (zone == null) {
      return DateTime(
        f.year,
        f.month,
        f.day,
        f.hour,
        f.minute,
        f.second,
      ).toUtc();
    }
    // A plain DateTime, not a TZDateTime: the latter only equals another
    // TZDateTime, which breaks set lookups against the excluded dates.
    return DateTime.fromMillisecondsSinceEpoch(
      tz.TZDateTime(
        zone!,
        f.year,
        f.month,
        f.day,
        f.hour,
        f.minute,
        f.second,
      ).millisecondsSinceEpoch,
      isUtc: true,
    );
  }

  _Wall withFields(DateTime fields) => _Wall(fields, zone);
}

_Wall? _parseWall(_Property property) {
  final match = RegExp(
    r'^(\d{4})(\d{2})(\d{2})(?:T(\d{2})(\d{2})(\d{2})(Z)?)?$',
  ).firstMatch(property.value.trim());
  if (match == null) return null;
  int field(int group) => int.parse(match.group(group) ?? '0');
  final fields = DateTime.utc(
    field(1),
    field(2),
    field(3),
    field(4),
    field(5),
    field(6),
  );
  if (match.group(7) != null) return _Wall(fields, _Wall.utc);
  final tzid = property.params['TZID'];
  return _Wall(fields, tzid == null ? null : _location(tzid));
}

tz.Location? _location(String tzid) {
  final name = tzid.trim();
  try {
    return tz.getLocation(name);
  } on tz.LocationNotFoundException {
    final windows = _windowsZones[name.toLowerCase()];
    return windows == null ? null : tz.getLocation(windows);
  }
}

DateTime? _parseDate(_Property property) => _parseWall(property)?.toUtc();

// ---------------------------------------------------------------------------
// Repeats (RRULE, RFC 5545 3.3.10): the subset agenda apps write for a
// club's outings -- daily, weekly, monthly and yearly, with an interval, a
// count or an end date, weekdays (with a rank for monthly: "1TH", "-1FR")
// and days of the month.
// ---------------------------------------------------------------------------

const _weekdays = {
  'MO': DateTime.monday,
  'TU': DateTime.tuesday,
  'WE': DateTime.wednesday,
  'TH': DateTime.thursday,
  'FR': DateTime.friday,
  'SA': DateTime.saturday,
  'SU': DateTime.sunday,
};

class _Rule {
  const _Rule({
    required this.frequency,
    required this.interval,
    this.count,
    this.until,
    this.byDay = const [],
    this.byMonthDay = const [],
  });

  final String frequency;
  final int interval;
  final int? count;
  final DateTime? until;

  /// (rank or 0, weekday).
  final List<(int, int)> byDay;
  final List<int> byMonthDay;

  static _Rule parse(String value) {
    final parts = <String, String>{};
    for (final part in value.split(';')) {
      final equals = part.indexOf('=');
      if (equals > 0) {
        parts[part.substring(0, equals).toUpperCase()] = part.substring(
          equals + 1,
        );
      }
    }
    final byDay = <(int, int)>[];
    for (final day in (parts['BYDAY'] ?? '').split(',')) {
      final match = RegExp(r'^([+-]?\d+)?([A-Z]{2})$').firstMatch(day.trim());
      final weekday = match == null ? null : _weekdays[match.group(2)];
      if (weekday != null) {
        byDay.add((int.tryParse(match!.group(1) ?? '') ?? 0, weekday));
      }
    }
    final untilValue = parts['UNTIL'];
    return _Rule(
      frequency: (parts['FREQ'] ?? '').toUpperCase(),
      interval: int.tryParse(parts['INTERVAL'] ?? '') ?? 1,
      count: int.tryParse(parts['COUNT'] ?? ''),
      until: untilValue == null
          ? null
          : _parseDate(_Property('UNTIL', const {}, untilValue)),
      byDay: byDay,
      byMonthDay: [
        for (final day in (parts['BYMONTHDAY'] ?? '').split(','))
          ?int.tryParse(day.trim()),
      ],
    );
  }
}

/// The occurrences of [start] under [rule], in UTC, first one included, up to
/// [horizon] (and the rule's own count or end date).
Iterable<DateTime> _expand(_Wall start, _Rule rule, DateTime horizon) sync* {
  final interval = rule.interval < 1 ? 1 : rule.interval;
  final first = start.fields;
  var emitted = 0;

  bool done(DateTime at) =>
      at.isAfter(horizon) ||
      (rule.until != null && at.isAfter(rule.until!)) ||
      (rule.count != null && emitted >= rule.count!);

  // Each period (day, week, month or year) gives its candidate dates, in
  // order; the ones before the first occurrence are skipped.
  for (var period = 0; period < 5000; period++) {
    final candidates = _periodDates(first, rule, period * interval);
    if (candidates == null) return;
    for (final fields in candidates) {
      if (fields.isBefore(first)) continue;
      final at = start.withFields(fields).toUtc();
      if (done(at)) return;
      emitted++;
      yield at;
    }
  }
}

/// The wall-clock dates of the period [offset] periods after [first]'s, at
/// [first]'s time of day; null for an unsupported frequency.
List<DateTime>? _periodDates(DateTime first, _Rule rule, int offset) {
  DateTime at(int year, int month, int day) =>
      DateTime.utc(year, month, day, first.hour, first.minute, first.second);

  switch (rule.frequency) {
    case 'DAILY':
      return [at(first.year, first.month, first.day + offset)];
    case 'WEEKLY':
      final monday = at(
        first.year,
        first.month,
        first.day - (first.weekday - DateTime.monday) + offset * 7,
      );
      final weekdays = rule.byDay.isEmpty
          ? [first.weekday]
          : ([for (final (_, weekday) in rule.byDay) weekday]..sort());
      return [
        for (final weekday in weekdays)
          at(monday.year, monday.month, monday.day + weekday - DateTime.monday),
      ];
    case 'MONTHLY':
      final month = DateTime.utc(first.year, first.month + offset);
      return _monthDates(month.year, month.month, first, rule, at);
    case 'YEARLY':
      final year = first.year + offset;
      final day = at(year, first.month, first.day);
      // 29 February only exists in leap years.
      return day.month == first.month ? [day] : [];
    default:
      return null;
  }
}

List<DateTime> _monthDates(
  int year,
  int month,
  DateTime first,
  _Rule rule,
  DateTime Function(int, int, int) at,
) {
  final daysInMonth = DateTime.utc(year, month + 1, 0).day;
  final days = <int>{};
  for (final day in rule.byMonthDay) {
    final resolved = day > 0 ? day : daysInMonth + day + 1;
    if (resolved >= 1 && resolved <= daysInMonth) days.add(resolved);
  }
  for (final (rank, weekday) in rule.byDay) {
    final matching = [
      for (var day = 1; day <= daysInMonth; day++)
        if (DateTime.utc(year, month, day).weekday == weekday) day,
    ];
    if (rank == 0) {
      days.addAll(matching);
    } else {
      final index = rank > 0 ? rank - 1 : matching.length + rank;
      if (index >= 0 && index < matching.length) days.add(matching[index]);
    }
  }
  if (rule.byMonthDay.isEmpty && rule.byDay.isEmpty) {
    if (first.day <= daysInMonth) days.add(first.day);
  }
  return [for (final day in days.toList()..sort()) at(year, month, day)];
}
