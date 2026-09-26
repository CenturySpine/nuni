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
  final (width, _) = photoSize(decoded.width, decoded.height, maxWidth);
  final resized = width < decoded.width
      ? img.copyResize(decoded, width: width)
      : decoded;
  return _encodeJpg(resized, quality);
}

/// 4:2:0 chroma, like browsers and cameras: the image package defaults to
/// 4:4:4, about twice the weight for no visible gain on a photo.
Uint8List _encodeJpg(img.Image image, int quality) => Uint8List.fromList(
  img.encodeJpg(image, quality: quality, chroma: img.JpegChroma.yuv420),
);

/// A JPEG thumbnail of [bytes] whose shortest side is at most [shortSide]
/// (plan 30), or null if [bytes] can't be decoded as an image.
Uint8List? makeThumbnail(
  Uint8List bytes, {
  int shortSide = thumbnailShortSide,
  int quality = 75,
}) {
  final decoded = decodePhoto(bytes);
  if (decoded == null) return null;
  final (width, height) = thumbnailSize(
    decoded.width,
    decoded.height,
    shortSide,
  );
  final small = width < decoded.width
      ? img.copyResize(decoded, width: width, height: height)
      : decoded;
  return _encodeJpg(small, quality);
}

/// Size of a [width] x [height] photo capped at [maxWidth] wide, ratio
/// kept, never upscaled.
(int, int) photoSize(int width, int height, int maxWidth) => width > maxWidth
    ? (maxWidth, (height * maxWidth / width).round())
    : (width, height);

/// Size of the thumbnail of a [width] x [height] photo: shortest side capped
/// at [shortSide], ratio kept, never upscaled.
(int, int) thumbnailSize(int width, int height, int shortSide) {
  if (width <= height) {
    return width > shortSide
        ? (shortSide, (height * shortSide / width).round())
        : (width, height);
  }
  return height > shortSide
      ? ((width * shortSide / height).round(), shortSide)
      : (width, height);
}

/// Storage path of the thumbnail of the photo at [path], stored next to it
/// in the same bucket (plan 30): derived, never saved in the database.
String thumbnailPath(String path) => '$path.thumb.jpg';

bool isThumbnailPath(String path) => path.endsWith('.thumb.jpg');
