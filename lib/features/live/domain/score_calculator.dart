import '../../sessions/domain/scoring_mode.dart';

/// Points awarded to each team for a single played hole, given the raw
/// value each team entered for that hole (strokes for Stroke Play, Match
/// Play and Redistribution; points directly for Free, Q7b -- no
/// calculation). Transposed from LsgScores'
/// `ScoringCalculator.calculateScores` (`ClassicScoringCalculator`,
/// `SinglePointScoringCalculator`, `TwoOneScoringCalculator` -- see
/// `test/features/live/domain/score_calculator_test.dart` for the
/// transposed test cases). Only teams present in [valueByTeamId] are
/// considered -- a team with no score yet for this hole doesn't affect the
/// others' points.
Map<String, int> calculateHolePoints(
  ScoringMode mode,
  Map<String, int> valueByTeamId,
) {
  if (valueByTeamId.isEmpty) return const {};
  return switch (mode) {
    // Stroke Play has no separate "points" concept: the raw value already
    // is the number that's ranked on (ascending).
    ScoringMode.strokePlay => Map.unmodifiable(valueByTeamId),
    ScoringMode.matchPlay => _matchPlayPoints(valueByTeamId),
    ScoringMode.redistribution => _redistributionPoints(valueByTeamId),
    // Free's entered value already is the point total (Q7b): no calculation.
    ScoringMode.free => Map.unmodifiable(valueByTeamId),
  };
}

/// `SinglePointScoringCalculator`: the sole lowest-value team scores 1, all
/// others 0. A tie for lowest scores everyone 0 for that hole.
Map<String, int> _matchPlayPoints(Map<String, int> valueByTeamId) {
  final minValue = valueByTeamId.values.reduce((a, b) => a < b ? a : b);
  final leaders = [
    for (final entry in valueByTeamId.entries)
      if (entry.value == minValue) entry.key,
  ];
  if (leaders.length != 1) {
    return {for (final teamId in valueByTeamId.keys) teamId: 0};
  }
  return {
    for (final teamId in valueByTeamId.keys)
      teamId: teamId == leaders.single ? 1 : 0,
  };
}

/// `TwoOneScoringCalculator`: a sole leader (lowest value) scores 2 and a
/// sole runner-up (the next distinct lowest value among the rest) scores 1.
/// Two teams tied for the lead score 1 each, and a sole runner-up behind
/// them still scores 1. Three or more tied for the lead: nobody scores.
/// "Sole" is load-bearing throughout -- a tie for runner-up scores no one.
Map<String, int> _redistributionPoints(Map<String, int> valueByTeamId) {
  final sorted = valueByTeamId.entries.toList()
    ..sort((a, b) => a.value.compareTo(b.value));
  final minValue = sorted.first.value;
  final leaders = [
    for (final entry in sorted)
      if (entry.value == minValue) entry.key,
  ];

  if (leaders.length >= 3) {
    return {for (final teamId in valueByTeamId.keys) teamId: 0};
  }

  final rest = [
    for (final entry in sorted)
      if (entry.value > minValue) entry,
  ];
  final runnerUpValue = rest.isEmpty ? null : rest.first.value;
  final runnersUp = [
    for (final entry in rest)
      if (entry.value == runnerUpValue) entry.key,
  ];
  final soleRunnerUp = runnersUp.length == 1 ? runnersUp.single : null;

  final leaderPoints = leaders.length == 1 ? 2 : 1;
  return {
    for (final teamId in valueByTeamId.keys)
      teamId: leaders.contains(teamId)
          ? leaderPoints
          : (teamId == soleRunnerUp ? 1 : 0),
  };
}
