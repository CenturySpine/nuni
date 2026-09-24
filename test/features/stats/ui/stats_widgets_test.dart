import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/stats/ui/stats_widgets.dart';

void main() {
  const seasons = ['2025-2026', '2024-2025'];

  test('opens on the most recent season played', () {
    expect(
      displayedSeason(seasons: seasons, allTime: false, picked: null),
      '2025-2026',
    );
  });

  test('keeps the season or "all time" the viewer picked', () {
    expect(
      displayedSeason(seasons: seasons, allTime: false, picked: '2024-2025'),
      '2024-2025',
    );
    expect(
      displayedSeason(seasons: seasons, allTime: true, picked: null),
      isNull,
    );
  });

  test('no season played: all time', () {
    expect(
      displayedSeason(seasons: const [], allTime: false, picked: null),
      isNull,
    );
  });
}
