/// Validates an edited session schedule (plan 10): neither end in the
/// future, and the end after the start. Pure so the rule is unit-testable
/// without a widget; the edit screen calls this on submit.
enum ScheduleError { startInFuture, endInFuture, endBeforeStart }

ScheduleError? validateSchedule({
  required DateTime startedAt,
  required DateTime endedAt,
  required DateTime now,
}) {
  if (startedAt.isAfter(now)) return ScheduleError.startInFuture;
  if (endedAt.isAfter(now)) return ScheduleError.endInFuture;
  if (!endedAt.isAfter(startedAt)) return ScheduleError.endBeforeStart;
  return null;
}
