import 'package:flutter/material.dart';

import '../core/theme/google_brand_colors.dart';

/// The official Google "G" mark (Sign in with Google branding guidelines):
/// reproduced in shapes (same technique as [NuniLogo]) from Google's own
/// canonical `logo_googleg_48dp` asset, not a generic icon-font glyph --
/// the icon a "Continue with Google" button is required to use is this
/// exact, unmodified, four-colour mark.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter(), size: Size(size, size)),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 120, size.height / 120);

    canvas.drawPath(
      Path()
        ..moveTo(117.6, 61.3636364)
        ..cubicTo(
          117.6,
          57.1090909,
          117.218182,
          53.0181818,
          116.509091,
          49.0909091,
        )
        ..lineTo(60, 49.0909091)
        ..lineTo(60, 72.3)
        ..lineTo(92.2909091, 72.3)
        ..cubicTo(90.9, 79.8, 86.6727273, 86.1545455, 80.3181818, 90.4090909)
        ..lineTo(80.3181818, 105.463636)
        ..lineTo(99.7090909, 105.463636)
        ..cubicTo(111.054545, 95.0181818, 117.6, 79.6363636, 117.6, 61.3636364)
        ..close(),
      Paint()..color = googleBlue,
    );

    canvas.drawPath(
      Path()
        ..moveTo(60, 120)
        ..cubicTo(76.2, 120, 89.7818182, 114.627273, 99.7090909, 105.463636)
        ..lineTo(80.3181818, 90.4090909)
        ..cubicTo(
          74.9454545,
          94.0090909,
          68.0727273,
          96.1363636,
          60,
          96.1363636,
        )
        ..cubicTo(
          44.3727273,
          96.1363636,
          31.1454545,
          85.5818182,
          26.4272727,
          71.4,
        )
        ..lineTo(6.38181818, 71.4)
        ..lineTo(6.38181818, 86.9454545)
        ..cubicTo(16.2545455, 106.554545, 36.5454545, 120, 60, 120)
        ..close(),
      Paint()..color = googleGreen,
    );

    canvas.drawPath(
      Path()
        ..moveTo(26.4272727, 71.4)
        ..cubicTo(25.2272727, 67.8, 24.5454545, 63.9545455, 24.5454545, 60)
        ..cubicTo(24.5454545, 56.0454545, 25.2272727, 52.2, 26.4272727, 48.6)
        ..lineTo(26.4272727, 33.0545455)
        ..lineTo(6.38181818, 33.0545455)
        ..cubicTo(2.31818182, 41.1545455, 0, 50.3181818, 0, 60)
        ..cubicTo(0, 69.6818182, 2.31818182, 78.8454545, 6.38181818, 86.9454545)
        ..close(),
      Paint()..color = googleYellow,
    );

    canvas.drawPath(
      Path()
        ..moveTo(60, 23.8636364)
        ..cubicTo(
          68.8090909,
          23.8636364,
          76.7181818,
          26.8909091,
          82.9363636,
          32.8363636,
        )
        ..lineTo(100.145455, 15.6272727)
        ..cubicTo(89.7545455, 5.94545455, 76.1727273, 0, 60, 0)
        ..cubicTo(36.5454545, 0, 16.2545455, 13.4454545, 6.38181818, 33.0545455)
        ..lineTo(26.4272727, 48.6)
        ..cubicTo(
          31.1454545,
          34.4181818,
          44.3727273,
          23.8636364,
          60,
          23.8636364,
        )
        ..close(),
      Paint()..color = googleRed,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GoogleLogoPainter oldDelegate) => false;
}
