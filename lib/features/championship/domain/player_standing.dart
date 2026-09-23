import 'championship_session_result.dart';

/// One player's position in a championship association/season classement (plan
/// 15, decision 4-5).
class PlayerStanding {
  const PlayerStanding({
    required this.playerId,
    required this.playerName,
    required this.position,
    required this.totalPoints,
    required this.sessionsPlayed,
  });

  final String playerId;
  final String playerName;
  final int position;
  final int totalPoints;
  final int sessionsPlayed;
}

/// Season totals across every championship session of an association/season: sums
/// each player's per-session points (ranking + fixed attendance, decision
/// 4 -- every session played counts, no averaging or best-results-only),
/// then ranks descending by total points. A tie is broken by sessions
/// played (Q45, "le plus présent gagne"); a further tie is left as a
/// shared position ("ex æquo"), same convention already used by
/// `TeamStanding`/`computeStandings` for a single session.
List<PlayerStanding> seasonStandings(List<ChampionshipSessionResult> results) {
  final totalPoints = <String, int>{};
  final sessionsPlayed = <String, int>{};
  final names = <String, String>{};

  for (final result in results) {
    for (final entry in result.pointsByPlayerId.entries) {
      final playerId = entry.key;
      totalPoints[playerId] = (totalPoints[playerId] ?? 0) + entry.value;
      sessionsPlayed[playerId] = (sessionsPlayed[playerId] ?? 0) + 1;
      names[playerId] = result.playerNameById[playerId]!;
    }
  }

  final ordered = totalPoints.keys.toList()
    ..sort((a, b) {
      final byPoints = totalPoints[b]!.compareTo(totalPoints[a]!);
      if (byPoints != 0) return byPoints;
      return sessionsPlayed[b]!.compareTo(sessionsPlayed[a]!);
    });

  final standings = <PlayerStanding>[];
  for (var i = 0; i < ordered.length; i++) {
    final playerId = ordered[i];
    final tiedWithPrevious =
        i > 0 &&
        totalPoints[playerId] == totalPoints[ordered[i - 1]] &&
        sessionsPlayed[playerId] == sessionsPlayed[ordered[i - 1]];
    final position = tiedWithPrevious ? standings[i - 1].position : i + 1;
    standings.add(
      PlayerStanding(
        playerId: playerId,
        playerName: names[playerId]!,
        position: position,
        totalPoints: totalPoints[playerId]!,
        sessionsPlayed: sessionsPlayed[playerId]!,
      ),
    );
  }
  return standings;
}
