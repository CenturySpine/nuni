import 'package:flutter/material.dart';

import 'display_sized_image.dart';

/// A list-sized photo (plan 30): loads the photo's small thumbnail
/// ([thumbnailUrl]) and falls back to the full photo ([url]) while the
/// thumbnail doesn't exist yet (photo uploaded before plan 30 and not
/// backfilled). Both are decoded at display size. [placeholder] stands in
/// when neither loads.
class NuniPhotoThumbnail extends StatelessWidget {
  const NuniPhotoThumbnail({
    super.key,
    required this.thumbnailUrl,
    required this.url,
    required this.width,
    required this.height,
    this.placeholder,
  });

  final String thumbnailUrl;
  final String url;
  final double width;
  final double height;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    Image sized(String source, ImageErrorWidgetBuilder onError) => Image(
      image: displaySizedImage(
        context,
        NetworkImage(source),
        width: width,
        height: height,
      ),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: onError,
    );

    return sized(
      thumbnailUrl,
      (context, error, stackTrace) => sized(
        url,
        (context, error, stackTrace) =>
            placeholder ?? SizedBox(width: width, height: height),
      ),
    );
  }
}
