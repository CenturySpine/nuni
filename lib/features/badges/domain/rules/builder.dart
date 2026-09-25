import '../../../live/domain/live_session_snapshot.dart';
import '../../../stats/domain/eligible_session.dart';
import '../badge.dart';
import '../badge_facts.dart';
import 'tracker.dart';

/// H. Builder: what the player's account added to the app, imported data
/// included (Q116). Holes created don't depend on any session; sessions
/// created, photos and the players of a hole only count eligible sessions
/// (Q117).
List<BadgeResult> builderBadges(BadgeFacts facts) {
  final flagPlanter = BadgeTracker(BadgeId.flagPlanter);
  final landscaper = BadgeTracker(BadgeId.landscaper);
  final architect = BadgeTracker(BadgeId.architect);
  final organizer = BadgeTracker(BadgeId.organizer);
  final gameMaster = BadgeTracker(BadgeId.gameMaster);
  final reporter = BadgeTracker(BadgeId.reporter);
  final photographer = BadgeTracker(BadgeId.photographer);
  final all = [
    flagPlanter,
    landscaper,
    architect,
    organizer,
    gameMaster,
    reporter,
    photographer,
  ];
  final userId = facts.userId;
  if (userId == null) return all.results();
  final contributions = facts.contributions;

  // H1, H2: holes created, clones excluded (Q120).
  final originals = [
    for (final hole in contributions.holes)
      if (!hole.cloned) hole,
  ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  for (final (i, hole) in originals.indexed) {
    flagPlanter.reach(i + 1, null, at: hole.createdAt);
    landscaper.reach(i + 1, null, at: hole.createdAt);
  }

  // H3: one of the player's holes, a clone included (Q120: it may have
  // been moved or changed), played by 10 different players, the player
  // included.
  // The session that brings the last one names it only if the player was
  // in it: another association's session isn't readable.
  final owned = {for (final hole in contributions.holes) hole.id};
  final playersByHole = <String, Set<String>>{};
  for (final snapshot in _eligibleByDate(facts.holesHistory)) {
    final holeIds = {
      for (final hole in snapshot.playedHoles)
        if (hole.hole?.id case final id? when owned.contains(id)) id,
    };
    for (final holeId in holeIds) {
      final players = playersByHole.putIfAbsent(holeId, () => {})
        ..addAll([
          for (final team in snapshot.teams)
            for (final player in team.players) player.playerId,
        ]);
      architect.reach(
        players.length,
        null,
        at: sessionDate(snapshot.session),
        sessionId: teamOf(snapshot, facts.playerId) != null
            ? snapshot.session.id
            : null,
      );
    }
  }

  // H4, H5: sessions created and completed, played or not.
  final eligible = {
    for (final snapshot in contributions.sessions)
      if (isEligibleSession(snapshot)) snapshot.session.id: snapshot,
  };
  var created = 0;
  for (final snapshot in _eligibleByDate(contributions.sessions)) {
    if (snapshot.session.ownerId != userId) continue;
    created++;
    for (final tracker in [organizer, gameMaster]) {
      tracker.reach(
        created,
        null,
        at: sessionDate(snapshot.session),
        sessionId: snapshot.session.id,
      );
    }
  }

  // H6, H7: photos added to eligible sessions.
  final photos = [
    for (final photo in contributions.photos)
      if (eligible.containsKey(photo.sessionId)) photo,
  ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  for (final (i, photo) in photos.indexed) {
    for (final tracker in [reporter, photographer]) {
      tracker.reach(
        i + 1,
        null,
        at: photo.createdAt,
        sessionId: photo.sessionId,
      );
    }
  }

  return all.results();
}

List<LiveSessionSnapshot> _eligibleByDate(
  List<LiveSessionSnapshot> snapshots,
) => [
  for (final snapshot in snapshots)
    if (isEligibleSession(snapshot)) snapshot,
]..sort((a, b) => sessionDate(a.session).compareTo(sessionDate(b.session)));
