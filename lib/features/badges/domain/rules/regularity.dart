import '../badge.dart';
import '../badge_facts.dart';
import 'tracker.dart';

/// Monday-to-Sunday week number of a local date (plan 21, "Semaine"),
/// counted from Monday 5 January 1970 on calendar days, so a
/// daylight-saving change never shifts it.
int weekIndex(DateTime date) =>
    DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime.utc(1970, 1, 5)).inDays ~/
    7;

/// Meteorological season of a date (B4): 0 winter (December to February),
/// 1 spring, 2 summer, 3 autumn.
int yearSeasonOf(DateTime date) => (date.month % 12) ~/ 3;

/// B. Regularity: consecutive weeks (B1, B2), a busy week (B3), the four
/// seasons (B4), a veteran still playing (B5), every month (B6).
List<BadgeResult> regularityBadges(BadgeFacts facts) {
  final appointment = BadgeTracker(BadgeId.appointment);
  final metronome = BadgeTracker(BadgeId.metronome);
  final busyWeek = BadgeTracker(BadgeId.busyWeek);
  final fourSeasons = BadgeTracker(BadgeId.fourSeasons);
  final veteran = BadgeTracker(BadgeId.veteran);
  final allYear = BadgeTracker(BadgeId.allYear);

  final weeks = <int, int>{};
  final seasons = <int>{};
  final months = <int>{};

  for (final session in facts.sessions) {
    final week = weekIndex(session.date);
    weeks[week] = (weeks[week] ?? 0) + 1;
    // The run of consecutive weeks ending with this one.
    var run = 1;
    while (weeks.containsKey(week - run)) {
      run++;
    }
    appointment.reach(run, session);
    metronome.reach(run, session);
    busyWeek.reach(weeks[week]!, session);

    seasons.add(yearSeasonOf(session.date));
    fourSeasons.reach(seasons.length, session);
    months.add(session.date.month);
    allYear.reach(months.length, session);

    // B5: when a session is played more than a year after the first one,
    // both conditions hold at that moment (first session over a year ago,
    // one in the last three months: this one). Judged on that session, so
    // the badge doesn't depend on the day one looks and stays (Q111).
    final first = facts.sessions.first.date;
    final anniversary = DateTime(first.year + 1, first.month, first.day);
    if (session.date.isAfter(anniversary)) veteran.hit(session);
  }

  return [
    appointment,
    metronome,
    busyWeek,
    fourSeasons,
    veteran,
    allYear,
  ].results();
}
