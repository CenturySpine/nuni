import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../championship/data/championship_repository.dart';
import '../../championship/domain/championship_season.dart';
import '../../players/data/players_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../stats/data/stats_repository.dart';
import '../../stats/domain/eligible_session.dart';
import '../domain/badge.dart';
import 'seen_badges_store.dart';
import '../domain/badge_facts.dart';
import '../domain/compute_badges.dart';

part 'badges_repository.g.dart';

/// A player's badges (plan 21), recomputed from what is already readable:
/// their history (`player_history`, plan 19) and, for E3 to E5, the
/// classement of every finished championship season they played in. No
/// badge is stored (decision 8). Hiding badges is a display choice only
/// (Q133): this never looks at `badges_public`.
@riverpod
Future<List<BadgeResult>> playerBadges(Ref ref, String playerId) async {
  final history = await ref.watch(playerHistoryProvider(playerId).future);
  final player = await ref.watch(playerByIdProvider(playerId).future);

  final now = DateTime.now();
  final seasons = {
    for (final snapshot in history)
      if (snapshot.session.isChampionship && teamOf(snapshot, playerId) != null)
        if ((
              snapshot.session.associationId,
              snapshot.session.championshipSeason,
            )
            case (final String association, final String season)
            when now.isAfter(championshipSeasonEnd(season)))
          (association, season),
  };
  final placings = <SeasonPlacing>[];
  for (final (association, season) in seasons) {
    final standings = await ref.watch(
      championshipStandingsProvider(association, season).future,
    );
    for (final standing in standings) {
      if (standing.playerId != playerId) continue;
      placings.add(
        SeasonPlacing(
          associationId: association,
          season: season,
          position: standing.position,
          endedAt: championshipSeasonEnd(season),
          shared:
              standings.where((s) => s.position == standing.position).length >
              1,
        ),
      );
    }
  }

  return computeBadges(
    BadgeFacts(
      playerId: playerId,
      associationId: player?.associationId,
      history: history,
      seasonPlacings: placings,
    ),
  );
}

/// My own badges, for announcing new ones (plan 21): null until I have
/// chosen an association (plan 18), so nothing is announced over the
/// association choice of a first sign-in.
@riverpod
Future<List<BadgeResult>?> myBadges(Ref ref) async {
  final me = await ref.watch(myPlayerProvider.future);
  if (me.associationId == null) return null;
  return ref.watch(playerBadgesProvider(me.id).future);
}

/// The badges already seen in my badges section when the app started: read
/// once and kept, so the "New" marks survive the section being rebuilt
/// while it marks them seen for next time.
@Riverpod(keepAlive: true)
Future<Set<BadgeId>> viewedBadgesAtStart(Ref ref, String userId) =>
    SeenBadgesStore(userId).viewed();
