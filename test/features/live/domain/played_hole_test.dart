import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/live/domain/played_hole.dart';
import 'package:nuni/features/live/ui/played_hole_label.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';

void main() {
  Map<String, Object?> row({
    Map<String, Object?>? hole,
    String? label,
    int par = 3,
    String? comment,
  }) => {
    'id': 'ph1',
    'position': 3,
    'game_mode': 'individual',
    'label': label,
    'par': par,
    'comment': comment,
    'hole': hole,
    'scores': [
      {'team_id': 't1', 'value': 4},
    ],
  };

  final directoryHole = {
    'id': 'h1',
    'name': 'Le Ficus',
    'par': 3,
    'start_lat': 48.8534,
    'start_lng': 2.3488,
  };

  test('reads a directory hole from a session_snapshot entry', () {
    final playedHole = PlayedHole.fromJson(row(hole: directoryHole));

    expect(playedHole.isFreeHole, isFalse);
    expect(playedHole.customName, 'Le Ficus');
  });

  test('reads a free hole (no directory hole) with its label (plan 17)', () {
    final playedHole = PlayedHole.fromJson(row(label: 'Test escalier'));

    expect(playedHole.hole, isNull);
    expect(playedHole.isFreeHole, isTrue);
    expect(playedHole.customName, 'Test escalier');
    expect(playedHole.valueByTeamId, {'t1': 4});
  });

  test('reads the session par and comment (plan 26)', () {
    final playedHole = PlayedHole.fromJson(
      row(hole: directoryHole, par: 5, comment: 'From the bench'),
    );

    expect(playedHole.par, 5);
    expect(playedHole.comment, 'From the bench');
  });

  test('differingOfficialPar recalls the hole par only when it differs', () {
    expect(
      PlayedHole.fromJson(row(hole: directoryHole)).differingOfficialPar,
      isNull,
    );
    expect(
      PlayedHole.fromJson(row(hole: directoryHole, par: 4))
          .differingOfficialPar,
      3,
    );
    // A free hole has no official par to recall.
    expect(PlayedHole.fromJson(row(par: 4)).differingOfficialPar, isNull);
  });

  test('an unlabelled free hole is named "Free hole" / "Trou libre"', () {
    final playedHole = PlayedHole.fromJson(row());

    expect(playedHole.customName, isNull);
    expect(
      playedHoleName(lookupAppLocalizations(const Locale('en')), playedHole),
      'Free hole',
    );
    expect(
      playedHoleName(lookupAppLocalizations(const Locale('fr')), playedHole),
      'Trou libre',
    );
  });

  test('a labelled free hole shows its label in any language', () {
    final playedHole = PlayedHole.fromJson(row(label: 'Test escalier'));

    expect(
      playedHoleName(lookupAppLocalizations(const Locale('fr')), playedHole),
      'Test escalier',
    );
  });
}
