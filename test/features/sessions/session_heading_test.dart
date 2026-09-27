import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/sessions/domain/session.dart';
import 'package:nuni/features/sessions/ui/session_nature.dart';

void main() {
  Session session({String? title, String? city, String? zone}) => Session(
    id: 's',
    code: 'ABC123',
    ownerId: 'u',
    status: SessionStatus.completed,
    title: title,
    city: city,
    zone: zone,
    createdAt: DateTime(2026),
  );

  test('without a name, the place is the title, as before (Q205)', () {
    final s = session(city: 'Lyon', zone: 'The People');
    expect(sessionHeading(s), 'Lyon · The People');
    expect(sessionSubheading(s), isNull);
  });

  test('a name takes the title, the place goes under it', () {
    final s = session(title: 'AG 2026', city: 'Lyon', zone: 'The People');
    expect(sessionHeading(s), 'AG 2026');
    expect(sessionSubheading(s), 'Lyon · The People');
  });

  test('neither name nor place: the code', () {
    expect(sessionHeading(session()), 'ABC123');
  });
}
