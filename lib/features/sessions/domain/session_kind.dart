import 'package:freezed_annotation/freezed_annotation.dart';

/// Mirrors the `session_kind` Postgres enum (plan 03).
enum SessionKind {
  @JsonValue('individual')
  individual,
  @JsonValue('team')
  team,
}

/// Fixed team size per kind (Q5): 1 in individual (one team per participant,
/// created by `start_session`), 2 in team. Not user-configurable.
extension SessionKindTeamSize on SessionKind {
  int get teamSize => this == SessionKind.individual ? 1 : 2;
}

/// The exact text stored in the `session_kind` Postgres enum -- distinct
/// from the generated json_serializable map, which is private to
/// `session.g.dart` and only used for reading rows back.
extension SessionKindPostgresValue on SessionKind {
  String toPostgresValue() => switch (this) {
    SessionKind.individual => 'individual',
    SessionKind.team => 'team',
  };
}
