import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/history/domain/schedule_validation.dart';

void main() {
  final now = DateTime(2026, 9, 17, 12);

  test('accepts a schedule fully in the past with end after start', () {
    final error = validateSchedule(
      startedAt: DateTime(2026, 9, 16, 10),
      endedAt: DateTime(2026, 9, 16, 12),
      now: now,
    );
    expect(error, isNull);
  });

  test('rejects a start in the future', () {
    final error = validateSchedule(
      startedAt: DateTime(2026, 9, 18, 10),
      endedAt: DateTime(2026, 9, 18, 12),
      now: now,
    );
    expect(error, ScheduleError.startInFuture);
  });

  test('rejects an end in the future even if the start is valid', () {
    final error = validateSchedule(
      startedAt: DateTime(2026, 9, 16, 10),
      endedAt: DateTime(2026, 9, 18, 12),
      now: now,
    );
    expect(error, ScheduleError.endInFuture);
  });

  test('rejects an end at or before the start', () {
    final sameInstant = validateSchedule(
      startedAt: DateTime(2026, 9, 16, 10),
      endedAt: DateTime(2026, 9, 16, 10),
      now: now,
    );
    final before = validateSchedule(
      startedAt: DateTime(2026, 9, 16, 10),
      endedAt: DateTime(2026, 9, 16, 9),
      now: now,
    );
    expect(sameInstant, ScheduleError.endBeforeStart);
    expect(before, ScheduleError.endBeforeStart);
  });

  test('accepts a schedule ending exactly now', () {
    final error = validateSchedule(
      startedAt: DateTime(2026, 9, 16, 10),
      endedAt: now,
      now: now,
    );
    expect(error, isNull);
  });
}
