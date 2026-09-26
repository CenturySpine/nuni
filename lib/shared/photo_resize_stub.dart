import 'dart:typed_data';

/// No native image codec outside the browser: callers fall back to the pure
/// Dart version.
Future<Uint8List?> encodeJpegNatively(
  Uint8List bytes,
  (int, int) Function(int width, int height) targetSize, {
  required int quality,
}) async => null;
