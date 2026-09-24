import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/core/weather/weather.dart';
import 'package:nuni/features/badges/domain/badge.dart';
import 'package:nuni/features/badges/domain/badge_facts.dart';
import 'package:nuni/features/badges/domain/compute_badges.dart';
import 'package:nuni/features/live/domain/live_session_snapshot.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';
import 'package:nuni/features/sessions/domain/session_kind.dart';

import '../../stats/domain/stats_fixtures.dart';

/// An individual session of the player "p" against "x" and "y" (and "z"
/// when given): one value per hole each, null where "p" has no score.
/// Defaults: 3 par-3 holes, p on 3, x on 4, y on 5 -- p wins.
LiveSessionSnapshot game({
  String id = 's',
  DateTime? at,
  List<int?> me = const [3, 3, 3],
  List<int>? x,
  List<int>? y,
  List<int>? z,
  List<int>? pars,
  List<String?>? holeIds,
  ScoringMode mode = ScoringMode.strokePlay,
  Weather? weather,
  (double, double)? place,
  bool championship = false,
  String association = 'a1',
  String season = '2025-2026',
}) {
  final n = me.length;
  final xs = x ?? List.filled(n, 4);
  final ys = y ?? List.filled(n, 5);
  final base = individualSession(
    id: id,
    playerIds: ['p', 'x', 'y', if (z != null) 'z'],
    startedAt: at ?? DateTime(2026, 1, 1, 12),
    scoringMode: mode,
    holes: [
      for (var i = 0; i < n; i++)
        hole(
          i + 1,
          {
            if (me[i] != null) 't-p': me[i]!,
            't-x': xs[i],
            't-y': ys[i],
            if (z != null) 't-z': z[i],
          },
          par: pars?[i] ?? 3,
          holeId: holeIds == null ? 'h${i + 1}' : holeIds[i],
        ),
    ],
  );
  return LiveSessionSnapshot(
    session: base.session.copyWith(
      weather: weather,
      locationLat: place?.$1,
      locationLng: place?.$2,
      isChampionship: championship,
      associationId: association,
      championshipSeason: season,
    ),
    members: const [],
    teams: base.teams,
    playedHoles: base.playedHoles,
  );
}

/// A team session: "p" with [mate] against two others; p's team on 3,
/// the other on 4 unless [win] is false.
LiveSessionSnapshot teamGame({
  String id = 't',
  DateTime? at,
  String mate = 'q',
  bool win = true,
}) => snapshot(
  id: id,
  kind: SessionKind.team,
  startedAt: at,
  teams: [
    team('tA', ['p', mate]),
    team('tB', const ['r', 's']),
  ],
  holes: [
    for (var i = 1; i <= 3; i++) hole(i, {'tA': win ? 3 : 5, 'tB': 4}),
  ],
);

List<LiveSessionSnapshot> games(
  int count, {
  DateTime? from,
  List<int?> me = const [3, 3, 3],
  List<int>? x,
  List<int>? y,
  List<int>? z,
  bool championship = false,
}) => [
  for (var i = 0; i < count; i++)
    game(
      id: 's$i',
      at: (from ?? DateTime(2026, 1, 1, 12)).add(Duration(days: i)),
      me: me,
      x: x,
      y: y,
      z: z,
      championship: championship,
    ),
];

Map<BadgeId, BadgeResult> badges(
  List<LiveSessionSnapshot> history, {
  String association = 'a1',
  List<SeasonPlacing> placings = const [],
}) => {
  for (final r in computeBadges(
    BadgeFacts(
      playerId: 'p',
      associationId: association,
      history: history,
      seasonPlacings: placings,
    ),
  ))
    r.id: r,
};

void expectBadge(
  List<LiveSessionSnapshot> earnedWith,
  List<LiveSessionSnapshot> notWith,
  BadgeId id,
) {
  expect(badges(earnedWith)[id]!.earned, isTrue, reason: '$id earned');
  expect(badges(notWith)[id]!.earned, isFalse, reason: '$id not earned');
}

