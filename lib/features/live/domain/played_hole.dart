import 'package:freezed_annotation/freezed_annotation.dart';

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
    @JsonKey(name: 'start_lat') double? startLat,
    @JsonKey(name: 'start_lng') double? startLng,
  }) = _PlayedHoleGeo;

  factory PlayedHoleGeo.fromJson(Map<String, Object?> json) =>
      _$PlayedHoleGeoFromJson(json);
}

/// One team's raw entered value for a played hole (plan 08): strokes for
/// Stroke Play/Match Play/Redistribution, points directly for Free (Q7b).
/// `updatedBy`/`updatedAt` record who entered it and when (Q8); no longer
/// shown on screen (PO, 2026-09-23), kept as data.
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
/// [hole] is null for a generic "free hole" (plan 17), which may carry a
/// [label] instead -- show it with `playedHoleName` (ui/played_hole_label.dart)
/// rather than `hole.name`. [par] is this session's par (plan 26, Q118):
/// copied from the hole when added, possibly changed by the organizer, and
/// always set, free holes included -- read it, never `hole.par`, in any
/// calculation. [comment] is a note for this session only.
@freezed
abstract class PlayedHole with _$PlayedHole {
  const factory PlayedHole({
    required String id,
    required int position,
    @JsonKey(name: 'game_mode') required GameMode gameMode,
    PlayedHoleGeo? hole,
    String? label,
    required int par,
    String? comment,
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

extension PlayedHoleName on PlayedHole {
  bool get isFreeHole => hole == null;

  /// The directory hole's name, or a free hole's label (plan 17, Q57); null
  /// for an unlabelled free hole, whose name is translated by the UI.
  String? get customName => hole?.name ?? label;

  /// The directory hole's own par when this session plays it with another
  /// one (plan 26), for a discreet "official par" hint; null otherwise.
  int? get differingOfficialPar {
    final official = hole?.par;
    return official != null && official != par ? official : null;
  }
}
