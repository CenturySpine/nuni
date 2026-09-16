import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/profile/domain/profile.dart';

void main() {
  test(
    'Profile.fromJson reads the snake_case columns from the profiles table',
    () {
      final profile = Profile.fromJson({
        'id': 'u1',
        'display_name': 'Ada Lovelace',
        'avatar_url': 'https://example.com/a.png',
        'locale': 'fr',
      });

      expect(profile.id, 'u1');
      expect(profile.displayName, 'Ada Lovelace');
      expect(profile.avatarUrl, 'https://example.com/a.png');
      expect(profile.locale, 'fr');
    },
  );
}
