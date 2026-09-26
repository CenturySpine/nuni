import 'dart:typed_data';

import 'package:image/image.dart' as img;

// Pure Dart (no Flutter import): also used by tool/backfill_photo_thumbnails.dart.

/// Largest width of an uploaded photo (plan 06); also the cap applied to
/// the photos imported from LsgScores (Q202).
const photoMaxWidth = 1600;

/// Shortest side of a photo thumbnail (plan 30, Q201): sharp enough for the
/// largest list tile (84 px) on a 3x screen.
const thumbnailShortSide = 256;

/// Decodes [bytes], or null when they aren't a readable image (the image
/// package throws on some malformed data instead of returning null).
img.Image? decodePhoto(Uint8List bytes) {
  try {
    return img.decodeImage(bytes);
  } on Object {
    return null;
  }
}

/// Re-encodes [bytes] as JPEG, capped at [maxWidth] wide (never upscaled),
/// to keep uploads small on mobile connections (plan 06). Returns the
/// original bytes unchanged if they can't be decoded as an image.
Uint8List resizeForUpload(
  Uint8List bytes, {
  int maxWidth = photoMaxWidth,
  int quality = 80,
}) {
  final decoded = decodePhoto(bytes);
  if (decoded == null) return bytes;
  final resized = decoded.width > maxWidth
      ? img.copyResize(decoded, width: maxWidth)
      : decoded;
  return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
}

/// A JPEG thumbnail of [bytes] whose shortest side is at most [shortSide]
/// (plan 30), or null if [bytes] can't be decoded as an image.
Uint8List? makeThumbnail(
  Uint8List bytes, {
  int shortSide = thumbnailShortSide,
  int quality = 75,
}) {
  final decoded = decodePhoto(bytes);
  if (decoded == null) return null;
  final small = decoded.width <= decoded.height
      ? (decoded.width > shortSide
            ? img.copyResize(decoded, width: shortSide)
            : decoded)
      : (decoded.height > shortSide
            ? img.copyResize(decoded, height: shortSide)
            : decoded);
  return Uint8List.fromList(img.encodeJpg(small, quality: quality));
}

/// Storage path of the thumbnail of the photo at [path], stored next to it
/// in the same bucket (plan 30): derived, never saved in the database.
String thumbnailPath(String path) => '$path.thumb.jpg';

bool isThumbnailPath(String path) => path.endsWith('.thumb.jpg');
