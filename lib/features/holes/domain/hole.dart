import 'package:freezed_annotation/freezed_annotation.dart';

part 'hole.freezed.dart';
part 'hole.g.dart';

enum HoleVisibility {
  @JsonValue('public')
  public,
  @JsonValue('private')
  private,
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
    @JsonKey(name: 'start_lat') required double startLat,
    @JsonKey(name: 'start_lng') required double startLng,
    // Target point (PO, 2026-09-16): optional, captured for a future path
    // line between start and end -- not drawn yet.
    @JsonKey(name: 'end_lat') double? endLat,
    @JsonKey(name: 'end_lng') double? endLng,
    @JsonKey(name: 'photo_start_path') String? photoStartPath,
    @JsonKey(name: 'photo_end_path') String? photoEndPath,
    required HoleVisibility visibility,
    @JsonKey(name: 'owner_id') required String ownerId,
    // Only present on `holes_nearby` rows: distance from the search point, in metres.
    double? distance,
  }) = _Hole;

  factory Hole.fromJson(Map<String, Object?> json) => _$HoleFromJson(json);
}
