import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/sessions/domain/session_kind.dart';

void main() {
  test('Q5: fixed team size per kind', () {
    expect(SessionKind.individual.teamSize, 1);
    expect(SessionKind.team.teamSize, 2);
  });

  test('toPostgresValue matches the session_kind enum', () {
    expect(SessionKind.individual.toPostgresValue(), 'individual');
    expect(SessionKind.team.toPostgresValue(), 'team');
  });
}
