import 'package:flutter/material.dart';
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

  testWidgets('a filled slot can be emptied with its remove button', (
    tester,
  ) async {
    String? url = 'https://example.invalid/start.jpg';
    var removed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => PhotoField(
              label: 'Start',
              imageUrl: url,
              onPicked: (_) {},
              removeTooltip: 'Remove photo',
              onRemoved: () => setState(() {
                removed++;
                url = null;
              }),
            ),
          ),
        ),
      ),
    );
    // The fake URL never loads in tests; its load error is irrelevant here.
    tester.takeException();

    await tester.tap(find.byTooltip('Remove photo'));
    await tester.pump();

    expect(removed, 1);
    expect(find.byTooltip('Remove photo'), findsNothing);
  });

  testWidgets('an empty slot has no remove button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PhotoField(
            label: 'Start',
            onPicked: (_) {},
            removeTooltip: 'Remove photo',
            onRemoved: () {},
          ),
        ),
      ),
    );

    expect(find.byTooltip('Remove photo'), findsNothing);
  });
}
