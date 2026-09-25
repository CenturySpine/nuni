import '../../live/domain/live_session_snapshot.dart';

/// A hole a player's account owns (H1 to H3): a clone is marked, it doesn't
/// count as a hole created (Q120).
class CreatedHole {
  const CreatedHole({
    required this.id,
    required this.createdAt,
    this.cloned = false,
  });

  factory CreatedHole.fromJson(Map<String, Object?> json) => CreatedHole(
    id: json['id']! as String,
    createdAt: DateTime.parse(json['created_at']! as String).toLocal(),
    cloned: json['cloned'] as bool? ?? false,
  );

  final String id;
  final DateTime createdAt;
  final bool cloned;
}

/// A photo a player's account added to a completed session (H6, H7).
class AddedPhoto {
  const AddedPhoto({required this.sessionId, required this.createdAt});

  factory AddedPhoto.fromJson(Map<String, Object?> json) => AddedPhoto(
    sessionId: json['session_id']! as String,
    createdAt: DateTime.parse(json['created_at']! as String).toLocal(),
  );

  final String sessionId;
  final DateTime createdAt;
}

/// What a player's account added to the app (plan 21, family H), imported
/// data included (Q116), as `player_contributions` returns it: empty for a
/// player without an account.
class PlayerContributions {
  const PlayerContributions({
    this.holes = const [],
    this.photos = const [],
    this.sessions = const [],
  });

  factory PlayerContributions.fromJson(Map<String, Object?> json) =>
      PlayerContributions(
        holes: [
          for (final row in json['holes'] as List<dynamic>? ?? const [])
            CreatedHole.fromJson(row as Map<String, Object?>),
        ],
        photos: [
          for (final row in json['photos'] as List<dynamic>? ?? const [])
            AddedPhoto.fromJson(row as Map<String, Object?>),
        ],
        sessions: [
          for (final row in json['sessions'] as List<dynamic>? ?? const [])
            LiveSessionSnapshot.fromJson(row as Map<String, Object?>),
        ],
      );

  final List<CreatedHole> holes;
  final List<AddedPhoto> photos;

  /// Every completed session the account created or added a photo to,
  /// played or not: which count is decided by `isEligibleSession`.
  final List<LiveSessionSnapshot> sessions;
}
