/// Which sessions a family's badges read (PO, 2026-09-25): shown as a pill
/// next to the family name.
enum BadgeScope { individual, team, both }

/// The badge families of plan 21 ("Catalogue retenu"), in display order,
/// with the sessions they read: rankings and strokes are individual (Q90,
/// Q138), their team version is in [team] (Q141), the rest reads both.
/// H (contributions) and J (records) come with the second lot (Q137).
enum BadgeFamily {
  attendance(BadgeScope.both),
  regularity(BadgeScope.both),
  strokes(BadgeScope.individual),
  wins(BadgeScope.individual),
  championship(BadgeScope.both),
  team(BadgeScope.team),
  explorer(BadgeScope.both),
  builder(BadgeScope.both),
  conditions(BadgeScope.both),
  records(BadgeScope.individual),
  fun(BadgeScope.individual);

  const BadgeFamily(this.scope);

  final BadgeScope scope;
}

/// A medal's ring (Q114): bronze, silver, gold in order of difficulty in a
/// series; a single badge has none.
enum BadgeTier { none, bronze, silver, gold }

/// Every badge of the catalogue (plan 21, Q96), with its family, its ring,
/// the stars past gold (A5, A6) and, for a counter badge, the count it
/// needs (its progress shows as "7 / 10"). Names and conditions live in the
/// ARB files, keyed by [name]. Codes (A1...) follow the plan.
enum BadgeId {
  // A. Attendance.
  firstStart(BadgeFamily.attendance, target: 1),
  regular(BadgeFamily.attendance, tier: BadgeTier.bronze, target: 5),
  pillar(BadgeFamily.attendance, tier: BadgeTier.silver, target: 10),
  addict(BadgeFamily.attendance, tier: BadgeTier.gold, target: 25),
  streetLegend(
    BadgeFamily.attendance,
    tier: BadgeTier.gold,
    stars: 1,
    target: 50,
  ),
  centurion(
    BadgeFamily.attendance,
    tier: BadgeTier.gold,
    stars: 2,
    target: 100,
  ),
  fiftyHoles(BadgeFamily.attendance, tier: BadgeTier.bronze, target: 50),
  hundredHoles(BadgeFamily.attendance, tier: BadgeTier.silver, target: 100),

  // B. Regularity.
  appointment(BadgeFamily.regularity, target: 4),
  metronome(BadgeFamily.regularity, target: 8),
  busyWeek(BadgeFamily.regularity, target: 3),
  fourSeasons(BadgeFamily.regularity, target: 4),
  veteran(BadgeFamily.regularity),
  allYear(BadgeFamily.regularity, target: 12),

  // C. Strokes (individual sessions).
  onPar(BadgeFamily.strokes),
  birdie(BadgeFamily.strokes, tier: BadgeTier.bronze),
  eagle(BadgeFamily.strokes, tier: BadgeTier.silver),
  albatross(BadgeFamily.strokes, tier: BadgeTier.gold),
  holeInOne(BadgeFamily.strokes),
  birdieFlock(BadgeFamily.strokes, tier: BadgeTier.bronze, target: 10),
  birdieSwarm(BadgeFamily.strokes, tier: BadgeTier.silver, target: 50),
  parStreak(BadgeFamily.strokes),
  hotHand(BadgeFamily.strokes),
  clean(BadgeFamily.strokes),
  underPar(BadgeFamily.strokes),
  bounceBack(BadgeFamily.strokes),
  steady(BadgeFamily.strokes),

  // D. Wins and session standings.
  firstWin(BadgeFamily.wins, tier: BadgeTier.bronze, target: 1),
  winner(BadgeFamily.wins, tier: BadgeTier.silver, target: 5),
  dominator(BadgeFamily.wins, tier: BadgeTier.gold, target: 25),
  hatTrick(BadgeFamily.wins, target: 3),
  onTheBox(BadgeFamily.wins, tier: BadgeTier.bronze, target: 1),
  podiumRegular(BadgeFamily.wins, tier: BadgeTier.silver, target: 10),
  wireToWire(BadgeFamily.wins),
  comeback(BadgeFamily.wins),
  photoFinish(BadgeFamily.wins),
  holdUp(BadgeFamily.wins),

  // E. Championship.
  competitor(BadgeFamily.championship, target: 1),
  fullSeason(BadgeFamily.championship, target: 5),
  champion(BadgeFamily.championship, tier: BadgeTier.gold),
  seasonPodium(BadgeFamily.championship, tier: BadgeTier.silver),
  topFive(BadgeFamily.championship, tier: BadgeTier.bronze),

