import '../../../core/text/compare_names.dart';
import '../../championship/domain/championship_season.dart';
import '../../live/domain/live_session_snapshot.dart';
import '../../live/domain/played_hole.dart';
import '../../live/domain/team_standing.dart';
import '../../sessions/domain/session_kind.dart';
import 'eligible_session.dart';

/// Strokes against par over a set of holes (plan 19, "Rapport au par"):
/// the average difference per hole and how the holes split between birdie
/// or better, par, and bogey or worse.
class ParReport {
  const ParReport({
    required this.holes,
    required this.averageToPar,
    required this.birdieOrBetter,
    required this.pars,
    required this.bogeyOrWorse,
  });

  final int holes;
  final double averageToPar;
  final int birdieOrBetter;
  final int pars;
  final int bogeyOrWorse;
}

/// One directory hole's record for a player: how often they played it and
/// their average difference to par on it.
class HoleAverage {
  const HoleAverage({
    required this.holeId,
    required this.name,
    required this.passages,
    required this.averageToPar,
  });

  final String holeId;
  final String name;
  final int passages;
  final double averageToPar;
}

/// One point of the curve: a session and the player's average difference to
/// par per hole in it.
class CurvePoint {
  const CurvePoint({
    required this.sessionId,
    required this.date,
    required this.averageToPar,
    required this.holes,
  });

  final String sessionId;
  final DateTime date;
  final double averageToPar;
  final int holes;
}

/// A teammate and what the player achieved with them in team sessions.
class TeammateStat {
  const TeammateStat({
    required this.playerId,
    required this.name,
    required this.sessions,
    required this.wins,
  });

  final String playerId;
  final String name;
  final int sessions;
  final int wins;
}

/// Team-play meta-statistics (Q107): no strokes, only team results.
class TeamStats {
  const TeamStats({
    required this.sessions,
    required this.wins,
    required this.podiums,
    required this.mostFrequentTeammate,
    required this.bestDuo,
  });

  final int sessions;
  final int wins;
  final int podiums;
  final TeammateStat? mostFrequentTeammate;

  /// The teammate with the best win rate together over at least
  /// [minDuoSessions] shared sessions; null when none qualifies.
  final TeammateStat? bestDuo;
}

/// Shared team sessions a duo needs before it can be the "best duo" (Q107).
const minDuoSessions = 3;

/// A player's passages on a hole before it can be their best or worst hole
/// (Q93, revised 2026-09-24): one lucky or disastrous passage alone would
/// otherwise hold the title for a long time.
const minHolePassages = 3;

/// Everything the "Statistiques" section of a player's page shows (plan 19).
/// [parReport] is null and [curve] empty until the player has a
/// stroke-counting hole; the best and worst holes are null until a
/// directory hole reaches [minHolePassages] (the worst one needs a second
/// such hole); [team] is null without any team session.
class PlayerStats {
  const PlayerStats({
    required this.sessionsPlayed,
    required this.wins,
    required this.podiums,
    required this.holesPlayed,
    required this.parReport,
    required this.bestHole,
    required this.worstHole,
    required this.curve,
    required this.team,
  });

  final int sessionsPlayed;
  final int wins;
  final int podiums;
  final int holesPlayed;
  final ParReport? parReport;
  final HoleAverage? bestHole;
  final HoleAverage? worstHole;

  /// One point per stroke-counting session, in chronological order.
  final List<CurvePoint> curve;
  final TeamStats? team;
}

/// The eligible sessions [playerId] played in, oldest first; only those of
/// [season] ("2025-2026", September to August like the championship) when
/// given.
List<LiveSessionSnapshot> _playedSessions(
  String playerId,
  List<LiveSessionSnapshot> snapshots,
  String? season,
) => [
  for (final snapshot in snapshots)
    if (isEligibleSession(snapshot) &&
        teamOf(snapshot, playerId) != null &&
        (season == null ||
            championshipSeasonFor(sessionDate(snapshot.session)) == season))
      snapshot,
]..sort((a, b) => sessionDate(a.session).compareTo(sessionDate(b.session)));

/// The seasons [playerId] played at least one eligible session in, most
/// recent first: the choices of the season breakdown, next to "all time".
List<String> playedSeasons(
  String playerId,
  List<LiveSessionSnapshot> snapshots,
) {
  final seasons = {
    for (final snapshot in _playedSessions(playerId, snapshots, null))
      championshipSeasonFor(sessionDate(snapshot.session)),
  }.toList()..sort((a, b) => b.compareTo(a));
  return seasons;
}

class _HoleTally {
  _HoleTally(this.name);

  String name;
  int passages = 0;
  int toPar = 0;
}

class _TeammateTally {
  _TeammateTally(this.name);

  final String name;
  int sessions = 0;
  int wins = 0;
}

