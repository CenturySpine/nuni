import 'package:freezed_annotation/freezed_annotation.dart';

/// Mirrors the `game_mode` Postgres enum (plan 03): the format a played hole
/// is played in, chosen when it's added to a session (plan 08).
/// `individual` only makes sense for [SessionKind.individual] sessions; the
/// other three are for team sessions.
enum GameMode {
  @JsonValue('individual')
  individual,
  @JsonValue('scramble')
  scramble,
  @JsonValue('greensome')
  greensome,
  @JsonValue('best_ball')
  bestBall,
}

/// The exact text stored in the `game_mode` Postgres enum -- distinct from
/// the generated json_serializable map, which is private to
/// `played_hole.g.dart` and only used for reading rows back.
extension GameModePostgresValue on GameMode {
  String toPostgresValue() => switch (this) {
    GameMode.individual => 'individual',
    GameMode.scramble => 'scramble',
    GameMode.greensome => 'greensome',
    GameMode.bestBall => 'best_ball',
  };
}
