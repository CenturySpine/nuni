import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/profile/domain/player.dart';

void main() {
  test(
    'Player.fromJson reads the snake_case columns from the players table',
    () {
      final player = Player.fromJson({
        'id': 'p1',
        'name': 'Ada Lovelace',
        'avatar_url': 'https://example.com/a.png',
        'locale': 'fr',
        'user_id': 'u1',
      });

      expect(player.id, 'p1');
      expect(player.name, 'Ada Lovelace');
      expect(player.avatarUrl, 'https://example.com/a.png');
      expect(player.locale, 'fr');
      expect(player.userId, 'u1');
    },
  );

  test('Player.fromJson accepts a null user_id (imported, not linked)', () {
    final player = Player.fromJson({
      'id': 'p1',
      'name': 'Old Player',
      'locale': 'fr',
      'user_id': null,
    });

    expect(player.userId, isNull);
  });
}
