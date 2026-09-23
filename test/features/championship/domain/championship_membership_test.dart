import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/championship/domain/championship_membership.dart';

void main() {
  test('past memberships exclude the current season, most recent first', () {
    final past = pastMemberships([
      (associationId: 'lyon', season: '2024-2025'),
      (associationId: 'lyon', season: '2026-2027'),
      (associationId: 'lyon', season: '2025-2026'),
      (associationId: 'paris', season: '2025-2026'),
    ], '2026-2027');

    expect(past, [
      (associationId: 'lyon', season: '2025-2026'),
      (associationId: 'paris', season: '2025-2026'),
      (associationId: 'lyon', season: '2024-2025'),
    ]);
  });

  test('my association comes first within a season (Q88)', () {
    final past = pastMemberships(
      [
        (associationId: 'lyon', season: '2025-2026'),
        (associationId: 'paris', season: '2025-2026'),
        (associationId: 'lyon', season: '2024-2025'),
      ],
      '2026-2027',
      myAssociationId: 'paris',
    );

    expect(past, [
      (associationId: 'paris', season: '2025-2026'),
      (associationId: 'lyon', season: '2025-2026'),
      (associationId: 'lyon', season: '2024-2025'),
    ]);
  });

  test('current season championships: mine first, then the others', () {
    expect(
      seasonAssociationIds(
        [
          (associationId: 'lyon', season: '2026-2027'),
          (associationId: 'paris', season: '2026-2027'),
          (associationId: 'lyon', season: '2025-2026'),
          (associationId: 'morlaix', season: '2026-2027'),
        ],
        '2026-2027',
        'paris',
      ),
      ['paris', 'lyon', 'morlaix'],
    );
  });

  test('no past membership when everything is in the current season', () {
    expect(
      pastMemberships([
        (associationId: 'lyon', season: '2026-2027'),
      ], '2026-2027'),
      isEmpty,
    );
  });
}
