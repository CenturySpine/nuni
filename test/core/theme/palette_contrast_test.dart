import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/core/theme/contrast.dart';
import 'package:nuni/core/theme/palettes.dart';

/// Every text/background pairing the theme actually draws must reach WCAG AA
/// (4.5:1) -- docs/design/PALETTE.md. Exception: the brand fills (white
/// labels on the brand colour and gradient, brand-coloured links and tabs)
/// carry bold/large text only and are held to AA large text (3:1), which a
/// true orange can reach but not exceed by much (PO, 2026-09-23).
const _brandPairs = {
  'white on primary',
  'white on hero start',
  'white on hero end',
  'primary on background',
};

void main() {
  for (final palette in allPalettes) {
    final pairs = {
      'text on background': (palette.text, palette.background),
      'text on surface': (palette.text, palette.surface),
      'secondary text on background': (
        palette.textSecondary,
        palette.background,
      ),
      'secondary text on muted surface': (
        palette.textSecondary,
        palette.surfaceMuted,
      ),
      // Neutral pills and tiles: secondary text on the border tint.
      'secondary text on border tint': (palette.textSecondary, palette.border),
      'white on primary': (palette.onPrimary, palette.primary),
      'white on hero start': (palette.onPrimary, palette.heroStart),
      'white on hero end': (palette.onPrimary, palette.heroEnd),
      'primary on background': (palette.primary, palette.background),
      'danger on surface': (palette.danger, palette.surface),
      'danger on background': (palette.danger, palette.background),
      for (final (name, tone) in [
        ('primary', palette.primaryTone),
        ('fairway', palette.fairway),
        ('highlight', palette.highlight),
        ('sunshine', palette.sunshine),
        ('danger', palette.dangerTone),
      ])
        '$name tone text on its tint': (tone.onContainer, tone.container),
    };

    for (final MapEntry(key: name, value: (fg, bg)) in pairs.entries) {
      final minimum = _brandPairs.contains(name) ? 3.0 : 4.5;
      test('${palette.name}: $name is AA (>= $minimum:1)', () {
        expect(contrastRatio(fg, bg), greaterThanOrEqualTo(minimum));
      });
    }
  }
}
