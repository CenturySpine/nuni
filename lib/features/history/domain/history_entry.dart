import '../../live/domain/live_session_snapshot.dart';
import '../../live/domain/team_standing.dart';

/// One completed session in the history list or detail (plan 10): the same
/// `session_snapshot`-shaped data the live screen uses (Q36 reuse), plus its
/// standings computed once with the already-tested `computeStandings` (plan
/// 08) rather than duplicating any ranking logic here.
class HistoryEntry {
  HistoryEntry(this.snapshot)
    : standings = computeStandings(
        scoringMode: snapshot.session.scoringMode,
        rankingDirection: snapshot.session.rankingDirection,
        teams: snapshot.teams,
        playedHoles: snapshot.playedHoles,
      );

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

  List<TeamStanding> get leaders => [
    for (final s in standings)
      if (s.position == 1) s,
  ];
}
