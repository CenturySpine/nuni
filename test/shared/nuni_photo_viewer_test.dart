import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/shared/nuni_photo_thumbnail.dart';
import 'package:nuni/shared/nuni_photo_viewer.dart';

void main() {
  testWidgets('the viewer shows the original photo, not a resized one', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NuniPhotoViewer(urls: ['https://example.org/start.jpg']),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>());
    expect((image.image as NetworkImage).url, 'https://example.org/start.jpg');
  });

  testWidgets(
    'a thumbnail falls back to the full photo, then the placeholder',
    (tester) async {
      // In widget tests every network request fails, like a missing
      // thumbnail and then an unreachable photo.
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: NuniPhotoThumbnail(
              thumbnailUrl: 'https://example.org/start.jpg.thumb.jpg',
              url: 'https://example.org/start.jpg',
              width: 48,
              height: 48,
              placeholder: Text('placeholder'),
            ),
          ),
        ),
      );
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pump();
      }
      expect(find.text('placeholder'), findsOneWidget);
    },
  );
}
