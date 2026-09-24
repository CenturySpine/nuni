import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/holes/domain/hole.dart';

void main() {
  test('Hole.fromJson reads a plain "holes" row (no proximity distance)', () {
    final hole = Hole.fromJson({
      'id': 'h1',
      'name': 'Le Ficus',
      'description': null,
      'par': 3,
      'distance_m': 120,
      'start_lat': 48.8534,
      'start_lng': 2.3488,
      'photo_start_path': null,
      'photo_end_path': null,
      'owner_id': 'u1',
    });

    expect(hole.id, 'h1');
    expect(hole.name, 'Le Ficus');
    expect(hole.par, 3);
    expect(hole.distanceM, 120);
    expect(hole.startLat, 48.8534);
    expect(hole.startLng, 2.3488);
    expect(hole.clonedFrom, isNull);
    expect(hole.ownerId, 'u1');
    expect(hole.distance, isNull);
  });

  test(
    'Hole.fromJson reads a "holes_nearby" row, with the proximity distance',
    () {
      final hole = Hole.fromJson({
        'id': 'h1',
        'name': 'Le Ficus',
        'par': 3,
        'distance_m': null,
        'start_lat': 48.8534,
        'start_lng': 2.3488,
        'owner_id': 'u1',
        'distance': 240.7,
      });

      expect(hole.distanceM, isNull);
      expect(hole.distance, 240.7);
    },
  );

  test('Hole.fromJson reads a hole imported without a position (plan 13)', () {
    final hole = Hole.fromJson({
      'id': 'h2',
      'name': 'Vieux trou',
      'par': 3,
      'start_lat': null,
      'start_lng': null,
      'owner_id': 'u1',
    });

    expect(hole.startLat, isNull);
    expect(hole.hasPosition, isFalse);
  });

  test('Hole.fromJson reads the hole a clone comes from (plan 26)', () {
    final hole = Hole.fromJson({
      'id': 'h3',
      'name': 'Clone - Le Ficus',
      'par': 3,
      'owner_id': 'u2',
      'cloned_from': 'h1',
    });

    expect(hole.clonedFrom, 'h1');
  });

  test('hasPosition is true once the start is set', () {
    const hole = Hole(
      id: 'h1',
      name: 'Le Ficus',
      par: 3,
      startLat: 48.8534,
      startLng: 2.3488,
      ownerId: 'u1',
    );

    expect(hole.hasPosition, isTrue);
  });
}
