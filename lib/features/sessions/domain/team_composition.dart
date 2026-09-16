import 'dart:math';

import 'session_kind.dart';
import 'session_member.dart';

/// Thrown by [drawRandomTeams] when the selection has an odd number of
/// players -- the draw pairs by two (Q5's team size), so it can never place
/// everyone.
class UnevenPlayerCountException implements Exception {}

/// Thrown by [drawRandomTeams] when the selection has fewer than 4 players
/// (the plan's floor for a random draw to be meaningful).
class NotEnoughPlayersException implements Exception {}

/// Pairs [playerIds] up at random (team mode only, Q5: fixed size 2).
/// Requires an even count of at least 4; the result is a fresh, shuffled
/// pairing every call. [random] is injectable so tests can assert on a
/// deterministic draw.
List<List<String>> drawRandomTeams(List<String> playerIds, {Random? random}) {
  if (playerIds.length.isOdd) throw UnevenPlayerCountException();
  if (playerIds.length < 4) throw NotEnoughPlayersException();

  final shuffled = [...playerIds]..shuffle(random ?? Random());
  return [
    for (var i = 0; i < shuffled.length; i += 2) [shuffled[i], shuffled[i + 1]],
  ];
}

/// The pool members not yet assigned to a team (Q25).
List<SessionMember> unassignedMembers(List<SessionMember> members) => [
  for (final member in members)
    if (member.teamId == null) member,
];

/// Mirrors `start_session`'s server-side conditions (Q25), so the "Démarrer"
/// button can be disabled client-side before the round trip: individual
/// needs at least one participant; team needs at least one team and no
/// unassigned participant.
bool canStartSession({
  required SessionKind kind,
  required List<SessionMember> members,
  required int teamCount,
}) {
  if (members.isEmpty) return false;
  if (kind == SessionKind.individual) return true;
  return teamCount > 0 && unassignedMembers(members).isEmpty;
}
