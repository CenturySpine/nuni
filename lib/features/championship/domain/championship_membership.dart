/// One zone/season a player has at least one championship session in
/// (plan 15, decision 5: a player can appear in several zones the same
/// season).
typedef ChampionshipMembership = ({String zoneId, String season});

/// The home tab's championship history (plan 15, Q72): every zone/season but
/// [currentSeason], most recent season first (seasons are "Y-Y+1", so a plain
/// string comparison orders them), zones in their original order within a
/// season.
List<ChampionshipMembership> pastMemberships(
  List<ChampionshipMembership> memberships,
  String currentSeason,
) {
  final past = [
    for (final m in memberships)
      if (m.season != currentSeason) m,
  ];
  final order = {for (var i = 0; i < past.length; i++) past[i]: i};
  return past..sort((a, b) {
    final bySeason = b.season.compareTo(a.season);
    return bySeason != 0 ? bySeason : order[a]!.compareTo(order[b]!);
  });
}
