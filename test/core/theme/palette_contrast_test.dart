import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/core/theme/contrast.dart';
import 'package:nuni/core/theme/palettes.dart';

void main() {
  for (final palette in allPalettes) {
    test('${palette.name}: text/background contrast is AA (>= 4.5:1)', () {
      expect(
        contrastRatio(palette.text, palette.background),
        greaterThanOrEqualTo(4.5),
      );
    });

    // Accent/background contrast is NOT asserted here: 01-B and 02-B fall short (2.15:1 and
    // 2.51:1) because accent is used as a filled-button surface, not as text or a border directly
    // on the page background -- text-on-accent is what matters there, already checked by hand in
    // docs/design/PALETTE.md (6.0:1 and 6.2:1). Decision recorded in plan 04.
  }
}
