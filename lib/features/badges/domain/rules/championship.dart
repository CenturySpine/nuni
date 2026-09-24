import '../badge.dart';
import '../badge_facts.dart';
import 'tracker.dart';

/// E. Championship: championship sessions played (E1, E2, eligible ones
/// only) and final places in finished seasons (E3 to E5, from the season
/// classement itself, which keeps every championship session, Q126).
List<BadgeResult> championshipBadges(BadgeFacts facts) {
  final competitor = BadgeTracker(BadgeId.competitor);
  final fullSeason = BadgeTracker(BadgeId.fullSeason);
  final champion = BadgeTracker(BadgeId.champion);
  final seasonPodium = BadgeTracker(BadgeId.seasonPodium);
  final topFive = BadgeTracker(BadgeId.topFive);

  final perSeason = <String, int>{};
  for (final session in facts.sessions) {
    final s = session.session;
    if (!s.isChampionship) continue;
    competitor.add(session);
    final key = '${s.associationId}|${s.championshipSeason}';
    perSeason[key] = (perSeason[key] ?? 0) + 1;
    fullSeason.reach(perSeason[key]!, session);
  }

  final placings = [...facts.seasonPlacings]
    ..sort((a, b) => a.endedAt.compareTo(b.endedAt));
  for (final placing in placings) {
    final at = placing.endedAt;
    // A shared place counts for nothing (Q138, Q139).
    if (placing.shared) continue;
    if (placing.position == 1) champion.reach(1, null, at: at);
    if (placing.position <= 3) seasonPodium.reach(1, null, at: at);
    if (placing.position <= 5) topFive.reach(1, null, at: at);
  }

  return [competitor, fullSeason, champion, seasonPodium, topFive].results();
}