DateTime day(int y, int m, int d, [int h = 12, int min = 0]) =>
    DateTime(y, m, d, h, min);

void main() {
  test('every badge of the lot has a result, in catalogue order', () {
    final results = computeBadges(
      BadgeFacts(playerId: 'p', associationId: 'a1', history: const []),
    );
    expect(results.map((r) => r.id), BadgeId.values);
    expect(results.where((r) => r.earned), isEmpty);
  });

  test('only eligible sessions count (a duel gives nothing)', () {
    final duel = individualSession(
      playerIds: const ['p', 'x'],
      holes: [
        for (var i = 1; i <= 3; i++) hole(i, {'t-p': 1, 't-x': 4}),
      ],
    );
    expect(badges([duel])[BadgeId.firstStart]!.earned, isFalse);
  });

  test('earned on the session that crosses the threshold', () {
    final result = badges(games(6))[BadgeId.regular]!;
    expect(result.sessionId, 's4');
    expect(result.earnedAt, day(2026, 1, 5));
    expect(result.progress, 5);
  });

  group('A. attendance', () {
    for (final (id, target) in [
      (BadgeId.firstStart, 1),
      (BadgeId.regular, 5),
      (BadgeId.pillar, 10),
      (BadgeId.addict, 25),
      (BadgeId.streetLegend, 50),
      (BadgeId.centurion, 100),
    ]) {
      test('$id: $target sessions', () {
        expectBadge(games(target), games(target - 1), id);
      });
    }
    test('fiftyHoles and hundredHoles', () {
      final ten = List<int?>.filled(10, 3);
      expectBadge(games(5, me: ten), games(4, me: ten), BadgeId.fiftyHoles);
      expectBadge(games(10, me: ten), games(9, me: ten), BadgeId.hundredHoles);
      expect(badges(games(4, me: ten))[BadgeId.fiftyHoles]!.progress, 40);
    });
  });

  group('B. regularity', () {
    List<LiveSessionSnapshot> on(List<DateTime> dates) => [
      for (var i = 0; i < dates.length; i++) game(id: 'b$i', at: dates[i]),
    ];
    List<DateTime> weekly(int count, {int skip = -1}) => [
      for (var i = 0; i <= count; i++)
        if (i != skip && (skip >= 0 || i < count))
          day(2026, 1, 5).add(Duration(days: 7 * i)),
    ];

    test('appointment: 4 weeks in a row', () {
      expectBadge(on(weekly(4)), on(weekly(4, skip: 2)), BadgeId.appointment);
    });
    test('metronome: 8 weeks in a row', () {
      expectBadge(on(weekly(8)), on(weekly(8, skip: 4)), BadgeId.metronome);
    });
    test('busy week: 3 sessions Monday to Sunday', () {
      expectBadge(
        on([day(2026, 1, 5), day(2026, 1, 7), day(2026, 1, 11)]),
        on([day(2026, 1, 5), day(2026, 1, 11), day(2026, 1, 12)]),
        BadgeId.busyWeek,
      );
    });
    test('four seasons', () {
      expectBadge(
        on([
          day(2026, 1, 5),
          day(2026, 4, 5),
          day(2026, 7, 5),
          day(2026, 10, 5),
        ]),
        on([
          day(2026, 1, 5),
          day(2026, 2, 5),
          day(2026, 4, 5),
          day(2026, 7, 5),
        ]),
        BadgeId.fourSeasons,
      );
    });
    test('veteran: playing more than a year after the first session', () {
      expectBadge(
        on([day(2025, 1, 1), day(2026, 1, 2)]),
        on([day(2025, 1, 1), day(2025, 12, 31)]),
        BadgeId.veteran,
      );
    });
    test('all year: every month', () {
      expectBadge(
        on([for (var m = 1; m <= 12; m++) day(2026, m, 3)]),
        on([for (var m = 1; m <= 11; m++) day(2026, m, 3)]),
        BadgeId.allYear,
      );
    });
  });

  group('C. strokes', () {
    void feat(BadgeId id, List<int?> yes, List<int?> no, {List<int>? pars}) {
      expectBadge(
        [
          game(
            me: yes,
            pars: pars,
            x: List.filled(yes.length, 9),
            y: List.filled(yes.length, 9),
          ),
        ],
        [
          game(
            me: no,
            pars: pars,
            x: List.filled(no.length, 9),
            y: List.filled(no.length, 9),
          ),
        ],
        id,
      );
    }

    test('on par, birdie, eagle, albatross, hole in one', () {
      feat(BadgeId.onPar, [3, 4, 4], [4, 4, 4]);
      feat(BadgeId.birdie, [2, 4, 4], [3, 3, 3]);
      feat(BadgeId.eagle, [2, 4, 4], [3, 4, 4], pars: [4, 3, 3]);
      feat(BadgeId.albatross, [2, 4, 4], [3, 4, 4], pars: [5, 3, 3]);
      feat(BadgeId.holeInOne, [1, 4, 4], [2, 4, 4]);
    });
    test('birdies cumulated', () {
      expectBadge(
        games(4, me: [2, 2, 2]),
        games(3, me: [2, 2, 2]),
        BadgeId.birdieFlock,
      );
      expectBadge(
        games(17, me: [2, 2, 2]),
        games(16, me: [2, 2, 2]),
        BadgeId.birdieSwarm,
      );
    });
    test('series: an unentered hole breaks them', () {
      feat(BadgeId.parStreak, [3, 3, 3], [3, 4, 3]);
      feat(BadgeId.hotHand, [2, 2, 2], [2, null, 2, 2]);
    });
    test('clean: 6 holes or more, no bogey', () {
      feat(BadgeId.clean, [3, 3, 3, 3, 3, 2], [3, 3, 3, 3, 3]);
      feat(BadgeId.clean, [2, 3, 3, 3, 3, 3], [3, 3, 3, 3, 3, 4]);
    });
    test('under par, bounce back, steady', () {
      feat(BadgeId.underPar, [2, 3, 3], [2, 4, 3]);
      feat(BadgeId.bounceBack, [5, 2, 3], [4, 2, 3]);
      feat(BadgeId.steady, [2, 3, 4, 3, 3, 3], [2, 3, 5, 3, 3, 3]);
    });
    test('team sessions and Free scoring never count strokes', () {
      final free = game(me: [1, 1, 1], mode: ScoringMode.free);
      expect(badges([free])[BadgeId.holeInOne]!.earned, isFalse);
      final teams = snapshot(
        kind: SessionKind.team,
        teams: [
          team('tA', const ['p', 'q']),
          team('tB', const ['r', 's']),
        ],
        holes: [
          for (var i = 1; i <= 3; i++) hole(i, {'tA': 1, 'tB': 4}),
        ],
      );
      expect(badges([teams])[BadgeId.holeInOne]!.earned, isFalse);
    });
  });

  group('D. wins', () {
    final lose = game(me: [6, 6, 6]);
    List<LiveSessionSnapshot> wins(int n) => games(n);

    test('wins cumulated', () {
      expectBadge(wins(1), [lose], BadgeId.firstWin);
      expectBadge(wins(5), wins(4), BadgeId.winner);
      expectBadge(wins(25), wins(24), BadgeId.dominator);
    });
    test('hat-trick: three wins in a row', () {
      final w = games(4);
      expectBadge(w.take(3).toList(), [
        w[0],
        w[1],
        game(id: 'l', at: day(2026, 1, 2, 18), me: [6, 6, 6]),
        w[3],
      ], BadgeId.hatTrick);
    });
    test('podiums need a fourth player to miss one', () {
      final last = games(1, me: [9, 9, 9], z: [4, 4, 4]);
      expectBadge(games(1, me: [6, 6, 6]), last, BadgeId.onTheBox);
      expectBadge(games(10), games(9), BadgeId.podiumRegular);
    });
    test('wire to wire: first after every hole', () {
      expectBadge(
        [
          game(me: [2, 3, 3], x: [3, 3, 3]),
        ],
        [
          game(me: [4, 2, 2], x: [3, 3, 3]),
        ],
        BadgeId.wireToWire,
      );
    });
    test('comeback: last at half-time, then the win', () {
      expectBadge(
        [
          game(me: [5, 5, 1, 1], x: [3, 3, 4, 4], y: [4, 4, 4, 4]),
        ],
        [
          game(me: [3, 3, 3, 3], x: [4, 4, 4, 4], y: [5, 5, 5, 5]),
        ],
        BadgeId.comeback,
      );
    });
    test('photo finish: one stroke ahead', () {
      expectBadge(
        [
          game(me: [3, 3, 3], x: [3, 3, 4]),
        ],
        [game()],
        BadgeId.photoFinish,
      );
    });
    test('hold-up: behind before the last hole, alone first at the end', () {
      expectBadge(
        [
          game(me: [4, 4, 1], x: [3, 3, 4]),
        ],
        [
          game(me: [4, 4, 2], x: [3, 3, 4]),
        ],
        BadgeId.holdUp,
      );
    });
    test('team versions only read team sessions (Q141)', () {
      expectBadge([teamGame()], [game()], BadgeId.teamFirstWin);
      expectBadge([game()], [teamGame()], BadgeId.firstWin);
      expectBadge(
        [for (var i = 0; i < 3; i++) teamGame(id: 't$i')],
        [teamGame(id: 'a'), teamGame(id: 'b', win: false), teamGame(id: 'c')],
        BadgeId.teamHatTrick,
      );
      expectBadge(
        [teamGame(win: false)],
        [
          game(me: [6, 6, 6]),
        ],
        BadgeId.teamRedLantern,
      );
      expectBadge(
        [
          game(me: [6, 6, 6]),
        ],
        [teamGame(win: false)],
        BadgeId.redLantern,
      );
    });
  });

  group('E. championship', () {
    test('championship sessions', () {
      expectBadge([game(championship: true)], [game()], BadgeId.competitor);
      expectBadge(
        games(5, championship: true),
        games(4, championship: true),
        BadgeId.fullSeason,
      );
    });
    test('season places', () {
      Map<BadgeId, BadgeResult> placed(int position) => badges(
        const [],
        placings: [
          SeasonPlacing(
            associationId: 'a1',
            season: '2024-2025',
            position: position,
            endedAt: DateTime(2025, 8, 31),
          ),
        ],
      );
      expect(placed(1)[BadgeId.champion]!.earned, isTrue);
      expect(placed(2)[BadgeId.champion]!.earned, isFalse);
      expect(placed(3)[BadgeId.seasonPodium]!.earned, isTrue);
      expect(placed(4)[BadgeId.seasonPodium]!.earned, isFalse);
      expect(placed(5)[BadgeId.topFive]!.earned, isTrue);
      expect(placed(6)[BadgeId.topFive]!.earned, isFalse);
      expect(placed(1)[BadgeId.champion]!.earnedAt, DateTime(2025, 8, 31));
    });
  });

  group('F. team', () {
    test('team sessions and teammates', () {
      expectBadge([teamGame()], [game()], BadgeId.teammate);
      expectBadge(
        [for (var i = 0; i < 5; i++) teamGame(id: 't$i', mate: 'q$i')],
        [for (var i = 0; i < 4; i++) teamGame(id: 't$i', mate: 'q$i')],
        BadgeId.gatherer,
      );
      expectBadge(
        [for (var i = 0; i < 5; i++) teamGame(id: 't$i')],
        [for (var i = 0; i < 4; i++) teamGame(id: 't$i')],
        BadgeId.dreamTeam,
      );
    });
  });

  group('G. explorer', () {
    LiveSessionSnapshot on(String id, List<String?> holes) => game(
      id: id,
      me: List.filled(holes.length, 3),
      holeIds: holes,
      x: List.filled(holes.length, 4),
      y: List.filled(holes.length, 5),
    );

    test('different directory holes', () {
      expectBadge(
        [
          on('1', ['a', 'b', 'c']),
          on('2', ['d', 'e', 'c']),
        ],
        [
          on('1', ['a', 'b', 'c']),
          on('2', ['a', 'b', 'd']),
        ],
        BadgeId.curious,
      );
      List<LiveSessionSnapshot> distinct(int n) => [
        for (var i = 0; i < 5; i++)
          on('$i', [for (var j = 0; j < 3; j++) 'h${(i * 3 + j) % n}']),
      ];
      expectBadge(distinct(15), distinct(14), BadgeId.explorer);
    });
    test('globetrotter: three sessions 50 km apart from each other', () {
      const lyon = (45.76, 4.83);
      const villeurbanne = (45.77, 4.88);
      const paris = (48.85, 2.35);
      const marseille = (43.30, 5.37);
      expectBadge(
        [
          game(id: '1', place: lyon),
          game(id: '2', place: paris),
          game(id: '3', place: marseille),
        ],
        [
          game(id: '1', place: lyon),
          game(id: '2', place: villeurbanne),
          game(id: '3', place: paris),
        ],
        BadgeId.globetrotter,
      );
    });
    test('guest: a session of another association', () {
      expectBadge([game(association: 'a2')], [game()], BadgeId.guest);
    });
    test('improviser: free holes', () {
      expectBadge(
        [on('1', List.filled(5, null)), on('2', List.filled(5, null))],
        [on('1', List.filled(5, null)), on('2', List.filled(4, null))],
        BadgeId.improviser,
      );
    });
  });

  group('I. conditions', () {
    LiveSessionSnapshot w(double temp, double wind, int code) => game(
      weather: Weather(temperatureC: temp, windKph: wind, code: code),
    );

    test('weather at the start', () {
      expectBadge([w(15, 5, 61)], [w(15, 5, 95), game()], BadgeId.rain);
      expectBadge([w(15, 5, 71)], [w(15, 5, 61)], BadgeId.snow);
      expectBadge([w(2, 5, 0)], [w(3, 5, 0)], BadgeId.frosty);
      expectBadge([w(31, 5, 0)], [w(30, 5, 0)], BadgeId.heatwave);
      expectBadge([w(15, 31, 0)], [w(15, 30, 0)], BadgeId.gust);
    });
    test('start time and length', () {
      expectBadge(
        [game(at: day(2026, 1, 1, 21))],
        [game(at: day(2026, 1, 1, 20, 59))],
        BadgeId.nightOwl,
      );
      expectBadge(
        [game(at: day(2026, 1, 1, 8, 59))],
        [game(at: day(2026, 1, 1, 9))],
        BadgeId.earlyBird,
      );
      expectBadge(
        [
          game(
            me: List.filled(9, 3),
            x: List.filled(9, 4),
            y: List.filled(9, 5),
          ),
        ],
        [
          game(
            me: List.filled(8, 3),
            x: List.filled(8, 4),
            y: List.filled(8, 5),
          ),
        ],
        BadgeId.marathon,
      );
    });
  });

  group('Q138: alone in first or last place, individual sessions only', () {
    final tiedFirst = game(me: [3, 3, 3], x: [3, 3, 3]);
    final aloneLast = game(me: [6, 6, 6]);
    final tiedLast = game(me: [6, 6, 6], y: [6, 6, 6]);

    test('a tie for first is no win', () {
      expectBadge([game()], [tiedFirst], BadgeId.firstWin);
    });
    test('a tie for last is no last place', () {
      expectBadge([aloneLast], [tiedLast], BadgeId.redLantern);
    });
    test('a tie for third is no podium (Q139)', () {
      final aloneThird = game(me: [5, 5, 5], y: [6, 6, 6], z: [9, 9, 9]);
      final tiedThird = game(me: [5, 5, 5], y: [5, 5, 5], z: [9, 9, 9]);
      expectBadge([aloneThird], [tiedThird], BadgeId.onTheBox);
    });
    test('wire to wire needs the lead alone after every hole', () {
      expectBadge(
        [
          game(me: [2, 3, 3], x: [3, 3, 3]),
        ],
        [
          game(me: [3, 2, 3], x: [3, 3, 3]),
        ],
        BadgeId.wireToWire,
      );
    });
    test('team sessions count, except for ranking badges', () {
      final teams = [
        for (var i = 0; i < 5; i++)
          teamGame(id: 't$i', at: DateTime(2026, 1, 1 + i)),
      ];
      final results = badges(teams);
      expect(results[BadgeId.regular]!.earned, isTrue);
      expect(results[BadgeId.busyWeek]!.earned, isTrue);
      expect(results[BadgeId.firstWin]!.earned, isFalse);
      expect(results[BadgeId.onTheBox]!.earned, isFalse);
      expect(
        badges([teamGame(win: false)])[BadgeId.redLantern]!.earned,
        isFalse,
      );
      expect(results[BadgeId.teammate]!.earned, isTrue);
      expect(results[BadgeId.dreamTeam]!.earned, isTrue);
      expect(results[BadgeId.teamFirstWin]!.earned, isTrue);
    });
    test('a shared championship title is no title', () {
      Map<BadgeId, BadgeResult> placed({required bool shared}) => badges(
        const [],
        placings: [
          SeasonPlacing(
            associationId: 'a1',
            season: '2024-2025',
            position: 1,
            endedAt: DateTime(2025, 8, 31),
            shared: shared,
          ),
        ],
      );
      expect(placed(shared: false)[BadgeId.champion]!.earned, isTrue);
      expect(placed(shared: true)[BadgeId.champion]!.earned, isFalse);
      expect(placed(shared: true)[BadgeId.seasonPodium]!.earned, isFalse);
    });
  });

  group('K. fun', () {
    final last = game(me: [6, 6, 6]);
    final tied = game(me: [4, 4, 4], x: [4, 4, 4], y: [4, 4, 4]);

    test('last places, but not on a fully tied board', () {
      expectBadge([last], [tied, game()], BadgeId.redLantern);
      expectBadge(
        [
          for (var i = 0; i < 5; i++) game(id: 'l$i', me: [6, 6, 6]),
        ],
        [
          for (var i = 0; i < 4; i++) game(id: 'l$i', me: [6, 6, 6]),
        ],
        BadgeId.persistent,
      );
    });
    test('an X, and a birdie with an X', () {
      expectBadge(
        [
          game(me: [10, 3, 3], x: [11, 11, 11]),
        ],
        [
          game(me: [9, 3, 3], x: [11, 11, 11]),
        ],
        BadgeId.adultsOnly,
      );
      expectBadge(
        [
          game(me: [2, 10, 3], x: [11, 11, 11]),
        ],
        [
          game(me: [3, 10, 3], x: [11, 11, 11]),
        ],
        BadgeId.rollerCoaster,
      );
    });
  });

  test('near badges: started counters, most advanced first', () {
    final near = nearBadges(
      computeBadges(
        BadgeFacts(playerId: 'p', associationId: 'a1', history: games(9)),
      ),
    );
    expect(near.length, 3);
    expect(near.first.id, BadgeId.pillar);
    expect(near.every((r) => !r.earned && r.progress > 0), isTrue);
  });
}
