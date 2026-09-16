import 'package:freezed_annotation/freezed_annotation.dart';

import 'ranking_direction.dart';

/// Mirrors the `scoring_mode` Postgres enum (plan 03).
enum ScoringMode {
  @JsonValue('stroke_play')
  strokePlay,
  @JsonValue('match_play')
  matchPlay,
  @JsonValue('redistribution')
  redistribution,
  @JsonValue('free')
  free,
}

/// Q34: for every mode but Libre, `ranking_direction` is deduced from the
/// mode and not user-editable. Libre returns `null` -- the organizer picks
/// it explicitly (Q7b).
extension ScoringModeRankingDirection on ScoringMode {
  RankingDirection? get impliedRankingDirection => switch (this) {
    ScoringMode.strokePlay => RankingDirection.asc,
    ScoringMode.matchPlay => RankingDirection.desc,
    ScoringMode.redistribution => RankingDirection.desc,
    ScoringMode.free => null,
  };
}

/// The exact text stored in the `scoring_mode` Postgres enum -- distinct
/// from the generated json_serializable map, which is private to
/// `session.g.dart` and only used for reading rows back.
extension ScoringModePostgresValue on ScoringMode {
  String toPostgresValue() => switch (this) {
    ScoringMode.strokePlay => 'stroke_play',
    ScoringMode.matchPlay => 'match_play',
    ScoringMode.redistribution => 'redistribution',
    ScoringMode.free => 'free',
  };
}
