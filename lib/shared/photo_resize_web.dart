import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Decodes [bytes] with the browser (EXIF orientation applied), draws them
/// at [targetSize] on a canvas and encodes the result as JPEG. Null when the
/// browser can't read the image (e.g. HEIC outside Safari).
Future<Uint8List?> encodeJpegNatively(
  Uint8List bytes,
  (int, int) Function(int width, int height) targetSize, {
  required int quality,
}) async {
  try {
    final bitmap = await web.window
        .createImageBitmap(web.Blob([bytes.toJS].toJS))
        .toDart;
    try {
      final (width, height) = targetSize(bitmap.width, bitmap.height);
      final canvas = web.HTMLCanvasElement()
        ..width = width
        ..height = height;
      canvas.context2D
        ..imageSmoothingEnabled = true
        ..imageSmoothingQuality = 'high'
        ..drawImage(bitmap, 0, 0, width, height);
      final encoded = Completer<web.Blob?>();
      canvas.toBlob(
        ((web.Blob? blob) => encoded.complete(blob)).toJS,
        'image/jpeg',
        (quality / 100).toJS,
      );
      final blob = await encoded.future;
      if (blob == null) return null;
      return (await blob.arrayBuffer().toDart).toDart.asUint8List();
    } finally {
      bitmap.close();
    }
  } on Object {
    return null;
  }
}
