import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';
part 'event.g.dart';

/// Mirrors the `event_response` Postgres enum (plan 23): a member's answer
/// to an event.
enum EventResponse {
  @JsonValue('yes')
  yes,
  @JsonValue('no')
  no,
  @JsonValue('maybe')
  maybe,
}

/// Mirrors the `event_color` Postgres enum (plan 23, Q149): the base stores
/// the hue's name only, `lib/core/theme/palettes.dart` owns its colour.
enum EventColor {
  @JsonValue('red')
  red,
  @JsonValue('orange')
  orange,
  @JsonValue('yellow')
  yellow,
  @JsonValue('green')
  green,
  @JsonValue('teal')
  teal,
  @JsonValue('blue')
  blue,
  @JsonValue('purple')
  purple,
  @JsonValue('pink')
  pink,
}

/// Mirrors the `event_origin` Postgres enum (plan 23, Q155): set by the base,
/// never by the app -- a new import replaces the `imported` ones only.
enum EventOrigin {
  @JsonValue('manual')
  manual,
  @JsonValue('imported')
  imported,
}

/// The exact text stored in the Postgres enums, for writes -- the generated
/// json maps are private to `event.g.dart` and only read rows back.
extension EventResponsePostgresValue on EventResponse {
  String toPostgresValue() => name;
}

extension EventColorPostgresValue on EventColor {
  String toPostgresValue() => name;
}

/// One member's answer, as embedded in an event row
/// (`event_responses(player_id, response)`).
@freezed
abstract class EventAnswer with _$EventAnswer {
  const factory EventAnswer({
    @JsonKey(name: 'player_id') required String playerId,
    required EventResponse response,
  }) = _EventAnswer;

  factory EventAnswer.fromJson(Map<String, Object?> json) =>
      _$EventAnswerFromJson(json);
}

/// Mirrors the `events` table (plan 23), read with its answers and its
/// comment count (`event_comments(count)`) in the same query.
@freezed
abstract class Event with _$Event {
  const Event._();

  const factory Event({
    required String id,
    @JsonKey(name: 'association_id') required String associationId,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'manager_player_id') String? managerPlayerId,
    @JsonKey(name: 'starts_at') required DateTime startsAt,
    required String label,
    String? spot,
    // One of the association's spots (plan 28), whose name [spot] copies;
    // null for a free place.
    @JsonKey(name: 'spot_id') String? spotId,
    @JsonKey(name: 'location_lat') double? locationLat,
    @JsonKey(name: 'location_lng') double? locationLng,
    String? description,
    EventColor? color,
    @Default(EventOrigin.manual) EventOrigin origin,
    @JsonKey(name: 'event_responses') @Default([]) List<EventAnswer> answers,
    @JsonKey(name: 'event_comments', readValue: _readCount)
    @Default(0)
    int commentCount,
  }) = _Event;

  factory Event.fromJson(Map<String, Object?> json) => _$EventFromJson(json);

  bool get hasLocation => locationLat != null && locationLng != null;

  int get yesCount =>
      answers.where((answer) => answer.response == EventResponse.yes).length;

  /// [playerId]'s answer, or null when they haven't answered.
  EventResponse? responseOf(String? playerId) {
    for (final answer in answers) {
      if (answer.playerId == playerId) return answer.response;
    }
    return null;
  }
}

/// PostgREST returns an embedded count as `[{"count": n}]`.
Object? _readCount(Map<dynamic, dynamic> json, String key) {
  final value = json[key];
  if (value is List && value.isNotEmpty) {
    final first = value.first;
    if (first is Map) return first['count'];
  }
  return value is int ? value : null;
}

/// Mirrors the `event_comments` table (plan 23, Q166).
@freezed
abstract class EventComment with _$EventComment {
  const factory EventComment({
    required String id,
    @JsonKey(name: 'event_id') required String eventId,
    @JsonKey(name: 'author_player_id') required String authorPlayerId,
    required String body,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'edited_at') DateTime? editedAt,
  }) = _EventComment;

  factory EventComment.fromJson(Map<String, Object?> json) =>
      _$EventCommentFromJson(json);
}

/// What the event form writes (plan 23): every field but the ones the base
/// owns (association, creator, origin).
@freezed
abstract class EventDraft with _$EventDraft {
  const EventDraft._();

  const factory EventDraft({
    required DateTime startsAt,
    required String label,
    String? spot,
    String? spotId,
    double? lat,
    double? lng,
    String? managerPlayerId,
    String? description,
    EventColor? color,
  }) = _EventDraft;

  Map<String, Object?> toRow() => {
    'starts_at': startsAt.toUtc().toIso8601String(),
    'label': label.trim(),
    'spot': _blankToNull(spot),
    'spot_id': spotId,
    'location': lat == null || lng == null
        ? null
        : 'SRID=4326;POINT($lng $lat)',
    'manager_player_id': managerPlayerId,
    'description': _blankToNull(description),
    'color': color?.toPostgresValue(),
  };
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
