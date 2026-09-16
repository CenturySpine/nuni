import 'package:freezed_annotation/freezed_annotation.dart';

/// Mirrors the `ranking_direction` Postgres enum (plan 03): `asc` for
/// "fewest strokes wins" (Stroke Play), `desc` for "highest score wins"
/// (the point-based modes, and Libre when the organizer picks it that way).
enum RankingDirection {
  @JsonValue('asc')
  asc,
  @JsonValue('desc')
  desc,
}
