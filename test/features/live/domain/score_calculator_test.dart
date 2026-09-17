import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/live/domain/score_calculator.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';

void main() {
  group('calculateHolePoints - stroke play', () {
    test('is a pass-through (LsgScores ClassicScoringCalculator)', () {
      expect(
        calculateHolePoints(ScoringMode.strokePlay, {'1': 4, '2': 3, '3': 5}),
        {'1': 4, '2': 3, '3': 5},
      );
    });
  });

  group('calculateHolePoints - match play', () {
    test('sole lowest scores 1, everyone else 0', () {
      expect(
        calculateHolePoints(ScoringMode.matchPlay, {'1': 2, '2': 5, '3': 4}),
        {'1': 1, '2': 0, '3': 0},
      );
    });

    test('a tie for lowest scores everyone 0', () {
      expect(
        calculateHolePoints(ScoringMode.matchPlay, {'1': 3, '2': 3, '3': 4}),
        {'1': 0, '2': 0, '3': 0},
      );
    });
  });

  group('calculateHolePoints - redistribution', () {
    test('sole leader scores 2, sole runner-up scores 1', () {
      expect(
        calculateHolePoints(ScoringMode.redistribution, {
          '1': 2,
          '2': 4,
          '3': 3,
        }),
        {'1': 2, '2': 0, '3': 1},
      );
    });

    test('two tied leaders score 1 each, a clear third also scores 1', () {
      expect(
        calculateHolePoints(ScoringMode.redistribution, {
          '1': 3,
          '2': 3,
          '3': 4,
        }),
        {'1': 1, '2': 1, '3': 1},
      );
    });

    test('three or more tied for the lead score 0', () {
      expect(
        calculateHolePoints(ScoringMode.redistribution, {
          '1': 2,
          '2': 2,
          '3': 2,
          '4': 3,
        }),
        {'1': 0, '2': 0, '3': 0, '4': 0},
      );
    });

    test('sole leader but a tie for second gives no second-place point', () {
      expect(
        calculateHolePoints(ScoringMode.redistribution, {
          '1': 2,
          '2': 3,
          '3': 3,
        }),
        {'1': 2, '2': 0, '3': 0},
      );
    });

    test('two tied leaders with no team behind them', () {
      expect(
        calculateHolePoints(ScoringMode.redistribution, {'1': 3, '2': 3}),
        {'1': 1, '2': 1},
      );
    });
  });

  group('calculateHolePoints - free', () {
    test('is a pass-through: the entered value already is the points', () {
      expect(calculateHolePoints(ScoringMode.free, {'1': 10, '2': 0, '3': 7}), {
        '1': 10,
        '2': 0,
        '3': 7,
      });
    });
  });
}
