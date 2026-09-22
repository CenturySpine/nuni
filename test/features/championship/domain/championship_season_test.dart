import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/championship/domain/championship_season.dart';

void main() {
  group('championshipSeasonFor', () {
    test('September starts the season named after that year', () {
      expect(championshipSeasonFor(DateTime(2026, 9, 1)), '2026-2027');
    });

    test('a later month within the same season stays in it', () {
      expect(championshipSeasonFor(DateTime(2027, 3, 15)), '2026-2027');
    });

    test(
      'August still belongs to the season started the previous September',
      () {
        expect(championshipSeasonFor(DateTime(2026, 8, 31)), '2025-2026');
      },
    );

    test('boundary between two consecutive seasons', () {
      expect(championshipSeasonFor(DateTime(2026, 8, 31, 23, 59)), '2025-2026');
      expect(championshipSeasonFor(DateTime(2026, 9, 1, 0, 0)), '2026-2027');
    });
  });
}
