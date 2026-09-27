import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/weather/weather.dart';
import 'ranking_direction.dart';
import 'scoring_mode.dart';
import 'session_kind.dart';
import 'session_tag.dart';

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
  const Session._();

  const factory Session({
    required String id,
    required String code,
    @JsonKey(name: 'owner_id') required String ownerId,
    required SessionStatus status,
    // The scorecard (plan 29, "Parcours"): all three set, or all three null
    // for a session without scores, whose attendees are its single team's
    // players. Frozen after creation (Q193).
    SessionKind? kind,
    @JsonKey(name: 'scoring_mode') ScoringMode? scoringMode,
    @JsonKey(name: 'ranking_direction') RankingDirection? rankingDirection,
    // Its other natures (plan 29), cumulative; empty for a plain game.
    @Default(<SessionTag>[]) List<SessionTag> tags,
    // An optional name (plan 31, Q205), the title when set.
    String? title,
    String? city,
    String? zone,
    // The association's spot (plan 28); null for a free place (plan 29).
    @JsonKey(name: 'spot_id') String? spotId,
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

  /// Whether the session has a scorecard ("Parcours", plan 29): holes,
  /// scores and a ranking. Without one, it only records who attended, a
  /// report and photos.
  bool get hasScoring => scoringMode != null;

  bool hasTag(SessionTag tag) => tags.contains(tag);
}
