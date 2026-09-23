// Regenerates the PWA icons and favicon (web/icons/*.png, web/favicon.png)
// from the same drawing as the in-app logo (lib/shared/nuni_logo.dart), so
// the home-screen icon and the app's own logo never drift apart. Also
// renders the link-preview image (web/og-image.png, 1200x630, referenced by
// the og:image tag of web/index.html).
//
// Run with: fvm flutter test tool/generate_icons.dart
// (a `flutter test` entry point because it needs dart:ui to paint and encode
// PNGs; it lives in tool/, not test/, so the regular test run skips it).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/core/theme/logo_colors.dart';
import 'package:nuni/core/theme/palettes.dart';
import 'package:nuni/shared/nuni_logo.dart';

/// Full-bleed square (the platform applies its own mask), glyph at 64% of
/// the side -- inside the 80% safe zone maskable icons require.
Future<void> _render(String path, int size) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final side = size.toDouble();
  final rect = Rect.fromLTWH(0, 0, side, side);
  canvas.drawRect(
    rect,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [nuniLogoBackgroundStart, nuniLogoBackgroundEnd],
      ).createShader(rect),
  );
  final glyph = side * 0.64;
  canvas.save();
  canvas.translate((side - glyph) / 2, (side - glyph) / 2);
  NuniLogoGlyphPainter().paint(canvas, Size(glyph, glyph));
  canvas.restore();

  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

/// Link-preview card: brand gradient, logo glyph on the left, name, motto
/// and one line of French description, all in the default palette.
Future<void> _renderPreview(String path) async {
  const width = 1200.0;
  const height = 630.0;
  final ink = defaultPalette.onPrimary;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const rect = Rect.fromLTWH(0, 0, width, height);
  canvas.drawRect(
    rect,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [nuniLogoBackgroundStart, nuniLogoBackgroundEnd],
      ).createShader(rect),
  );
  // Same soft circles as the in-app hero (NuniHero).
  final soft = Paint()..color = ink.withValues(alpha: 0.08);
  canvas.drawCircle(const Offset(width * 0.92, height * 0.08), 260, soft);
  canvas.drawCircle(const Offset(width * 0.70, height * 1.02), 170, soft);

  const glyph = 360.0;
  canvas.save();
  canvas.translate(90, (height - glyph) / 2);
  NuniLogoGlyphPainter().paint(canvas, const Size(glyph, glyph));
  canvas.restore();

  void text(String value, double size, FontWeight weight, double top) {
    final builder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(fontFamily: 'PlusJakartaSans', maxLines: 2),
          )
          ..pushStyle(
            ui.TextStyle(
              color: ink,
              fontSize: size,
              fontWeight: weight,
              fontFamily: 'PlusJakartaSans',
              letterSpacing: size > 100 ? -3 : 0,
            ),
          )
          ..addText(value);
    final paragraph = builder.build()
      ..layout(const ui.ParagraphConstraints(width: 620));
    canvas.drawParagraph(paragraph, Offset(500, top));
  }

  text('NUNI', 150, FontWeight.w800, 150);
  text('Never Up, Never In', 46, FontWeight.w700, 330);
  text('Le scoring de street golf entre amis', 34, FontWeight.w500, 400);

  final image = await recorder.endRecording().toImage(
    width.toInt(),
    height.toInt(),
  );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

/// Tests render text with a placeholder font unless the real one is loaded.
Future<void> _loadBrandFont() async {
  final loader = FontLoader('PlusJakartaSans');
  for (final weight in ['Medium', 'Bold', 'ExtraBold']) {
    final bytes = File('assets/fonts/PlusJakartaSans-$weight.ttf')
        .readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

void main() {
  testWidgets('generate PWA icons', (tester) async {
    await tester.runAsync(() async {
      await _render('web/icons/Icon-192.png', 192);
      await _render('web/icons/Icon-512.png', 512);
      await _render('web/icons/Icon-maskable-192.png', 192);
      await _render('web/icons/Icon-maskable-512.png', 512);
      await _render('web/favicon.png', 64);
      await _loadBrandFont();
      await _renderPreview('web/og-image.png');
    });
  });
}
