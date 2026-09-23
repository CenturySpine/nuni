import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/weather/weather.dart';
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
    Weather? weather,
    String? comment,
    @JsonKey(name: 'cover_photo_id') String? coverPhotoId,
    // Only present on a `session_snapshot`/`history_snapshots` row (joined
    // from `session_photos`), not on a plain `sessions` select (plan 10).
    @JsonKey(name: 'cover_photo_path') String? coverPhotoPath,
    // The creator's association (plan 18), trigger-owned, read back only;
    // also the championship the session counts for when tagged (Q77).
    @JsonKey(name: 'association_id') String? associationId,
    // Championship tagging (plan 15): `isChampionship` is the only one the
    // client ever writes -- `championshipSeason` is trigger-owned.
    @JsonKey(name: 'is_championship') @Default(false) bool isChampionship,
    @JsonKey(name: 'championship_season') String? championshipSeason,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'ended_at') DateTime? endedAt,
  }) = _Session;

  factory Session.fromJson(Map<String, Object?> json) =>
      _$SessionFromJson(json);
}
