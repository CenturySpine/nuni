// Imports LsgScores data into NUNI (plan 13). Run from the repo root:
//
//   fvm dart run tool/migrate_lsgscores.dart holes [--env env/migration.json] [--dry-run]
//
// Step 1 only ("holes"): every legacy hole becomes a NUNI hole owned by the
// super_admin account (Q50), public (Q51), without a position (Q49), keyed by
// legacy_id. Idempotent: a hole whose legacy_id already exists is never
// touched again (Q55), and a photo already in NUNI's "holes" bucket is never
// re-uploaded (Q52) -- storage survives a schema reconstruction, so replaying
// after one re-inserts rows without re-downloading anything.
//
// Both projects are accessed with their service key (bypasses RLS), read from
// an untracked JSON file (env/*.json is git-ignored) -- never commit it.
import 'dart:convert';
import 'dart:io';

import 'package:supabase/supabase.dart';

const _pageSize = 1000;
const _reportPath = 'build/migration/holes_report.csv';

Future<void> main(List<String> args) async {
  if (args.isEmpty || args.first != 'holes') {
    stderr.writeln(
      'Usage: dart run tool/migrate_lsgscores.dart holes '
      '[--env env/migration.json] [--dry-run]',
    );
    exit(64);
  }
  final envIndex = args.indexOf('--env');
  final envPath = envIndex >= 0 && envIndex + 1 < args.length
      ? args[envIndex + 1]
      : 'env/migration.json';
  final dryRun = args.contains('--dry-run');

  final env = _readEnv(envPath);
  final legacy = SupabaseClient(
    env['LEGACY_SUPABASE_URL']!,
    env['LEGACY_SUPABASE_SERVICE_KEY']!,
  );
  final nuni = SupabaseClient(
    env['NUNI_SUPABASE_URL']!,
    env['NUNI_SUPABASE_SERVICE_KEY']!,
  );
  try {
    await _migrateHoles(legacy: legacy, nuni: nuni, dryRun: dryRun);
  } finally {
    await legacy.dispose();
    await nuni.dispose();
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
  const keys = [
    'LEGACY_SUPABASE_URL',
    'LEGACY_SUPABASE_SERVICE_KEY',
    'NUNI_SUPABASE_URL',
    'NUNI_SUPABASE_SERVICE_KEY',
  ];
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

Future<void> _migrateHoles({
  required SupabaseClient legacy,
  required SupabaseClient nuni,
  required bool dryRun,
}) async {
  final ownerId = await _superAdminId(nuni);

  final legacyHoles = await _fetchAll(
    (from, to) => legacy
        .from('holes')
        .select(
          'id, name, description, distance, par, startphotouri, endphotouri, '
          'game_zones(name, cities(name))',
        )
        .order('id', ascending: true)
        .range(from, to),
  );
  final existingRows = await _fetchAll(
    (from, to) => nuni
        .from('holes')
        .select('legacy_id')
        .not('legacy_id', 'is', null)
        .order('legacy_id', ascending: true)
        .range(from, to),
  );
  final existing = {for (final row in existingRows) row['legacy_id'] as int};

  final report = <List<String>>[
    ['legacy_id', 'name', 'zone', 'city', 'status', 'start_photo', 'end_photo'],
  ];
  final toInsert = <Map<String, Object?>>[];
  var photosCopied = 0;

  for (final hole in legacyHoles) {
    final legacyId = hole['id'] as int;
    // Legacy names often carry a stray trailing space ("Radioactive ").
    final name = (hole['name'] as String).trim();
    final description = (hole['description'] as String?)?.trim();
    final zone = hole['game_zones'] as Map<String, dynamic>?;
    final zoneName = (zone?['name'] as String? ?? '').trim();
    final cityName =
        (zone?['cities'] as Map<String, dynamic>?)?['name'] as String? ?? '';

    if (existing.contains(legacyId)) {
      report.add([
        '$legacyId',
        name,
        zoneName,
        cityName,
        'already_present',
        '',
        '',
      ]);
      continue;
    }

    final start = await _copyPhoto(
      legacy: legacy,
      nuni: nuni,
      sourceUrl: hole['startphotouri'] as String?,
      targetPath: '$ownerId/legacy-$legacyId/start',
      dryRun: dryRun,
    );
    final end = await _copyPhoto(
      legacy: legacy,
      nuni: nuni,
      sourceUrl: hole['endphotouri'] as String?,
      targetPath: '$ownerId/legacy-$legacyId/end',
      dryRun: dryRun,
    );
    photosCopied += (start.copied ? 1 : 0) + (end.copied ? 1 : 0);

    toInsert.add({
      'legacy_id': legacyId,
      'owner_id': ownerId,
      'name': name,
      'description': (description?.isEmpty ?? true) ? null : description,
      'par': hole['par'],
      'distance_m': hole['distance'],
      'visibility': 'public',
      'photo_start_path': start.path,
      'photo_end_path': end.path,
    });
    report.add([
      '$legacyId',
      name,
      zoneName,
      cityName,
      dryRun ? 'would_insert' : 'inserted',
      start.status,
      end.status,
    ]);
  }

  if (!dryRun) {
    for (var i = 0; i < toInsert.length; i += _pageSize) {
      final batch = toInsert.sublist(
        i,
        i + _pageSize > toInsert.length ? toInsert.length : i + _pageSize,
      );
      // ignoreDuplicates: a row inserted concurrently since the read above is
      // left untouched rather than overwritten (Q55).
      await nuni
          .from('holes')
          .upsert(batch, onConflict: 'legacy_id', ignoreDuplicates: true);
    }
  }

  _writeReport(report);
  stdout
    ..writeln(dryRun ? 'DRY RUN, nothing written to NUNI.' : 'Done.')
    ..writeln('Legacy holes: ${legacyHoles.length}')
    ..writeln('Already in NUNI: ${existing.length}')
    ..writeln('${dryRun ? 'To insert' : 'Inserted'}: ${toInsert.length}')
    ..writeln('Photos ${dryRun ? 'to copy' : 'copied'}: $photosCopied')
    ..writeln('Report: $_reportPath');
}

/// Imported holes belong to the one super_admin account (Q50): replayed
/// after supabase/seed_super_admin.sql in docs/DEV.md's reconstruction order.
Future<String> _superAdminId(SupabaseClient nuni) async {
  final rows = await nuni
      .from('user_roles')
      .select('user_id')
      .eq('role', 'super_admin');
  if (rows.length != 1) {
    stderr.writeln(
      'Expected exactly one super_admin in NUNI, found ${rows.length} '
      '(run supabase/seed_super_admin.sql first).',
    );
    exit(1);
  }
  return rows.single['user_id'] as String;
}

Future<List<Map<String, dynamic>>> _fetchAll(
  Future<List<Map<String, dynamic>>> Function(int from, int to) page,
) async {
  final all = <Map<String, dynamic>>[];
  for (var from = 0; ; from += _pageSize) {
    final rows = await page(from, from + _pageSize - 1);
    all.addAll(rows);
    if (rows.length < _pageSize) return all;
  }
}

typedef _PhotoResult = ({String? path, bool copied, String status});

/// Copies one legacy photo into NUNI's "holes" bucket under the owner's own
/// folder (so the storage policies let the PO replace it from the app later),
/// at a path derived from the legacy id -- stable across reconstructions,
/// unlike the NUNI hole id.
Future<_PhotoResult> _copyPhoto({
  required SupabaseClient legacy,
  required SupabaseClient nuni,
  required String? sourceUrl,
  required String targetPath,
  required bool dryRun,
}) async {
  if (sourceUrl == null || sourceUrl.isEmpty) {
    return (path: null, copied: false, status: 'none');
  }
  final source = _parseStorageUrl(sourceUrl);
  if (source == null) {
    // e.g. a device-local content:// URI whose upload never happened.
    return (path: null, copied: false, status: 'unusable_uri');
  }
  final extension = source.object.contains('.')
      ? source.object.substring(source.object.lastIndexOf('.')).toLowerCase()
      : '.jpg';
  final path = '$targetPath$extension';
  final bucket = nuni.storage.from('holes');

  if (await bucket.exists(path)) {
    return (path: path, copied: false, status: 'already_present');
  }
  if (dryRun) return (path: path, copied: true, status: 'would_copy');
  try {
    final bytes = await legacy.storage
        .from(source.bucket)
        .download(source.object);
    await bucket.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: _contentType(extension)),
    );
    return (path: path, copied: true, status: 'copied');
  } on StorageException catch (e) {
    stderr.writeln('Photo $sourceUrl not copied: ${e.message}');
    return (path: null, copied: false, status: 'error: ${e.message}');
  }
}

