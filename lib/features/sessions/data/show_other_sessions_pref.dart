import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'show_other_sessions_pref.g.dart';

const _prefsKey = 'nuni.show_other_sessions';

/// "Voir toutes les sessions" (plan 38, Q278): whether a super_admin's home
/// and history show their "Autres sessions" section -- one setting for both
/// pages, remembered on the device, like `LibreRankingDirectionPref`. On by
/// default.
@riverpod
class ShowOtherSessionsPref extends _$ShowOtherSessionsPref {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? true;
  }

  Future<void> set(bool show) async {
    state = AsyncData(show);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, show);
  }
}
