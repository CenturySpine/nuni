import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/core/theme/palette_controller.dart';
import 'package:nuni/core/theme/palettes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('palette ids are unique and resolve back to their palette', () {
    final ids = allPalettes.map((p) => p.id).toSet();
    expect(ids, hasLength(allPalettes.length));
    for (final palette in allPalettes) {
      expect(paletteById(palette.id), same(palette));
    }
    expect(paletteById('unknown'), isNull);
    expect(paletteById(null), isNull);
  });

  test('defaults to the default palette, then persists the choice', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(paletteControllerProvider), same(defaultPalette));

    await container
        .read(paletteControllerProvider.notifier)
        .setPalette(nuniPop);
    expect(container.read(paletteControllerProvider), same(nuniPop));
    expect(await loadPersistedPalette(), same(nuniPop));
  });

  test('a saved choice is restored at start-up', () {
    final container = ProviderContainer(
      overrides: [persistedPaletteProvider.overrideWithValue(nuniPop)],
    );
    addTearDown(container.dispose);

    expect(container.read(paletteControllerProvider), same(nuniPop));
  });
}
