import '../../live/domain/live_session_snapshot.dart';
import '../../live/domain/live_team.dart';
import '../../live/domain/team_standing.dart';

/// Fixed point awarded to every player of a championship session regardless
/// of their standing that day (plan 15, decision 3): rewards showing up
/// without ever letting attendance alone outrank a better result -- the gap
/// between two ranking positions (at least 1 point, see
/// [sessionRankingPoints]) is always strictly greater than this.
const championshipAttendancePoints = 1;

/// Ranking points for one championship session's final standings: a team at
/// position *p* among *n* teams scores `n - p + 1` -- last place always
/// scores at least 1, never 0. Tied teams already share one `position`
/// ([computeStandings] resolves this), so they score identically without
/// any extra handling here (Q40).
Map<String, int> sessionRankingPoints(List<TeamStanding> standings) {
  final teamCount = standings.length;
  return {for (final s in standings) s.teamId: teamCount - s.position + 1};
}

/// One championship session's points, already resolved to individual
/// players (Q43: every teammate of a Team-mode session scores identically,
/// no split or weighting) -- ranking points plus the fixed attendance
/// point. Built once per session from its own `session_snapshot`-shaped
/// data, reusing the same tested [computeStandings] the live and history
/// screens already use (plan 15: no new ranking logic per scoring mode).
class ChampionshipSessionResult {
  const ChampionshipSessionResult({
    required this.sessionId,
    required this.pointsByPlayerId,
    required this.playerNameById,
  });

  factory ChampionshipSessionResult.fromSnapshot(LiveSessionSnapshot snapshot) {
    final standings = computeStandings(
      scoringMode: snapshot.session.scoringMode,
      rankingDirection: snapshot.session.rankingDirection,
      teams: snapshot.teams,
      playedHoles: snapshot.playedHoles,
    );
    return ChampionshipSessionResult(
      sessionId: snapshot.session.id,
      pointsByPlayerId: _playerPoints(snapshot.teams, standings),
      playerNameById: {
        for (final team in snapshot.teams)
          for (final player in team.players) player.playerId: player.name,
      },
    );
  }

  final String sessionId;
  final Map<String, int> pointsByPlayerId;
  final Map<String, String> playerNameById;
}

Map<String, int> _playerPoints(
  List<LiveTeam> teams,
  List<TeamStanding> standings,
) {
  final rankingPoints = sessionRankingPoints(standings);
  final result = <String, int>{};
  for (final team in teams) {
    final points = (rankingPoints[team.id] ?? 0) + championshipAttendancePoints;
    for (final player in team.players) {
      result[player.playerId] = points;
    }
  }
  return result;
}
