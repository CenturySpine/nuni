import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/text/compare_names.dart';
import '../../associations/domain/association.dart';

part 'spot.freezed.dart';
part 'spot.g.dart';

/// Mirrors the `spots` table (plan 28): one of an association's playing
/// spots. A spot with a variable location (Q186, "Surprise") has no point:
/// each event and session keeps its own. The point is otherwise missing only
/// for a spot taken over from a place typed before plan 28 (Q185), shown "to
/// complete".
@freezed
abstract class Spot with _$Spot {
  const Spot._();

  const factory Spot({
    required String id,
    @JsonKey(name: 'association_id') required String associationId,
    required String name,
    String? description,
    String? address,
    String? city,
    @JsonKey(name: 'location_lat') double? locationLat,
    @JsonKey(name: 'location_lng') double? locationLng,
    @JsonKey(name: 'variable_location') @Default(false) bool variableLocation,
  }) = _Spot;

  factory Spot.fromJson(Map<String, Object?> json) => _$SpotFromJson(json);

  bool get hasLocation => locationLat != null && locationLng != null;

  /// A point or an address is missing (Q181, Q185) -- never for a variable
  /// location, which has neither on purpose (Q186).
  bool get isIncomplete =>
      !variableLocation && (!hasLocation || address == null);
}

/// The longest name the base accepts.
const spotNameMaxLength = 80;

/// The key two spot names are compared on, as the base's unique index does
/// (Q183): trimmed, ignoring case.
String spotNameKey(String name) => name.trim().toLowerCase();

/// The spot of [spots] named [name] (Q183), or null.
Spot? spotNamed(Iterable<Spot> spots, String name) {
  final key = spotNameKey(name);
  for (final spot in spots) {
    if (spotNameKey(spot.name) == key) return spot;
  }
  return null;
}

/// The session form's list (plan 28): nearest first when the position is
/// known, spots without a point after them, alphabetically otherwise.
List<Spot> sortSpots(List<Spot> spots, {double? lat, double? lng}) {
  int byName(Spot a, Spot b) => compareNames(a.name, b.name);
  final sorted = [...spots];
  if (lat == null || lng == null) return sorted..sort(byName);
  double distance(Spot s) => s.hasLocation
      ? distanceKm(lat, lng, s.locationLat!, s.locationLng!)
      : double.infinity;
  return sorted..sort((a, b) {
    final byDistance = distance(a).compareTo(distance(b));
    return byDistance != 0 ? byDistance : byName(a, b);
  });
}