/// Computes [playerId]'s statistics from their sessions ([snapshots], any
/// order, as `player_history` returns them), over all time or one [season]:
/// only eligible sessions count (Q117, Q123); strokes only where
/// [countsStrokes] (Q90). Victory and podium follow the session's own
/// ranking ([computeStandings]), ties included.
PlayerStats computePlayerStats(
  String playerId,
  List<LiveSessionSnapshot> snapshots, {
  String? season,
}) {
  final played = _playedSessions(playerId, snapshots, season);

  var wins = 0;
  var podiums = 0;
  var holesPlayed = 0;

  var strokeHoles = 0;
  var totalToPar = 0;
  var birdieOrBetter = 0;
  var pars = 0;
  var bogeyOrWorse = 0;
  final holeTallies = <String, _HoleTally>{};
  final curve = <CurvePoint>[];

  var teamSessions = 0;
  var teamWins = 0;
  var teamPodiums = 0;
  final teammates = <String, _TeammateTally>{};

  for (final snapshot in played) {
    final session = snapshot.session;
    final team = teamOf(snapshot, playerId)!;
    final standings = computeStandings(
      scoringMode: session.scoringMode,
      rankingDirection: session.rankingDirection,
      teams: snapshot.teams,
      playedHoles: snapshot.playedHoles,
    );
    final position = standings.firstWhere((s) => s.teamId == team.id).position;
    final won = position == 1;
    if (won) wins++;
    if (position <= 3) podiums++;

    final scoredHoles = <(PlayedHole, int)>[
      for (final hole in snapshot.playedHoles)
        if (hole.scoreFor(team.id) case final score?) (hole, score.value),
    ];
    holesPlayed += scoredHoles.length;

    if (countsStrokes(session) && scoredHoles.isNotEmpty) {
      var sessionToPar = 0;
      for (final (hole, strokes) in scoredHoles) {
        final toPar = strokes - hole.par;
        sessionToPar += toPar;
        if (toPar < 0) {
          birdieOrBetter++;
        } else if (toPar == 0) {
          pars++;
        } else {
          bogeyOrWorse++;
        }
        // Free holes are unique to their session: no "best hole" among them.
        final directoryHole = hole.hole;
        if (directoryHole != null) {
          final tally = holeTallies.putIfAbsent(
            directoryHole.id,
            () => _HoleTally(directoryHole.name),
          )..name = directoryHole.name;
          tally
            ..passages += 1
            ..toPar += toPar;
        }
      }
      strokeHoles += scoredHoles.length;
      totalToPar += sessionToPar;
      curve.add(
        CurvePoint(
          sessionId: session.id,
          date: sessionDate(session),
          averageToPar: sessionToPar / scoredHoles.length,
          holes: scoredHoles.length,
        ),
      );
    }

    if (session.kind == SessionKind.team) {
      teamSessions++;
      if (won) teamWins++;
      if (position <= 3) teamPodiums++;
      for (final mate in team.players) {
        if (mate.playerId == playerId) continue;
        final tally = teammates.putIfAbsent(
          mate.playerId,
          () => _TeammateTally(mate.name),
        );
        tally.sessions++;
        if (won) tally.wins++;
      }
    }
  }

  final holes = [
    for (final entry in holeTallies.entries)
      if (entry.value.passages >= minHolePassages)
        HoleAverage(
          holeId: entry.key,
          name: entry.value.name,
          passages: entry.value.passages,
          averageToPar: entry.value.toPar / entry.value.passages,
        ),
  ];
  // Ties: the most played hole, then alphabetical order.
  int byPassagesThenName(HoleAverage a, HoleAverage b) {
    final byPassages = b.passages.compareTo(a.passages);
    return byPassages != 0 ? byPassages : compareNames(a.name, b.name);
  }

  HoleAverage? bestHole;
  HoleAverage? worstHole;
  if (holes.isNotEmpty) {
    bestHole =
        ([...holes]..sort((a, b) {
              final byAverage = a.averageToPar.compareTo(b.averageToPar);
              return byAverage != 0 ? byAverage : byPassagesThenName(a, b);
            }))
            .first;
    if (holes.length > 1) {
      worstHole =
          ([...holes]..sort((a, b) {
                final byAverage = b.averageToPar.compareTo(a.averageToPar);
                return byAverage != 0 ? byAverage : byPassagesThenName(a, b);
              }))
              .first;
    }
  }

  return PlayerStats(
    sessionsPlayed: played.length,
    wins: wins,
    podiums: podiums,
    holesPlayed: holesPlayed,
    parReport: strokeHoles == 0
        ? null
        : ParReport(
            holes: strokeHoles,
            averageToPar: totalToPar / strokeHoles,
            birdieOrBetter: birdieOrBetter,
            pars: pars,
            bogeyOrWorse: bogeyOrWorse,
          ),
    bestHole: bestHole,
    worstHole: worstHole,
    curve: curve,
    team: teamSessions == 0
        ? null
        : TeamStats(
            sessions: teamSessions,
            wins: teamWins,
            podiums: teamPodiums,
            mostFrequentTeammate: _mostFrequent(teammates),
            bestDuo: _bestDuo(teammates),
          ),
  );
}

TeammateStat _stat(MapEntry<String, _TeammateTally> entry) => TeammateStat(
  playerId: entry.key,
  name: entry.value.name,
  sessions: entry.value.sessions,
  wins: entry.value.wins,
);

/// The teammate shared the most sessions with; ties in alphabetical order.
TeammateStat? _mostFrequent(Map<String, _TeammateTally> teammates) {
  final stats = teammates.entries.map(_stat).toList()
    ..sort((a, b) {
      final bySessions = b.sessions.compareTo(a.sessions);
      return bySessions != 0 ? bySessions : compareNames(a.name, b.name);
    });
  return stats.isEmpty ? null : stats.first;
}

/// The best win rate together over at least [minDuoSessions] shared
/// sessions, with at least one win (a winless pair is no "best duo");
/// ties: more shared sessions, then alphabetical order. Rates are compared
/// by cross-multiplying, so equal ratios are exactly equal.
TeammateStat? _bestDuo(Map<String, _TeammateTally> teammates) {
  final stats =
      [
        for (final entry in teammates.entries)
          if (entry.value.sessions >= minDuoSessions && entry.value.wins > 0)
            _stat(entry),
      ]..sort((a, b) {
        final byRate = (b.wins * a.sessions).compareTo(a.wins * b.sessions);
        if (byRate != 0) return byRate;
        final bySessions = b.sessions.compareTo(a.sessions);
        return bySessions != 0 ? bySessions : compareNames(a.name, b.name);
      });
  return stats.isEmpty ? null : stats.first;
}
