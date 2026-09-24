import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/player_stats.dart';

/// The strokes-against-par curve (plan 19, Q134): one dot per session at its average
/// difference to par, joined in chronological order, with a dashed line at
/// par. A plain drawing in the palette's colours -- no chart library, no
/// interaction. Lower is better, so the axis is not flipped: a curve going
/// down means progress, as golfers read a scorecard.
class SeasonChart extends StatelessWidget {
  const SeasonChart({
    super.key,
    required this.points,
    required this.formatToPar,
    required this.parLabel,
    this.height = 180,
  });

  final List<CurvePoint> points;
  final String Function(double) formatToPar;
  final String parLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: scheme.onSurfaceVariant);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SeasonChartPainter(
          points: points,
          lineColor: scheme.primary,
          dotRingColor: scheme.surfaceContainerLowest,
          parColor: context.nuni.border,
          labelStyle: labelStyle ?? const TextStyle(fontSize: 11),
          formatToPar: formatToPar,
          parLabel: parLabel,
          textDirection: Directionality.of(context),
        ),
      ),
    );
  }
}

class _SeasonChartPainter extends CustomPainter {
  _SeasonChartPainter({
    required this.points,
    required this.lineColor,
    required this.dotRingColor,
    required this.parColor,
    required this.labelStyle,
    required this.formatToPar,
    required this.parLabel,
    required this.textDirection,
  });

  final List<CurvePoint> points;
  final Color lineColor;
  final Color dotRingColor;
  final Color parColor;
  final TextStyle labelStyle;
  final String Function(double) formatToPar;
  final String parLabel;
  final TextDirection textDirection;

  static const _labelGap = 8.0;
  static const _dotRadius = 4.0;

  TextPainter _label(String text) => TextPainter(
    text: TextSpan(text: text, style: labelStyle),
    textDirection: textDirection,
  )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final values = points.map((p) => p.averageToPar).toList();
    // Always show par, and at least half a stroke of range around it.
    var minValue = math.min(0.0, values.reduce(math.min));
    var maxValue = math.max(0.0, values.reduce(math.max));
    if (maxValue - minValue < 1) {
      final middle = (maxValue + minValue) / 2;
      minValue = middle - 0.5;
      maxValue = middle + 0.5;
    }
    final padding = (maxValue - minValue) * 0.1;
    minValue -= padding;
    maxValue += padding;

    final topLabel = _label(formatToPar(maxValue - padding));
    final bottomLabel = _label(formatToPar(minValue + padding));
    final parText = _label(parLabel);
    final axisWidth = [
      topLabel.width,
      bottomLabel.width,
      parText.width,
    ].reduce(math.max);

    final left = axisWidth + _labelGap;
    final right = size.width - _dotRadius - 2;
    final top = _dotRadius + 2;
    final bottom = size.height - _dotRadius - 2;
    double yFor(double value) =>
        top + (maxValue - value) / (maxValue - minValue) * (bottom - top);
    double xFor(int index) => points.length == 1
        ? (left + right) / 2
        : left + index / (points.length - 1) * (right - left);

    // Par line, dashed, with its label.
    final parY = yFor(0);
    final parPaint = Paint()
      ..color = parColor
      ..strokeWidth = 1.5;
    const dash = 5.0;
    for (var x = left; x < right; x += dash * 2) {
      canvas.drawLine(
        Offset(x, parY),
        Offset(math.min(x + dash, right), parY),
        parPaint,
      );
    }
    parText.paint(canvas, Offset(0, parY - parText.height / 2));

    // Extreme values on the axis, unless they would overlap the par label.
    final topY = yFor(maxValue - padding);
    final bottomY = yFor(minValue + padding);
    if ((topY - parY).abs() > parText.height) {
      topLabel.paint(canvas, Offset(0, topY - topLabel.height / 2));
    }
    if ((bottomY - parY).abs() > parText.height) {
      bottomLabel.paint(canvas, Offset(0, bottomY - bottomLabel.height / 2));
    }

    final offsets = [
      for (var i = 0; i < points.length; i++)
        Offset(xFor(i), yFor(points[i].averageToPar)),
    ];
    if (offsets.length > 1) {
      final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
      for (final offset in offsets.skip(1)) {
        path.lineTo(offset.dx, offset.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = lineColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
    }
    final ringPaint = Paint()..color = dotRingColor;
    final dotPaint = Paint()..color = lineColor;
    for (final offset in offsets) {
      canvas
        ..drawCircle(offset, _dotRadius + 2, ringPaint)
        ..drawCircle(offset, _dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_SeasonChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.parColor != parColor ||
      oldDelegate.labelStyle != labelStyle;
}
