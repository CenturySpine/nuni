import 'package:freezed_annotation/freezed_annotation.dart';

import 'ranking_direction.dart';
import 'scoring_mode.dart';
import 'session_kind.dart';

part 'session.freezed.dart';
part 'session.g.dart';

/// Mirrors the `session_status` Postgres enum (plan 03).
enum SessionStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('live')
  live,
  @JsonValue('completed')
  completed,
}

/// Mirrors the `sessions` table (plan 03), the fields the waiting room and
/// creation flow (plan 07) need. `city`/`zone` are read back so the room can
/// show what the organizer confirmed at creation. `locationLat`/`locationLng`
/// are generated columns (like `holes.start_lat`/`start_lng`), read back so
/// `SessionRoomPage` can capture weather at kick-off without re-geolocating.
@freezed
abstract class Session with _$Session {
  const factory Session({
    required String id,
    required String code,
    @JsonKey(name: 'owner_id') required String ownerId,
    required SessionStatus status,
    required SessionKind kind,
    @JsonKey(name: 'scoring_mode') required ScoringMode scoringMode,
    @JsonKey(name: 'ranking_direction')
    required RankingDirection rankingDirection,
    String? city,
    String? zone,
    @JsonKey(name: 'location_lat') double? locationLat,
    @JsonKey(name: 'location_lng') double? locationLng,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'ended_at') DateTime? endedAt,
  }) = _Session;

  factory Session.fromJson(Map<String, Object?> json) =>
      _$SessionFromJson(json);
}
