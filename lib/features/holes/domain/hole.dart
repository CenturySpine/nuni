import 'package:freezed_annotation/freezed_annotation.dart';

part 'hole.freezed.dart';
part 'hole.g.dart';

enum HoleVisibility {
  @JsonValue('public')
  public,
  @JsonValue('private')
  private,
}

/// One waypoint of the path drawn between a hole's start and end (PO,
/// 2026-09-18). Stored as a plain jsonb array on `holes.path`, ordered from
/// start to end.
@freezed
abstract class HolePathPoint with _$HolePathPoint {
  const factory HolePathPoint({required double lat, required double lng}) =
      _HolePathPoint;

  factory HolePathPoint.fromJson(Map<String, Object?> json) =>
      _$HolePathPointFromJson(json);
}

/// Mirrors the `holes` table (plan 03), read either as a plain row (`start_lat`
/// / `start_lng` are generated columns) or as a `holes_nearby` RPC row, which
/// adds `distance` (metres from the search point). `distanceM` is a different
/// thing: the hole's own length, an optional field the owner fills in.
@freezed
abstract class Hole with _$Hole {
  const factory Hole({
    required String id,
    required String name,
    String? description,
    required int par,
    @JsonKey(name: 'distance_m') int? distanceM,
    // Null only for a hole imported from LsgScores (plan 13, Q49) whose
    // position the PO hasn't set yet; the app itself always writes one.
    @JsonKey(name: 'start_lat') double? startLat,
    @JsonKey(name: 'start_lng') double? startLng,
    // Target point (PO, 2026-09-16): optional.
    @JsonKey(name: 'end_lat') double? endLat,
    @JsonKey(name: 'end_lng') double? endLng,
    // Intermediate waypoints between start and end (PO, 2026-09-18), drawn as
    // a line on the hole's map.
    List<HolePathPoint>? path,
    @JsonKey(name: 'photo_start_path') String? photoStartPath,
    @JsonKey(name: 'photo_end_path') String? photoEndPath,
    required HoleVisibility visibility,
    @JsonKey(name: 'owner_id') required String ownerId,
    // Only present on `holes_nearby` rows: distance from the search point, in metres.
    double? distance,
  }) = _Hole;

  factory Hole.fromJson(Map<String, Object?> json) => _$HoleFromJson(json);
}

extension HolePosition on Hole {
  /// False only for a hole imported from LsgScores not repositioned yet
  /// (plan 13, Q49): kept off every map and out of "around me".
  bool get hasPosition => startLat != null && startLng != null;
}
