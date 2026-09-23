import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/associations/domain/association.dart';

Association _association(String id, String name, double lat, double lng) =>
    Association(
      id: id,
      name: name,
      city: name,
      locationLat: lat,
      locationLng: lng,
      status: AssociationStatus.approved,
    );

void main() {
  final lyon = _association('lyon', 'Lyon Street Golf', 45.749, 4.8459);
  final morlaix = _association(
    'morlaix',
    "Street Golf à l'Ouest",
    48.577,
    -3.827,
  );
  final grenoble = _association('grenoble', 'Wild Shrimp Crew', 45.188, 5.724);

  test('label is the abbreviation when there is one, else the name', () {
    expect(lyon.copyWith(shortName: 'LSG').label, 'LSG');
    expect(lyon.copyWith(shortName: '  ').label, 'Lyon Street Golf');
    expect(lyon.label, 'Lyon Street Golf');
  });

  test('distanceKm is close to the real distance Lyon - Grenoble', () {
    final km = distanceKm(45.749, 4.8459, 45.188, 5.724);
    expect(km, closeTo(94, 5));
  });

  test('the choice list puts the nearest association first', () {
    // A player in Grenoble.
    final sorted = sortForChoice(
      [morlaix, lyon, grenoble],
      lat: 45.19,
      lng: 5.72,
    );
    expect([for (final a in sorted) a.id], ['grenoble', 'lyon', 'morlaix']);
  });

  test('without a position, the choice list is alphabetical', () {
    final sorted = sortForChoice([grenoble, morlaix, lyon]);
    expect([for (final a in sorted) a.id], ['lyon', 'morlaix', 'grenoble']);
  });

  test('the directory puts my association first, then alphabetical', () {
    final sorted = sortForDirectory([lyon, grenoble, morlaix], 'grenoble');
    expect([for (final a in sorted) a.id], ['grenoble', 'lyon', 'morlaix']);
  });
}