/// `https://<ref>.supabase.co/storage/v1/object/{public|sign|authenticated}/<bucket>/<object>`
/// -> (bucket, object). Downloading through the service key rather than the
/// URL itself works whether the legacy bucket is public or private.
({String bucket, String object})? _parseStorageUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme || !uri.scheme.startsWith('http')) {
    return null;
  }
  final segments = uri.pathSegments;
  final objectIndex = segments.indexOf('object');
  if (objectIndex < 0) return null;
  var rest = segments.sublist(objectIndex + 1);
  if (rest.isNotEmpty &&
      const {'public', 'sign', 'authenticated'}.contains(rest.first)) {
    rest = rest.sublist(1);
  }
  if (rest.length < 2) return null;
  return (bucket: rest.first, object: rest.sublist(1).join('/'));
}

String _contentType(String extension) => switch (extension) {
  '.png' => 'image/png',
  '.webp' => 'image/webp',
  _ => 'image/jpeg',
};

void _writeReport(List<List<String>> rows) {
  final file = File(_reportPath)..createSync(recursive: true);
  String cell(String value) => '"${value.replaceAll('"', '""')}"';
  // Leading BOM so Excel reads accented names as UTF-8.
  file.writeAsStringSync(
    '﻿${rows.map((row) => row.map(cell).join(',')).join('\n')}\n',
  );
}
