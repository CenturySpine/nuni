import 'badge.dart';
import 'badge_facts.dart';
import 'rules/attendance.dart';
import 'rules/championship.dart';
import 'rules/conditions.dart';
import 'rules/explorer.dart';
import 'rules/fun.dart';
import 'rules/regularity.dart';
import 'rules/strokes.dart';
import 'rules/team.dart';
import 'rules/wins.dart';

/// Every badge of the catalogue for one player, in [BadgeId] order,
/// recomputed from their history (plan 21, decision 8: no badge is stored).
List<BadgeResult> computeBadges(BadgeFacts facts) {
  final byId = {
    for (final result in [
      ...attendanceBadges(facts),
      ...regularityBadges(facts),
      ...strokeBadges(facts),
      ...winBadges(facts),
      ...championshipBadges(facts),
      ...teamBadges(facts),
      ...explorerBadges(facts),
      ...conditionBadges(facts),
      ...funBadges(facts),
    ])
      result.id: result,
  };
  return [for (final id in BadgeId.values) byId[id]!];
}

/// Up to [count] badges still to earn that are closest to being earned
/// (Q128, "badges proches"): counter badges already started, the most
/// advanced first.
List<BadgeResult> nearBadges(List<BadgeResult> results, {int count = 3}) {
  final started =
      [
        for (final r in results)
          if (!r.earned && r.id.target != null && r.progress > 0) r,
      ]..sort((a, b) {
        final byRatio = b.ratio.compareTo(a.ratio);
        if (byRatio != 0) return byRatio;
        // Closer in absolute terms first: 9 / 10 before 45 / 50; then the
        // catalogue order.
        final byRemaining = (a.id.target! - a.progress).compareTo(
          b.id.target! - b.progress,
        );
        return byRemaining != 0
            ? byRemaining
            : a.id.index.compareTo(b.id.index);
      });
  return started.take(count).toList();
}
