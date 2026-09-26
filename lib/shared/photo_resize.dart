/// Photo shrinking for upload (plan 06) and thumbnails (plan 30). On the
/// web, the browser's own image decoder and canvas do the work: fast, and
/// asynchronous, so the page stays responsive and progress indicators keep
/// spinning. The pure Dart `photo_bytes.dart` versions, which block the only
/// thread of a web page for seconds on a phone photo (PO, 2026-09-26), only
/// run outside the browser (tests) or when the browser can't read the image.
library;

import 'dart:typed_data';

import 'photo_bytes.dart';
import 'photo_resize_stub.dart'
    if (dart.library.js_interop) 'photo_resize_web.dart';

/// JPEG version of [bytes], capped at [maxWidth] wide (never upscaled);
/// [bytes] unchanged if they can't be read as an image.
Future<Uint8List> shrinkPhoto(
  Uint8List bytes, {
  int maxWidth = photoMaxWidth,
  int quality = 80,
}) async =>
    await encodeJpegNatively(
      bytes,
      (width, height) => photoSize(width, height, maxWidth),
      quality: quality,
    ) ??
    resizeForUpload(bytes, maxWidth: maxWidth, quality: quality);

/// JPEG thumbnail of [bytes] (shortest side [thumbnailShortSide]), or null
/// if [bytes] can't be read as an image.
Future<Uint8List?> photoThumbnail(Uint8List bytes, {int quality = 75}) async =>
    await encodeJpegNatively(
      bytes,
      (width, height) => thumbnailSize(width, height, thumbnailShortSide),
      quality: quality,
    ) ??
    makeThumbnail(bytes, quality: quality);
