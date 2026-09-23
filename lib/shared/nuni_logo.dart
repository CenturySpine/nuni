import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/logo_colors.dart';

/// The NUNI logo: "NU" over "NI", same construction as `web/icons/nuni_logo.svg`
/// (block letters built from shapes, no font, so it renders identically and
/// scales losslessly). The tile and "NI" follow the palette the user picked
/// (Q76; Q23 had them fixed when the app had a single palette).
///
/// Always shown on its icon tile (brand gradient, rounded corners) so it
/// reads the same wherever it appears in the app as it does as the PWA icon
/// on the home screen -- never the bare glyph on the page background.
class NuniLogo extends StatelessWidget {
  const NuniLogo({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    // Proportions match the padding baked into web/icons/Icon-192.png.
    final glyphSize = size * 0.64;
    final nuni = context.nuni;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: nuni.heroGradient,
        borderRadius: BorderRadius.circular(size * 0.26),
      ),
      child: CustomPaint(
        painter: NuniLogoGlyphPainter(ni: nuni.palette.logoNi),
        size: Size(glyphSize, glyphSize),
      ),
    );
  }
}

/// The bare "NU/NI" glyph, without its tile. Public so that
/// `tool/generate_icons.dart` renders the PWA icons from this exact drawing.
class NuniLogoGlyphPainter extends CustomPainter {
  NuniLogoGlyphPainter({Color? ni}) : ni = ni ?? nuniLogoNi;

  /// Colour of the "NI" row.
  final Color ni;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);

    final nu = Paint()..color = nuniLogoNu;
    final niPaint = Paint()..color = ni;

    // "NU", top row.
    canvas.drawRect(const Rect.fromLTWH(24, 16, 7, 30), nu);
    canvas.drawPath(_diagonal(top: 16, bottom: 46), nu);
    canvas.drawRect(const Rect.fromLTWH(39, 16, 7, 30), nu);
    canvas.drawPath(_letterU(top: 16, bottom: 35), nu);

    // "NI", bottom row.
    canvas.drawRect(const Rect.fromLTWH(24, 54, 7, 30), niPaint);
    canvas.drawPath(_diagonal(top: 54, bottom: 84), niPaint);
    canvas.drawRect(const Rect.fromLTWH(39, 54, 7, 30), niPaint);
    canvas.drawRect(const Rect.fromLTWH(61.5, 54, 7, 30), niPaint);

    canvas.restore();
  }

  /// The "N" diagonal stroke: polygon(24,top 31.83,top 46,bottom 38.17,bottom).
  Path _diagonal({required double top, required double bottom}) {
    return Path()
      ..moveTo(24, top)
      ..lineTo(31.83, top)
      ..lineTo(46, bottom)
      ..lineTo(38.17, bottom)
      ..close();
  }

  /// The "U" glyph: two 7px-wide strokes (outer edges x=54/x=76, inner edges
  /// x=61/x=69) joined by an outer radius-11 arc and an inner radius-4 arc.
  Path _letterU({required double top, required double bottom}) {
    return Path()
      ..moveTo(54, top)
      ..lineTo(54, bottom)
      ..arcToPoint(
        Offset(76, bottom),
        radius: const Radius.circular(11),
        clockwise: false,
      )
      ..lineTo(76, top)
      ..lineTo(69, top)
      ..lineTo(69, bottom)
      ..arcToPoint(Offset(61, bottom), radius: const Radius.circular(4))
      ..lineTo(61, top)
      ..close();
  }

  @override
  bool shouldRepaint(covariant NuniLogoGlyphPainter oldDelegate) =>
      oldDelegate.ni != ni;
}
