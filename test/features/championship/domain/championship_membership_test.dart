import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/championship/domain/championship_membership.dart';

void main() {
  test('past memberships exclude the current season, most recent first', () {
    final past = pastMemberships([
      (zoneId: 'lyon', season: '2024-2025'),
      (zoneId: 'lyon', season: '2026-2027'),
      (zoneId: 'lyon', season: '2025-2026'),
      (zoneId: 'paris', season: '2025-2026'),
    ], '2026-2027');

    expect(past, [
      (zoneId: 'lyon', season: '2025-2026'),
      (zoneId: 'paris', season: '2025-2026'),
      (zoneId: 'lyon', season: '2024-2025'),
    ]);
  });

  test('no past membership when everything is in the current season', () {
    expect(
      pastMemberships([(zoneId: 'lyon', season: '2026-2027')], '2026-2027'),
      isEmpty,
    );
  });
}
