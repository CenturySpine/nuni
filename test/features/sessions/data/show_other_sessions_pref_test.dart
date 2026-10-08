import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/sessions/data/show_other_sessions_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ShowOtherSessionsPref (plan 38, Q278)', () {
    test('shows every session by default', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        await container.read(showOtherSessionsPrefProvider.future),
        isTrue,
      );
    });

    test('remembers the choice on the device', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(
        showOtherSessionsPrefProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      await container.read(showOtherSessionsPrefProvider.future);

      await container.read(showOtherSessionsPrefProvider.notifier).set(false);
      expect(container.read(showOtherSessionsPrefProvider).value, isFalse);

      // A later start of the app reads it back.
      final restarted = ProviderContainer();
      addTearDown(restarted.dispose);
      expect(
        await restarted.read(showOtherSessionsPrefProvider.future),
        isFalse,
      );
    });
  });
}
