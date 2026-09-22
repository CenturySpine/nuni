import 'package:freezed_annotation/freezed_annotation.dart';

/// Mirrors the `app_role` Postgres enum (plan 16) -- an app-wide role,
/// distinct from [MemberRole] (owner/player within a single session).
enum AppRole {
  @JsonValue('player')
  player,
  @JsonValue('super_admin')
  superAdmin,
}

/// Parses a plain `role` column value read from `user_roles`.
AppRole appRoleFromPostgresValue(String value) =>
    value == 'super_admin' ? AppRole.superAdmin : AppRole.player;
