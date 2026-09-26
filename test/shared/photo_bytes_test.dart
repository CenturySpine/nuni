import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nuni/shared/photo_bytes.dart';

void main() {
  img.Image decode(List<int> bytes) =>
      img.decodeImage(Uint8List.fromList(bytes))!;

  Uint8List jpeg(int width, int height) {
    final image = img.Image(width: width, height: height);
    img.fill(image, color: img.ColorRgb8(120, 180, 90));
    return Uint8List.fromList(img.encodeJpg(image));
  }

  test('a landscape thumbnail is 256 px high, ratio kept', () {
    final thumbnail = decode(makeThumbnail(jpeg(1600, 1200))!);
    expect(thumbnail.height, 256);
    expect(thumbnail.width, 341);
  });

  test('a portrait thumbnail is 256 px wide, ratio kept', () {
    final thumbnail = decode(makeThumbnail(jpeg(1200, 1600))!);
    expect(thumbnail.width, 256);
    expect(thumbnail.height, 341);
  });

  test('a small photo is never upscaled', () {
    final thumbnail = decode(makeThumbnail(jpeg(200, 100))!);
    expect(thumbnail.width, 200);
    expect(thumbnail.height, 100);
  });

  test('bytes that are not an image give no thumbnail', () {
    expect(makeThumbnail(Uint8List.fromList([1, 2, 3])), isNull);
  });

  test('photo size is capped in width, ratio kept, never upscaled', () {
    expect(photoSize(4000, 3000, 1600), (1600, 1200));
    expect(photoSize(3000, 4000, 1600), (1600, 2133));
    expect(photoSize(800, 600, 1600), (800, 600));
  });

  test('thumbnail size caps the shortest side, never upscaled', () {
    expect(thumbnailSize(1600, 1200, 256), (341, 256));
    expect(thumbnailSize(1200, 1600, 256), (256, 341));
    expect(thumbnailSize(200, 100, 256), (200, 100));
  });

  test('the thumbnail path is derived from the photo path', () {
    const path = 'owner/hole/start.jpg';
    expect(thumbnailPath(path), 'owner/hole/start.jpg.thumb.jpg');
    expect(isThumbnailPath(thumbnailPath(path)), isTrue);
    expect(isThumbnailPath(path), isFalse);
  });
}
