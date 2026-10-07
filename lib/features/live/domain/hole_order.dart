import 'live_team.dart';
import 'played_hole.dart';

/// A session's played holes as shown (plan 37, Q267): hole 1 on top when
/// [ascending], else the most recent place on top -- the default, as before
/// holes could be prepared. A hole's place in the course is its position,
/// also its number ("Hole 3"); the direction only flips the display.
List<PlayedHole> holesInDisplayOrder(
  List<PlayedHole> holes, {
  required bool ascending,
}) => [...holes]
  ..sort(
    (a, b) => ascending
        ? a.position.compareTo(b.position)
        : b.position.compareTo(a.position),
  );

/// The hole to play now, highlighted during the game (plan 37, Q268): the
/// first of the course where one of [teams] has no score yet; once every
/// team has scored every hole, the last of the course. For holes added as
/// they are played, that is the latest one, as before. Null without holes.
PlayedHole? currentHole(List<PlayedHole> holes, List<LiveTeam> teams) {
  if (holes.isEmpty) return null;
  final byPlace = holesInDisplayOrder(holes, ascending: true);
  for (final hole in byPlace) {
    if (teams.any((team) => hole.scoreFor(team.id) == null)) return hole;
  }
  return byPlace.last;
}

/// The place in the course (1 = the first hole) of a hole dropped at
/// [shownIndex] (0 = the top) in a displayed list of [count] holes,
/// [ascending] or not (plan 37, Q265).
int coursePlaceForDrop({
  required int count,
  required int shownIndex,
  required bool ascending,
}) => ascending ? shownIndex + 1 : count - shownIndex;
