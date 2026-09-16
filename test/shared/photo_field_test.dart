import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nuni/shared/photo_field.dart';

void main() {
  test('resizeForUpload shrinks a wide image down to the max width', () {
    final wide = img.Image(width: 2000, height: 1000);
    img.fill(wide, color: img.ColorRgb8(120, 180, 90));
    final original = img.encodeJpg(wide, quality: 100);

    final resized = resizeForUpload(original, maxWidth: 1600, quality: 80);
    final decoded = img.decodeImage(resized)!;

    expect(decoded.width, 1600);
    expect(decoded.height, 800);
    expect(resized.length, lessThan(original.length));
  });

  test('resizeForUpload does not upscale an already-small image', () {
    final small = img.Image(width: 100, height: 60);
    img.fill(small, color: img.ColorRgb8(10, 20, 30));
    final original = img.encodeJpg(small, quality: 90);

    final resized = resizeForUpload(original, maxWidth: 1600, quality: 80);
    final decoded = img.decodeImage(resized)!;

    expect(decoded.width, 100);
    expect(decoded.height, 60);
  });
}
