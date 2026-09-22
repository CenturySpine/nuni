/// Mirrors the `sessions.championship_season` generated column (plan 15,
/// Q38): a season runs from September to August, named "Y-Y+1" -- named
/// after the calendar year it starts in, regardless of when within it a
/// session was played.
String championshipSeasonFor(DateTime date) {
  final year = date.year;
  return date.month >= 9 ? '$year-${year + 1}' : '${year - 1}-$year';
}

String currentChampionshipSeason() => championshipSeasonFor(DateTime.now());
