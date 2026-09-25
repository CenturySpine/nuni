import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'association_choice_skip_pref.g.dart';

const _prefsKey = 'nuni.association_choice_skipped';

/// Whether the association choice was put off on this device (Q146): the
/// choice is offered at first sign-in, never forced. Remembered on the
/// device -- same pattern as `LibreRankingDirectionPref` -- so a new device
/// offers it once more. Leaving an association sets it too, so the choice
/// doesn't come straight back. Kept alive: `skip` may be called from a page
/// nothing else watches it from.
@Riverpod(keepAlive: true)
class AssociationChoiceSkipped extends _$AssociationChoiceSkipped {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }

  Future<void> skip() async {
    state = const AsyncData(true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }
}
