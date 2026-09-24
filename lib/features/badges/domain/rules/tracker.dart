import '../badge.dart';
import '../badge_facts.dart';

/// Follows one badge through a player's sessions, oldest first: the first
/// session that reaches its target earns it, on that session's date (plan
/// 21, "Date d'obtention"), and the best value reached so far is its
/// progress. Earned badges are never lost (Q111).
class BadgeTracker {
  BadgeTracker(this.id);

  final BadgeId id;
  int _best = 0;
  int _count = 0;
  DateTime? _earnedAt;
  String? _sessionId;

  bool get earned => _earnedAt != null;

  /// A value reached in [session] (a count, a streak...), or at [at] for
  /// something that isn't a session (a championship season's end); earns
  /// the badge once it reaches the target.
  void reach(int value, PlayedSession? session, {DateTime? at}) {
    if (value > _best) _best = value;
    final target = id.target ?? 1;
    if (!earned && value >= target) {
      _earnedAt = at ?? session?.date;
      _sessionId = session?.session.id;
    }
  }

  /// [by] more occurrences in [session], for a cumulated count.
  void add(PlayedSession session, [int by = 1]) {
    if (by <= 0) return;
    _count += by;
    reach(_count, session);
  }

  /// The feat happened in [session] (a one-off badge).
  void hit(PlayedSession session) => reach(id.target ?? 1, session);

  BadgeResult result() {
    final target = id.target;
    return BadgeResult(
      id: id,
      earnedAt: _earnedAt,
      sessionId: _sessionId,
      progress: target == null ? 0 : (_best > target ? target : _best),
    );
  }
}

extension BadgeTrackers on List<BadgeTracker> {
  List<BadgeResult> results() => [for (final t in this) t.result()];
}
