import '../../live/domain/live_session_snapshot.dart';
import '../../live/domain/team_standing.dart';

/// One completed session in the history list or detail (plan 10): the same
/// `session_snapshot`-shaped data the live screen uses (Q36 reuse), plus its
/// standings computed once with the already-tested `computeStandings` (plan
/// 08) rather than duplicating any ranking logic here.
class HistoryEntry {
  HistoryEntry(this.snapshot)
    : standings = switch ((
        snapshot.session.scoringMode,
        snapshot.session.rankingDirection,
      )) {
        (final mode?, final direction?) => computeStandings(
          scoringMode: mode,
          rankingDirection: direction,
          teams: snapshot.teams,
          playedHoles: snapshot.playedHoles,
        ),
        // No scorecard (plan 29): no ranking.
        _ => const [],
      };

  final LiveSessionSnapshot snapshot;
  final List<TeamStanding> standings;

  /// Null when either end of the session isn't known -- shouldn't happen
  /// for a completed session, but a defensive read is cheaper than a crash
  /// on unexpected data.
  Duration? get duration {
    final startedAt = snapshot.session.startedAt;
    final endedAt = snapshot.session.endedAt;
    if (startedAt == null || endedAt == null) return null;
    return endedAt.difference(startedAt);
  }

  /// Whether [playerId] played in this session (plan 26, Q129): the history
  /// lists the whole association's sessions, marking the caller's own.
  bool playedBy(String? playerId) =>
      playerId != null &&
      snapshot.teams.any(
        (team) => team.players.any((p) => p.playerId == playerId),
      );

  /// The creator's name, shown on a super_admin's "Autres sessions" (plan
  /// 38, Q276): the creator always stays an organizer, hence a member.
  String? get creatorName =>
      snapshot.memberFor(snapshot.session.ownerId)?.playerName;

  List<TeamStanding> get leaders => [
    for (final s in standings)
      if (s.position == 1) s,
  ];
}
