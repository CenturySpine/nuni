import 'package:freezed_annotation/freezed_annotation.dart';

import '../../holes/domain/hole.dart';
import 'game_mode.dart';

part 'played_hole.freezed.dart';
part 'played_hole.g.dart';

/// Just enough of a played hole's own `holes` row to show it on a card
/// (plan 08) -- not the full [Hole] model, which carries fields (owner,
/// photos, description...) this screen never needs.
@freezed
abstract class PlayedHoleGeo with _$PlayedHoleGeo {
  const factory PlayedHoleGeo({
    required String id,
    required String name,
    required int par,
    @JsonKey(name: 'start_lat') required double startLat,
    @JsonKey(name: 'start_lng') required double startLng,
    required HoleVisibility visibility,
  }) = _PlayedHoleGeo;

  factory PlayedHoleGeo.fromJson(Map<String, Object?> json) =>
      _$PlayedHoleGeoFromJson(json);
}

/// One team's raw entered value for a played hole (plan 08): strokes for
/// Stroke Play/Match Play/Redistribution, points directly for Free (Q7b).
/// `updatedBy`/`updatedAt` back the "who entered this and when" display
/// (Q8's retained suggestion).
@freezed
abstract class HoleScore with _$HoleScore {
  const factory HoleScore({
    @JsonKey(name: 'team_id') required String teamId,
    required int value,
    @JsonKey(name: 'updated_by') String? updatedBy,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _HoleScore;

  factory HoleScore.fromJson(Map<String, Object?> json) =>
      _$HoleScoreFromJson(json);
}

/// Mirrors one entry of `session_snapshot`'s `played_holes` array (plan 08):
/// a `played_holes` row, its `holes` row and every team's score for it.
@freezed
abstract class PlayedHole with _$PlayedHole {
  const factory PlayedHole({
    required String id,
    required int position,
    @JsonKey(name: 'game_mode') required GameMode gameMode,
    required PlayedHoleGeo hole,
    required List<HoleScore> scores,
  }) = _PlayedHole;

  factory PlayedHole.fromJson(Map<String, Object?> json) =>
      _$PlayedHoleFromJson(json);
}

extension PlayedHoleScores on PlayedHole {
  HoleScore? scoreFor(String teamId) {
    for (final score in scores) {
      if (score.teamId == teamId) return score;
    }
    return null;
  }

  /// Raw value per team, for the scoring calculators (only teams with an
  /// entered score are included -- a missing score doesn't count as 0).
  Map<String, int> get valueByTeamId => {
    for (final score in scores) score.teamId: score.value,
  };
}
