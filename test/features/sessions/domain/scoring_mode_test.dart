import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/sessions/domain/ranking_direction.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';

void main() {
  test('Q34: ranking direction is deduced for every mode but Libre', () {
    expect(
      ScoringMode.strokePlay.impliedRankingDirection,
      RankingDirection.asc,
    );
    expect(
      ScoringMode.matchPlay.impliedRankingDirection,
      RankingDirection.desc,
    );
    expect(
      ScoringMode.redistribution.impliedRankingDirection,
      RankingDirection.desc,
    );
    expect(ScoringMode.free.impliedRankingDirection, isNull);
  });

  test('toPostgresValue matches the scoring_mode enum', () {
    expect(ScoringMode.strokePlay.toPostgresValue(), 'stroke_play');
    expect(ScoringMode.matchPlay.toPostgresValue(), 'match_play');
    expect(ScoringMode.redistribution.toPostgresValue(), 'redistribution');
    expect(ScoringMode.free.toPostgresValue(), 'free');
  });
}
