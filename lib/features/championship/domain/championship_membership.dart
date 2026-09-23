/// One association/season a player has at least one championship session in
/// (plans 15 and 18, Q77: a visitor also appears in the championship of the
/// association that hosted them, so several the same season).
typedef ChampionshipMembership = ({String associationId, String season});

/// The associations of [season]'s championships, [myAssociationId] first
/// (PO, 2026-09-23, Q88: the home tab shows every championship played,
/// visiting included, mine on top), the others in their original order.
List<String> seasonAssociationIds(
  List<ChampionshipMembership> memberships,
  String season,
  String? myAssociationId,
) {
  final ids = {
    for (final m in memberships)
      if (m.season == season) m.associationId,
  }.toList();
  return [
    ...ids.where((id) => id == myAssociationId),
    ...ids.where((id) => id != myAssociationId),
  ];
}

/// The home tab's championship history (plan 15, Q72): every association/season but
/// [currentSeason], most recent season first (seasons are "Y-Y+1", so a plain
/// string comparison orders them); within a season, [myAssociationId] first
/// (Q88), then the others in their original order.
List<ChampionshipMembership> pastMemberships(
  List<ChampionshipMembership> memberships,
  String currentSeason, {
  String? myAssociationId,
}) {
  final past = [
    for (final m in memberships)
      if (m.season != currentSeason) m,
  ];
  final order = {for (var i = 0; i < past.length; i++) past[i]: i};
  int mineFirst(ChampionshipMembership m) =>
      m.associationId == myAssociationId ? 0 : 1;
  return past..sort((a, b) {
    final bySeason = b.season.compareTo(a.season);
    if (bySeason != 0) return bySeason;
    final byMine = mineFirst(a).compareTo(mineFirst(b));
    return byMine != 0 ? byMine : order[a]!.compareTo(order[b]!);
  });
}
