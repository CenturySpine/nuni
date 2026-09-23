import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'palettes.dart';

part 'palette_controller.g.dart';

const _prefsKey = 'nuni.palette';

/// The palette persisted on this device, loaded once before the app starts
/// (see `main.dart`) and injected here via provider override. `null` = no
/// choice saved, use [defaultPalette].
final persistedPaletteProvider = Provider<Palette?>((ref) => null);

Future<Palette?> loadPersistedPalette() async {
  final prefs = await SharedPreferences.getInstance();
  return paletteById(prefs.getString(_prefsKey));
}

/// The colour set the app is currently drawn with, chosen by the user in
/// the settings (PO, 2026-09-23, Q76). Per device, like the language.
@riverpod
class PaletteController extends _$PaletteController {
  @override
  Palette build() => ref.watch(persistedPaletteProvider) ?? defaultPalette;

  Future<void> setPalette(Palette palette) async {
    state = palette;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, palette.id);
  }
}
