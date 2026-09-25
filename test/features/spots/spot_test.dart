import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/spots/domain/spot.dart';

void main() {
  const park = Spot(
    id: 'p',
    associationId: 'a',
    name: 'Parc Borély',
    address: 'Avenue du Prado, 13008 Marseille',
    locationLat: 43.26,
    locationLng: 5.38,
  );
  const quays = Spot(
    id: 'q',
    associationId: 'a',
    name: 'Vieux-Port',
    locationLat: 43.295,
    locationLng: 5.374,
  );
  const legacy = Spot(id: 'l', associationId: 'a', name: 'Anse');

  test('spotNamed ignores case and surrounding spaces (Q183)', () {
    expect(spotNamed([park, quays], '  parc BORÉLY '), park);
    expect(spotNamed([park, quays], 'Parc'), isNull);
  });

  test('sortSpots: nearest first, spots without a point last', () {
    final sorted = sortSpots([legacy, park, quays], lat: 43.296, lng: 5.37);
    expect(sorted.map((s) => s.id), ['q', 'p', 'l']);
  });

  test('sortSpots: alphabetical without a position', () {
    final sorted = sortSpots([quays, park, legacy]);
    expect(sorted.map((s) => s.id), ['l', 'p', 'q']);
  });

  test('a spot without a point or an address is to complete', () {
    expect(park.isIncomplete, isFalse);
    expect(quays.isIncomplete, isTrue);
    expect(legacy.isIncomplete, isTrue);
    // A variable location has neither on purpose (Q186).
    const surprise = Spot(
      id: 's',
      associationId: 'a',
      name: 'Surprise',
      variableLocation: true,
    );
    expect(surprise.isIncomplete, isFalse);
  });

  test('Spot reads its row', () {
    final spot = Spot.fromJson({
      'id': 's',
      'association_id': 'a',
      'name': 'INSA',
      'description': null,
      'address': '20 Avenue Albert Einstein, 69100 Villeurbanne',
      'city': 'Villeurbanne',
      'location_lat': 45.78,
      'location_lng': 4.87,
    });
    expect(spot.city, 'Villeurbanne');
    expect(spot.hasLocation, isTrue);
  });
}
