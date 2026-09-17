import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/web/web_file_download.dart';
import '../../../core/web/web_share_support.dart';

/// Captures the widget under [repaintKey] (a `ResultsCard` wrapped in a
/// `RepaintBoundary`) as a PNG and hands it off (plan 10, Q16): the Web
/// Share API with the file attached where the browser supports it (mobile
/// Chrome/Safari), a plain download otherwise (desktop -- NUNI is a
/// web-only PWA, so "mobile" and "desktop" here both just mean "browser",
/// same distinction already made by `invite_sheet.dart`'s link share).
Future<Uint8List> captureAsPng(
  GlobalKey repaintKey, {
  double pixelRatio = 2,
}) async {
  final boundary =
      repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<void> shareOrDownloadPng(
  Uint8List bytes, {
  required String filename,
}) async {
  if (isWebShareSupported) {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: 'image/png', name: filename)],
        ),
      );
      if (result.status != ShareResultStatus.unavailable) return;
    } catch (_) {
      // Falls through to the download below.
    }
  }
  downloadBytes(bytes, filename: filename, mimeType: 'image/png');
}
