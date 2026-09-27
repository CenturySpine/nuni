import '../../live/domain/live_session_snapshot.dart';
import '../../live/domain/live_team.dart';
import '../../sessions/domain/scoring_mode.dart';
import '../../sessions/domain/session.dart';
import '../../sessions/domain/session_kind.dart';
import '../../sessions/domain/session_tag.dart';

/// The fewest players and played holes a session needs to count for
/// statistics, records and badges (plans 19 to 21, Q117, Q123): it rules out
/// playing alone, duels and abandoned sessions, and scores entered in front
/// of a group are harder to fake. Not used by a session's own ranking.
const minEligiblePlayers = 3;
const minEligibleHoles = 3;

/// Players across every team of [snapshot] (Q124: players, not teams).
int sessionPlayerCount(LiveSessionSnapshot snapshot) =>
    snapshot.teams.fold(0, (sum, team) => sum + team.players.length);

/// Whether [session] is a game (plan 29, Q188): it has a scorecard
/// ("Parcours") and is neither a training nor a simulator session. Only a
/// game counts for statistics, records, the king of a hole, badges A to K
/// and the championship; "association life" doesn't change that (a
/// Christmas tournament counts).
bool isGameSession(Session session) =>
    session.hasScoring &&
    !session.hasTag(SessionTag.training) &&
    !session.hasTag(SessionTag.simulator);

/// Whether [snapshot] counts for statistics, records and badges A to K: a
/// completed game ([isGameSession]) with at least [minEligiblePlayers]
/// players and [minEligibleHoles] played holes. The single definition shared
/// by plans 19, 20 and 21.
bool isEligibleSession(LiveSessionSnapshot snapshot) =>
    snapshot.session.status == SessionStatus.completed &&
    isGameSession(snapshot.session) &&
    sessionPlayerCount(snapshot) >= minEligiblePlayers &&
    snapshot.playedHoles.length >= minEligibleHoles;

/// Whether [snapshot] counts for the club-life badges (plan 29, family L,
/// Q190): completed, with at least [minEligiblePlayers] attendees, whatever
/// its natures -- a game, a training, a Christmas dinner.
bool isActivitySession(LiveSessionSnapshot snapshot) =>
    snapshot.session.status == SessionStatus.completed &&
    sessionPlayerCount(snapshot) >= minEligiblePlayers;

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
