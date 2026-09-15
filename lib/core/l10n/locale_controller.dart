import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_controller.g.dart';

const _prefsKey = 'nuni.locale';

/// The locale persisted on this device, loaded once before the app starts
/// (see `main.dart`) and injected here via provider override. `null` = no
/// override saved, follow the browser's locale.
final persistedLocaleProvider = Provider<Locale?>((ref) => null);

Future<Locale?> loadPersistedLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString(_prefsKey);
  return code == null ? null : Locale(code);
}

/// The language the app is currently displayed in. `null` means "follow the
/// browser", matching [MaterialApp.locale]'s own contract.
@riverpod
class LocaleController extends _$LocaleController {
  @override
  Locale? build() => ref.watch(persistedLocaleProvider);

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}
