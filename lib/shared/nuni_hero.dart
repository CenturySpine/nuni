import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// The brand surface: the violet gradient with two soft circles and a
/// dotted putt rolling straight to the foot of a street lamp -- a typical
/// street golf target (PO, 2026-09-23). Used for the login hero and the home
/// banner -- never for regular content cards.
class NuniHero extends StatelessWidget {
  const NuniHero({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(NuniRadius.card),
    ),
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final nuni = context.nuni;
    final onHero = Theme.of(context).colorScheme.onPrimary;
    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: nuni.heroGradient),
        child: CustomPaint(
          painter: _HeroDecorationPainter(
            circle: onHero.withValues(alpha: 0.10),
            dots: nuni.sunshine.base.withValues(alpha: 0.9),
            ball: onHero,
            lamp: onHero.withValues(alpha: 0.95),
            light: nuni.sunshine.base,
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _HeroDecorationPainter extends CustomPainter {
  const _HeroDecorationPainter({
    required this.circle,
    required this.dots,
    required this.ball,
    required this.lamp,
    required this.light,
  });

  final Color circle;
  final Color dots;
  final Color ball;
  final Color lamp;
  final Color light;

  @override
  void paint(Canvas canvas, Size size) {
    final soft = Paint()..color = circle;
    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 0.08),
      size.shortestSide * 0.42,
      soft,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 1.02),
      size.shortestSide * 0.28,
      soft,
    );

    // The lamp, fixed size, in the top-right corner (away from text and
    // buttons whatever the hero's height).
    final poleX = size.width - 34;
    const top = 12.0;
    const ground = 54.0;

    // Straight putt along the ground, ball first, to the foot of the lamp.
    final startX = size.width * 0.50;
    final endX = poleX - 12;
    const steps = 7;
    final dot = Paint()..color = dots;
    for (var i = 1; i <= steps; i++) {
      final x = startX + (endX - startX) * i / (steps + 1);
      canvas.drawCircle(Offset(x, ground - 2), 2.2, dot);
    }
    canvas.drawCircle(Offset(startX, ground - 2), 4.5, Paint()..color = ball);

    final stroke = Paint()
      ..color = lamp
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Pole with a small base, then an arm bending over towards the ball.
    canvas.drawLine(Offset(poleX, ground - 3), Offset(poleX, top + 8), stroke);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(poleX - 5, ground - 4, 10, 4),
        const Radius.circular(2),
      ),
      Paint()..color = lamp,
    );
    final headX = poleX - 16;
    canvas.drawPath(
      Path()
        ..moveTo(poleX, top + 8)
        ..quadraticBezierTo(poleX, top, poleX - 8, top)
        ..lineTo(headX, top),
      stroke,
    );

    // Light cone and bulb glow under the head.
    canvas.drawPath(
      Path()
        ..moveTo(headX - 3, top + 5)
        ..lineTo(headX + 3, top + 5)
        ..lineTo(headX + 11, ground - 6)
        ..lineTo(headX - 11, ground - 6)
        ..close(),
      Paint()..color = light.withValues(alpha: 0.18),
    );
    canvas.drawCircle(Offset(headX, top + 6), 3.2, Paint()..color = light);

    // Lamp head: a small dome hanging from the arm.
    canvas.drawPath(
      Path()
        ..moveTo(headX - 7, top + 5)
        ..quadraticBezierTo(headX - 6, top - 1, headX, top - 1)
        ..quadraticBezierTo(headX + 6, top - 1, headX + 7, top + 5)
        ..close(),
      Paint()..color = lamp,
    );
  }

  @override
  bool shouldRepaint(covariant _HeroDecorationPainter oldDelegate) =>
      oldDelegate.circle != circle ||
      oldDelegate.dots != dots ||
      oldDelegate.ball != ball ||
      oldDelegate.lamp != lamp ||
      oldDelegate.light != light;
}
