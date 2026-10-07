import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/live/domain/game_mode.dart';
import 'package:nuni/features/live/domain/hole_order.dart';
import 'package:nuni/features/live/domain/live_team.dart';
import 'package:nuni/features/live/domain/played_hole.dart';

LiveTeam _team(String id) =>
    LiveTeam(id: id, position: int.parse(id), players: const []);

PlayedHole _hole(int position, [Map<String, int> values = const {}]) =>
    PlayedHole(
      id: 'h$position',
      position: position,
      gameMode: GameMode.individual,
      par: 3,
      scores: [
        for (final entry in values.entries)
          HoleScore(teamId: entry.key, value: entry.value),
      ],
    );

List<int> _places(List<PlayedHole> holes) => [
  for (final hole in holes) hole.position,
];

void main() {
  group('holesInDisplayOrder (plan 37, Q267)', () {
    final holes = [_hole(2), _hole(1), _hole(3)];

    test('by default, the most recent place on top, as before', () {
      expect(_places(holesInDisplayOrder(holes, ascending: false)), [3, 2, 1]);
    });

    test('reversed, hole 1 on top', () {
      expect(_places(holesInDisplayOrder(holes, ascending: true)), [1, 2, 3]);
    });
  });

  group('currentHole (plan 37, Q268)', () {
    final teams = [_team('1'), _team('2')];

    test('none without holes', () {
      expect(currentHole(const [], teams), isNull);
    });

    test('the first hole of the course a team has not scored yet', () {
      final holes = [
        _hole(3),
        _hole(1, {'1': 3, '2': 4}),
        _hole(2, {'1': 5}),
      ];
      expect(currentHole(holes, teams)?.position, 2);
    });

    test('holes added as played: the latest one, as before', () {
      final holes = [
        _hole(1, {'1': 3, '2': 4}),
        _hole(2, {'1': 2, '2': 3}),
        _hole(3),
      ];
      expect(currentHole(holes, teams)?.position, 3);
    });

    test('everything scored: the last hole of the course', () {
      final holes = [
        _hole(2, {'1': 2, '2': 3}),
        _hole(1, {'1': 3, '2': 4}),
      ];
      expect(currentHole(holes, teams)?.position, 2);
    });
  });

  group('coursePlaceForDrop (plan 37, Q265)', () {
    test('hole 1 on top: the shown place is the course place', () {
      // [1, 2, 3, 4]: hole 1 dropped between holes 3 and 4 -> [2, 3, 1, 4].
      expect(coursePlaceForDrop(count: 4, shownIndex: 2, ascending: true), 3);
      // Hole 4 dragged to the top becomes the 1st.
      expect(coursePlaceForDrop(count: 4, shownIndex: 0, ascending: true), 1);
    });

    test('most recent on top: the shown order is the course reversed', () {
      // [4, 3, 2, 1]: hole 4 dropped at the bottom becomes the 1st.
      expect(coursePlaceForDrop(count: 4, shownIndex: 3, ascending: false), 1);
      // Hole 1 dragged to the top becomes the 4th, the last.
      expect(coursePlaceForDrop(count: 4, shownIndex: 0, ascending: false), 4);
      // Hole 2 dropped between holes 4 and 3 -> [4, 2, 3, 1]: the 3rd.
      expect(coursePlaceForDrop(count: 4, shownIndex: 1, ascending: false), 3);
    });
  });
}
