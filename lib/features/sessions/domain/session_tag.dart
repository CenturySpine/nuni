import 'package:freezed_annotation/freezed_annotation.dart';

/// Mirrors the `session_tag` Postgres enum (plan 29): the natures a session
/// may carry besides "Parcours" (having a scorecard), cumulative.
enum SessionTag {
  @JsonValue('training')
  training,
  @JsonValue('simulator')
  simulator,
  @JsonValue('association_life')
  associationLife,
}

/// The exact text stored in the `session_tag` Postgres enum.
extension SessionTagPostgresValue on SessionTag {
  String toPostgresValue() => switch (this) {
    SessionTag.training => 'training',
    SessionTag.simulator => 'simulator',
    SessionTag.associationLife => 'association_life',
  };
}