  // F. Team play.
  teammate(BadgeFamily.team, target: 1),
  gatherer(BadgeFamily.team, target: 5),
  dreamTeam(BadgeFamily.team, target: 5),
  // Team versions of the ranking badges (Q141): same rules, in team
  // sessions -- easier with a good teammate, accepted by the PO.
  teamFirstWin(BadgeFamily.team, tier: BadgeTier.bronze, target: 1),
  teamWinner(BadgeFamily.team, tier: BadgeTier.silver, target: 5),
  teamDominator(BadgeFamily.team, tier: BadgeTier.gold, target: 25),
  teamHatTrick(BadgeFamily.team, target: 3),
  teamOnTheBox(BadgeFamily.team, tier: BadgeTier.bronze, target: 1),
  teamPodiumRegular(BadgeFamily.team, tier: BadgeTier.silver, target: 10),
  teamWireToWire(BadgeFamily.team),
  teamComeback(BadgeFamily.team),
  teamPhotoFinish(BadgeFamily.team),
  teamHoldUp(BadgeFamily.team),
  teamRedLantern(BadgeFamily.team),
  teamPersistent(BadgeFamily.team, target: 5),

  // G. Explorer.
  curious(BadgeFamily.explorer, tier: BadgeTier.bronze, target: 5),
  explorer(BadgeFamily.explorer, tier: BadgeTier.silver, target: 15),
  globetrotter(BadgeFamily.explorer, target: 3),
  guest(BadgeFamily.explorer),
  improviser(BadgeFamily.explorer, target: 10),

  // H. Builder: what the player's account added to the app.
  flagPlanter(BadgeFamily.builder, tier: BadgeTier.bronze, target: 1),
  landscaper(BadgeFamily.builder, tier: BadgeTier.silver, target: 5),
  architect(BadgeFamily.builder, target: 10),
  organizer(BadgeFamily.builder, tier: BadgeTier.bronze, target: 1),
  gameMaster(BadgeFamily.builder, tier: BadgeTier.silver, target: 10),
  reporter(BadgeFamily.builder, tier: BadgeTier.bronze, target: 1),
  photographer(BadgeFamily.builder, tier: BadgeTier.silver, target: 10),

  // I. Playing conditions.
  rain(BadgeFamily.conditions),
  frosty(BadgeFamily.conditions),
  heatwave(BadgeFamily.conditions),
  gust(BadgeFamily.conditions),
  nightOwl(BadgeFamily.conditions),
  earlyBird(BadgeFamily.conditions),
  marathon(BadgeFamily.conditions),
  snow(BadgeFamily.conditions),

  // J. Hole records, all time only (Q136).
  recordHolder(BadgeFamily.records),
  recordCollector(BadgeFamily.records, target: 5),
  recordHunter(BadgeFamily.records, target: 10),
  rampart(BadgeFamily.records, target: 3),
  confidence(BadgeFamily.records),
  holeKing(BadgeFamily.records),
  // Losing a title, the first time (Q142): a reason to come back for it;
  // and taking a king's title from them.
  fallenRecord(BadgeFamily.records),
  dethroned(BadgeFamily.records),
  regicide(BadgeFamily.records),

  // K. Fun.
  redLantern(BadgeFamily.fun),
  adultsOnly(BadgeFamily.fun),
  persistent(BadgeFamily.fun, target: 5),
  rollerCoaster(BadgeFamily.fun);

  const BadgeId(
    this.family, {
    this.tier = BadgeTier.none,
    this.stars = 0,
    this.target,
  });

  final BadgeFamily family;
  final BadgeTier tier;
  final int stars;

  /// The count a counter badge needs; null for a one-off feat.
  final int? target;
}

/// A badge for one player: earned or not, when and in which session it was
/// earned (the session that crossed the threshold, plan 21 "Date
/// d'obtention"), and how far along a counter badge is.
class BadgeResult {
  const BadgeResult({
    required this.id,
    this.earnedAt,
    this.sessionId,
    this.progress = 0,
  });

  final BadgeId id;
  final DateTime? earnedAt;

  /// The session that earned it; null for a championship season placing.
  final String? sessionId;

  /// Towards [BadgeId.target]; capped at it once earned.
  final int progress;

  bool get earned => earnedAt != null;

  /// How far along a counter badge is, 0 to 1; 0 for a one-off feat.
  double get ratio {
    final target = id.target;
    if (target == null || target == 0) return earned ? 1 : 0;
    return (progress / target).clamp(0, 1).toDouble();
  }
}
