import 'dart:math' as math;

import '../badge.dart';
import '../badge_facts.dart';
import 'tracker.dart';

/// Minimum distance between the sessions of G3 (plan 21, "Éloignement").
const globetrotterKm = 50.0;

/// Great-circle distance in kilometres (haversine).
double distanceKm(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusKm = 6371.0;
  double rad(double deg) => deg * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) *
          math.cos(rad(lat2)) *
          math.pow(math.sin(dLng / 2), 2);
  return 2 * earthRadiusKm * math.asin(math.sqrt(a));
}

/// G. Explorer: different directory holes played (G1, G2), three sessions
/// far apart (G3), a session of another association (G4), free holes
/// played (G5).
List<BadgeResult> explorerBadges(BadgeFacts facts) {
  final curious = BadgeTracker(BadgeId.curious);
  final explorer = BadgeTracker(BadgeId.explorer);
  final globetrotter = BadgeTracker(BadgeId.globetrotter);
  final guest = BadgeTracker(BadgeId.guest);
  final improviser = BadgeTracker(BadgeId.improviser);

  final holeIds = <String>{};
  final places = <(double, double)>[];
  bool far((double, double) a, (double, double) b) =>
      distanceKm(a.$1, a.$2, b.$1, b.$2) >= globetrotterKm;

  for (final session in facts.sessions) {
    var freeHoles = 0;
    for (var i = 0; i < session.holes.length; i++) {
      if (session.values[i] == null) continue;
      final directoryHole = session.holes[i].hole;
      if (directoryHole == null) {
        freeHoles++;
      } else {
        holeIds.add(directoryHole.id);
      }
    }
    curious.reach(holeIds.length, session);
    explorer.reach(holeIds.length, session);
    improviser.add(session, freeHoles);

    // G3: the largest group of sessions all far from each other, up to 3.
    final s = session.session;
    if (s.locationLat != null && s.locationLng != null) {
      final here = (s.locationLat!, s.locationLng!);
      var group = 1;
      for (var i = 0; i < places.length && group < 3; i++) {
        if (!far(places[i], here)) continue;
        group = 2;
        for (var j = i + 1; j < places.length; j++) {
          if (far(places[j], here) && far(places[i], places[j])) {
            group = 3;
            break;
          }
        }
      }
      places.add(here);
      globetrotter.reach(group, session);
    }

    final association = s.associationId;
    if (association != null &&
        facts.associationId != null &&
        association != facts.associationId) {
      guest.hit(session);
    }
  }

  return [curious, explorer, globetrotter, guest, improviser].results();
}
