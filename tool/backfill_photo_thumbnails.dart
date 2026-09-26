// Backfills photo thumbnails and shrinks oversized photos (plan 30, Q201,
// Q202). Run once from the repo root, after the plan 30 app is deployed:
//
//   fvm dart run tool/backfill_photo_thumbnails.dart [--env env/migration.json] [--dry-run]
//
// For every photo of the "holes" and "session-photos" buckets:
// - a photo wider than 1600 px (the ones imported from LsgScores, copied
//   as-is) is re-encoded 1600 px wide at the same path, in its own format;
// - a missing thumbnail is created next to it (`<path>.thumb.jpg`).
// Safe to re-run: a shrunk photo is never shrunk again and an existing
// thumbnail is never redone. --dry-run downloads and counts, writes nothing.
//
// Uses the NUNI service key (bypasses the storage policies) from an
// untracked JSON file (env/*.json is git-ignored) -- never commit it.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:nuni/shared/photo_bytes.dart';
import 'package:supabase/supabase.dart';

const _buckets = ['holes', 'session-photos'];
const _pageSize = 1000;

Future<void> main(List<String> args) async {
  final envIndex = args.indexOf('--env');
  final envPath = envIndex >= 0 && envIndex + 1 < args.length
      ? args[envIndex + 1]
      : 'env/migration.json';
  final dryRun = args.contains('--dry-run');

  final env = _readEnv(envPath);
  final client = SupabaseClient(
    env['NUNI_SUPABASE_URL']!,
    env['NUNI_SUPABASE_SERVICE_KEY']!,
  );
  try {
    for (final bucket in _buckets) {
      await _backfillBucket(client.storage.from(bucket), bucket, dryRun);
    }
  } finally {
    await client.dispose();
  }
  if (dryRun) stdout.writeln('Dry run: nothing written.');
}

Future<void> _backfillBucket(
  StorageFileApi bucket,
  String name,
  bool dryRun,
) async {
  final files = await _listFiles(bucket);
  final existing = files.toSet();
  final photos = [
    for (final path in files)
      if (!isThumbnailPath(path)) path,
  ];
  var shrunk = 0;
  var thumbnails = 0;
  var failed = 0;

  for (final path in photos) {
    try {
      var bytes = await bucket.download(path);
      final decoded = decodePhoto(bytes);
      if (decoded == null) {
        stderr.writeln('$name/$path: not an image, skipped');
        failed++;
        continue;
      }
      if (decoded.width > photoMaxWidth) {
        final smaller = _shrink(decoded, path);
        if (smaller == null) {
          stderr.writeln('$name/$path: format not re-encodable, kept as is');
        } else {
          if (!dryRun) {
            await bucket.uploadBinary(
              path,
              smaller.bytes,
              fileOptions: FileOptions(
                contentType: smaller.contentType,
                upsert: true,
              ),
            );
          }
          bytes = smaller.bytes;
          shrunk++;
        }
      }
      if (!existing.contains(thumbnailPath(path))) {
        final thumbnail = makeThumbnail(bytes);
        if (thumbnail != null && !dryRun) {
          await bucket.uploadBinary(
            thumbnailPath(path),
            thumbnail,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
        }
        thumbnails++;
      }
    } on StorageException catch (e) {
      stderr.writeln('$name/$path: ${e.message}');
      failed++;
    }
  }

  final verb = dryRun ? 'to ' : '';
  stdout.writeln(
    '$name: ${photos.length} photos, '
    '$shrunk ${verb}shrink to $photoMaxWidth px, '
    '$thumbnails thumbnails ${verb}create, $failed failed',
  );
}

/// Re-encodes [image] [photoMaxWidth] wide in the format of [path]'s
/// extension (the path, and so the stored content type, doesn't change).
({Uint8List bytes, String contentType})? _shrink(img.Image image, String path) {
  final resized = img.copyResize(image, width: photoMaxWidth);
  final extension = path.contains('.')
      ? path.substring(path.lastIndexOf('.') + 1).toLowerCase()
      : '';
  return switch (extension) {
    'jpg' || 'jpeg' => (
      bytes: Uint8List.fromList(img.encodeJpg(resized, quality: 80)),
      contentType: 'image/jpeg',
    ),
    'png' => (
      bytes: Uint8List.fromList(img.encodePng(resized)),
      contentType: 'image/png',
    ),
    _ => null,
  };
}

/// Every object path of [bucket], folders walked recursively.
Future<List<String>> _listFiles(
  StorageFileApi bucket, [
  String prefix = '',
]) async {
  final files = <String>[];
  for (var offset = 0; ; offset += _pageSize) {
    final page = await bucket.list(
      path: prefix,
      searchOptions: SearchOptions(limit: _pageSize, offset: offset),
    );
    for (final object in page) {
      final path = prefix.isEmpty ? object.name : '$prefix/${object.name}';
      if (object.id == null) {
        files.addAll(await _listFiles(bucket, path));
      } else if (!object.name.startsWith('.')) {
        files.add(path);
      }
    }
    if (page.length < _pageSize) return files;
  }
}

Map<String, String> _readEnv(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('Missing $path (see env/migration.example.json).');
    exit(66);
  }
  final json = (jsonDecode(file.readAsStringSync()) as Map)
      .cast<String, Object?>();
  const keys = ['NUNI_SUPABASE_URL', 'NUNI_SUPABASE_SERVICE_KEY'];
  final missing = [
    for (final key in keys)
      if ((json[key] as String?)?.isNotEmpty != true) key,
  ];
  if (missing.isNotEmpty) {
    stderr.writeln('Missing keys in $path: ${missing.join(', ')}');
    exit(78);
  }
  return {for (final key in keys) key: json[key]! as String};
}
