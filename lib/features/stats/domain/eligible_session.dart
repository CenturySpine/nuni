import '../../live/domain/live_session_snapshot.dart';
import '../../live/domain/live_team.dart';
import '../../sessions/domain/scoring_mode.dart';
import '../../sessions/domain/session.dart';
import '../../sessions/domain/session_kind.dart';

/// The fewest players and played holes a session needs to count for
/// statistics, records and badges (plans 19 to 21, Q117, Q123): it rules out
/// playing alone, duels and abandoned sessions, and scores entered in front
/// of a group are harder to fake. Not used by a session's own ranking.
const minEligiblePlayers = 3;
const minEligibleHoles = 3;

/// Players across every team of [snapshot] (Q124: players, not teams).
int sessionPlayerCount(LiveSessionSnapshot snapshot) =>
    snapshot.teams.fold(0, (sum, team) => sum + team.players.length);

/// Whether [snapshot] counts for statistics, records and badges: completed,
/// with at least [minEligiblePlayers] players and [minEligibleHoles] played
/// holes. The single definition shared by plans 19, 20 and 21.
bool isEligibleSession(LiveSessionSnapshot snapshot) =>
    snapshot.session.status == SessionStatus.completed &&
    sessionPlayerCount(snapshot) >= minEligiblePlayers &&
    snapshot.playedHoles.length >= minEligibleHoles;

/// When a session was played, in the device's local time (Q115): its start,
/// or its creation for one never started. Orders sessions chronologically.
DateTime sessionDate(Session session) =>
    (session.startedAt ?? session.createdAt).toLocal();

/// [playerId]'s team in [snapshot], or null when they didn't play in it.
LiveTeam? teamOf(LiveSessionSnapshot snapshot, String playerId) {
  for (final team in snapshot.teams) {
    if (team.players.any((p) => p.playerId == playerId)) return team;
  }
  return null;
}

/// Whether a session's entered values are one player's strokes (Q90): only
/// individual sessions -- a team's score isn't any single player's -- and
/// never Free, whose entered value is points, not strokes.
bool countsStrokes(Session session) =>
    session.kind == SessionKind.individual &&
    session.scoringMode != ScoringMode.free;
