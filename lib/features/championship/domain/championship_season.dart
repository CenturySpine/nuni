/// Mirrors the `sessions.championship_season` generated column (plan 15,
/// Q38): a season runs from September to August, named "Y-Y+1" -- named
/// after the calendar year it starts in, regardless of when within it a
/// session was played.
String championshipSeasonFor(DateTime date) {
  final year = date.year;
  return date.month >= 9 ? '$year-${year + 1}' : '${year - 1}-$year';
}

String currentChampionshipSeason() => championshipSeasonFor(DateTime.now());

/// The last moment of a season ("2024-2025" ends on 31 August 2025, local
/// time): a season is finished once this has passed (plan 21, E3 to E5).
DateTime championshipSeasonEnd(String season) {
  final endYear = int.parse(season.split('-').last);
  return DateTime(endYear, 8, 31, 23, 59, 59);
}
