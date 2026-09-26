import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/shared/display_sized_image.dart';

void main() {
  Future<ResizeImage> resolve(
    WidgetTester tester, {
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    double ratio = 3,
  }) async {
    late ImageProvider<Object> provider;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(devicePixelRatio: ratio),
        child: Builder(
          builder: (context) {
            provider = displaySizedImage(
              context,
              const NetworkImage('https://example.org/photo.jpg'),
              width: width,
              height: height,
              fit: fit,
            );
            return const SizedBox();
          },
        ),
      ),
    );
    return provider as ResizeImage;
  }

  testWidgets('cover decodes within a doubled square, keeping the ratio', (
    tester,
  ) async {
    final image = await resolve(tester, width: 48, height: 48);
    expect(image.width, 288);
    expect(image.height, 288);
    expect(image.policy, ResizeImagePolicy.fit);
    expect(image.allowUpscaling, isFalse);
  });

  testWidgets('contain decodes at the box size in device pixels', (
    tester,
  ) async {
    final image = await resolve(
      tester,
      width: 400,
      height: 800,
      fit: BoxFit.contain,
      ratio: 2,
    );
    expect(image.width, 800);
    expect(image.height, 1600);
  });
}
