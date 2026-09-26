import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Wraps [image] so it is decoded no larger than needed to paint a
/// [width] x [height] logical box with [fit], instead of at full resolution.
///
/// Without this, a 48 px thumbnail of a 1600 px photo keeps ~7.7 MB of
/// decoded pixels in memory; a scrolled list of them made iOS Safari kill
/// the tab ("A problem repeatedly occurred", hole list, 2026-09-26).
///
/// The aspect ratio is kept ([ResizeImagePolicy.fit], never upscaled). For
/// [BoxFit.cover] the bounding box is doubled so the short side still
/// covers the box for any photo up to 2:1 (every camera format).
ImageProvider<Object> displaySizedImage(
  BuildContext context,
  ImageProvider<Object> image, {
  required double width,
  required double height,
  BoxFit fit = BoxFit.cover,
}) {
  final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
  final int boxWidth;
  final int boxHeight;
  if (fit == BoxFit.cover) {
    final side = (2 * math.max(width, height) * ratio).ceil();
    boxWidth = side;
    boxHeight = side;
  } else {
    boxWidth = (width * ratio).ceil();
    boxHeight = (height * ratio).ceil();
  }
  return ResizeImage(
    image,
    width: boxWidth,
    height: boxHeight,
    policy: ResizeImagePolicy.fit,
  );
}
