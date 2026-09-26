import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/photo_bytes.dart';

/// Keeps a photo's thumbnail (plan 30, Q201) in step with the photo: same
/// bucket, same folder -- so the same storage policies -- at the derived
/// [thumbnailPath]. Thumbnail operations are best effort: a missing
/// thumbnail only means the lists fall back to the full photo.
extension PhotoStorage on StorageFileApi {
  /// Uploads the thumbnail of [photo], already uploaded at [path].
  Future<void> uploadThumbnail(String path, Uint8List photo) async {
    final thumbnail = makeThumbnail(photo);
    if (thumbnail == null) return;
    try {
      await uploadBinary(
        thumbnailPath(path),
        thumbnail,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );
    } on StorageException catch (error) {
      debugPrint('Photo thumbnail not uploaded: ${error.message}');
    }
  }

  /// Removes the photos at [paths] and their thumbnails in one call.
  Future<void> removePhotos(Iterable<String> paths) => remove([
    for (final path in paths) ...[path, thumbnailPath(path)],
  ]);

  /// Copies the thumbnail of the photo at [from] next to the photo copied
  /// at [to].
  Future<void> copyThumbnail(String from, String to) async {
    try {
      await copy(thumbnailPath(from), thumbnailPath(to));
    } on StorageException catch (error) {
      debugPrint('Photo thumbnail not copied: ${error.message}');
    }
  }
}
