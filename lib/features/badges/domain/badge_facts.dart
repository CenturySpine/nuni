import '../../live/domain/live_session_snapshot.dart';
import '../../live/domain/live_team.dart';
import '../../live/domain/played_hole.dart';
import '../../live/domain/team_standing.dart';
import '../../sessions/domain/scoring_mode.dart';
import '../../sessions/domain/session.dart';
import '../../sessions/domain/session_kind.dart';
import '../../stats/domain/eligible_session.dart';

/// One eligible session a player played (plan 21, "Session jouée"), with
/// what the rules keep asking: the player's team, the final standings, and
/// the player's value on each played hole in playing order (null where
/// their team has no score, which breaks a "de suite" series, Q117).
class PlayedSession {
  PlayedSession._({
    required this.snapshot,
    required this.team,
    required this.holes,
    required this.values,
    required this.standings,
  });

  factory PlayedSession.of(LiveSessionSnapshot snapshot, LiveTeam team) {
    final holes = [...snapshot.playedHoles]
      ..sort((a, b) => a.position.compareTo(b.position));
    return PlayedSession._(
      snapshot: snapshot,
      team: team,
      holes: holes,
      values: [for (final hole in holes) hole.scoreFor(team.id)?.value],
      standings: _standingsAfter(snapshot, holes),
    );
  }

  final LiveSessionSnapshot snapshot;
  final LiveTeam team;

  /// Every played hole of the session, in playing order.
  final List<PlayedHole> holes;

  /// The player's team's value on each of [holes]; null when not entered.
  final List<int?> values;
  final List<TeamStanding> standings;

  Session get session => snapshot.session;
  DateTime get date => sessionDate(session);

  /// Whether [values] are the player's own strokes (Q90).
  bool get valuesAreStrokes => countsStrokes(session);

  int get holesPlayed => values.whereType<int>().length;

  int get position => positionIn(standings);

  /// The worst position of the final standings, ties included.
  int get lastPosition => _last(standings);

  /// A win for badges: alone in first place (Q138, PO 2026-09-25) -- a tie
  /// for first is no win here, unlike the session's own ranking.
  bool get won => soleFirstIn(standings);

  /// Places 1 to 3, alone at that place (Q139: no tie counts for a
  /// ranking badge, podium included).
  bool get podium =>
      position <= 3 &&
      standings.where((s) => s.position == position).length == 1;

  /// Alone in last place (Q138); a fully tied board has no last.
  bool get isLast => soleLastIn(standings);

  int positionIn(List<TeamStanding> standings) =>
      standings.firstWhere((s) => s.teamId == team.id).position;

  /// The standings after the first [count] played holes (D7, D8, D10), the
  /// same calculation as the live screen, limited to those holes.
  List<TeamStanding> standingsAfter(int count) =>
      _standingsAfter(snapshot, holes.take(count).toList());

  static int _last(List<TeamStanding> standings) =>
      standings.fold(0, (worst, s) => s.position > worst ? s.position : worst);

  static List<TeamStanding> _standingsAfter(
    LiveSessionSnapshot snapshot,
    List<PlayedHole> holes,
  ) => computeStandings(
    scoringMode: snapshot.session.scoringMode,
    rankingDirection: snapshot.session.rankingDirection,
    teams: snapshot.teams,
    playedHoles: holes,
  );

  /// Whether the player is alone in first place in [standings].
  bool soleFirstIn(List<TeamStanding> standings) =>
      positionIn(standings) == 1 &&
      standings.where((s) => s.position == 1).length == 1;

  /// Whether the player is alone in last place in [standings].
  bool soleLastIn(List<TeamStanding> standings) {
    final last = _last(standings);
    return last > 1 &&
        positionIn(standings) == last &&
        standings.where((s) => s.position == last).length == 1;
  }

  /// The gap between the player's result and the best other team's, in
  /// strokes (Stroke Play) or points (other modes, D9); null without
  /// another team.
  int? gapToRunnerUp() {
    int valueOf(TeamStanding s) => session.scoringMode == ScoringMode.strokePlay
        ? s.totalStrokes
        : s.totalPoints ?? 0;
    final mine = standings.firstWhere((s) => s.teamId == team.id);
    final others = standings.where((s) => s.teamId != team.id).toList();
    if (others.isEmpty) return null;
    return others
        .map((s) => (valueOf(s) - valueOf(mine)).abs())
        .reduce((a, b) => a < b ? a : b);
  }
}

/// A player's final place in one finished championship season (E3 to E5):
/// its association, its season ("2025-2026"), when it ended, and whether
/// another player shares the place (a shared first is no title, Q138).
class SeasonPlacing {
  const SeasonPlacing({
    required this.associationId,
    required this.season,
    required this.position,
    required this.endedAt,
    this.shared = false,
  });

  final String associationId;
  final String season;
  final int position;
  final DateTime endedAt;
  final bool shared;
}

/// Everything the rules read about one player (plan 21, "Données et
/// calcul"): their eligible sessions, oldest first, their current
/// association (G4) and their finished championship seasons.
class BadgeFacts {
  BadgeFacts({
    required this.playerId,
    required this.associationId,
    required List<LiveSessionSnapshot> history,
    this.seasonPlacings = const [],
  }) : sessions = _played(playerId, history);

  final String playerId;
  final String? associationId;

  /// Every eligible session played, team sessions included: what the
  /// badges that aren't about scores count (attendance, regularity,
  /// championship sessions, exploring, playing conditions).
  final List<PlayedSession> sessions;
  final List<SeasonPlacing> seasonPlacings;

  /// The individual sessions: the only ones for a badge about a ranking --
  /// a win, a podium, a last place (Q138, PO 2026-09-25). Strokes are
  /// individual anyway (Q90).
  late final List<PlayedSession> individualSessions = [
    for (final s in sessions)
      if (s.session.kind == SessionKind.individual) s,
  ];

  /// The team sessions, for the team badges (F, D12).
  late final List<PlayedSession> teamSessions = [
    for (final s in sessions)
      if (s.session.kind == SessionKind.team) s,
  ];

  static List<PlayedSession> _played(
    String playerId,
    List<LiveSessionSnapshot> history,
  ) => [
    for (final snapshot in history)
      if (isEligibleSession(snapshot))
        if (teamOf(snapshot, playerId) case final team?)
          PlayedSession.of(snapshot, team),
  ]..sort((a, b) => a.date.compareTo(b.date));
}
