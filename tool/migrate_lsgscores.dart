// Imports LsgScores data into NUNI (plan 13). Run from the repo root:
//
//   fvm dart run tool/migrate_lsgscores.dart holes | sessions [--env env/migration.json] [--dry-run]
//
// Step 1 ("holes"): every legacy hole becomes a NUNI hole owned by the
// super_admin account (Q50), public (Q51), without a position (Q49), keyed by
// legacy_id. Idempotent: a hole whose legacy_id already exists is never
// touched again (Q55), and a photo already in NUNI's "holes" bucket is never
// re-uploaded (Q52) -- storage survives a schema reconstruction, so replaying
// after one re-inserts rows without re-downloading anything.
//
// Step 2 ("sessions", after step 1 and the remote seed): sessions, teams,
// players, played holes, scores and session photos -- see _migrateSessions.
//
// Both projects are accessed with their service key (bypasses RLS), read from
// an untracked JSON file (env/*.json is git-ignored) -- never commit it.
import 'dart:convert';
import 'dart:io';

import 'package:supabase/supabase.dart';
import 'package:uuid/uuid.dart';

const _pageSize = 1000;
const _holesReportPath = 'build/migration/holes_report.csv';
const _sessionsReportPath = 'build/migration/sessions_report.csv';

/// Legacy holes never imported: 32 "Generic" was LsgScores' one-off hole,
/// replaced by NUNI's free hole (plan 17) -- its plays become free holes in
/// the session import (Q62).
const excludedLegacyHoleIds = {32};

Future<void> main(List<String> args) async {
  const commands = {'holes', 'sessions'};
  if (args.isEmpty || !commands.contains(args.first)) {
    stderr.writeln(
      'Usage: dart run tool/migrate_lsgscores.dart holes|sessions '
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
    if (args.first == 'holes') {
      await _migrateHoles(legacy: legacy, nuni: nuni, dryRun: dryRun);
    } else {
      await _migrateSessions(legacy: legacy, nuni: nuni, dryRun: dryRun);
    }
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
    if (excludedLegacyHoleIds.contains(legacyId)) continue;
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

  _writeReport(_holesReportPath, report);
  stdout
    ..writeln(dryRun ? 'DRY RUN, nothing written to NUNI.' : 'Done.')
    ..writeln('Legacy holes: ${legacyHoles.length}')
    ..writeln('Already in NUNI: ${existing.length}')
    ..writeln('${dryRun ? 'To insert' : 'Inserted'}: ${toInsert.length}')
    ..writeln('Photos ${dryRun ? 'to copy' : 'copied'}: $photosCopied')
    ..writeln('Report: $_holesReportPath');
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
  String targetBucket = 'holes',
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
  return _copyObject(
    legacy: legacy,
    nuni: nuni,
    sourceBucket: source.bucket,
    sourceObject: source.object,
    targetBucket: targetBucket,
    targetPath: '$targetPath$extension',
    dryRun: dryRun,
  );
}

/// Copies one legacy storage object into a NUNI bucket, unless [targetPath]
/// already exists there (idempotent: storage survives reconstructions).
Future<_PhotoResult> _copyObject({
  required SupabaseClient legacy,
  required SupabaseClient nuni,
  required String sourceBucket,
  required String sourceObject,
  required String targetBucket,
  required String targetPath,
  required bool dryRun,
}) async {
  final bucket = nuni.storage.from(targetBucket);
  if (await bucket.exists(targetPath)) {
    return (path: targetPath, copied: false, status: 'already_present');
  }
  if (dryRun) return (path: targetPath, copied: true, status: 'would_copy');
  try {
    final bytes = await legacy.storage
        .from(sourceBucket)
        .download(sourceObject);
    final extension = targetPath.contains('.')
        ? targetPath.substring(targetPath.lastIndexOf('.'))
        : '.jpg';
    await bucket.uploadBinary(
      targetPath,
      bytes,
      fileOptions: FileOptions(contentType: _contentType(extension)),
    );
    return (path: targetPath, copied: true, status: 'copied');
  } on StorageException catch (e) {
    stderr.writeln('$sourceBucket/$sourceObject not copied: ${e.message}');
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

void _writeReport(String path, List<List<String>> rows) {
  final file = File(path)..createSync(recursive: true);
  String cell(String value) => '"${value.replaceAll('"', '""')}"';
  // Leading BOM so Excel reads accented names as UTF-8.
  file.writeAsStringSync(
    '﻿${rows.map((row) => row.map(cell).join(',')).join('\n')}\n',
  );
}

// ---------------------------------------------------------------------------
// Step 2: sessions (plan 13, Q62-Q70).
// ---------------------------------------------------------------------------

/// Namespaced, deterministic ids: the same LsgScores row always gets the same
/// NUNI id, so a reconstruction followed by a replay recreates identical rows
/// (session photos, stored under the session id, are found again) -- plan 13,
/// step 2, "Identifiants stables".
String _stableId(String kind, Object legacyKey) =>
    const Uuid().v5(Namespace.url.value, 'lsgscores:$kind:$legacyKey');

const _scoringModes = {
  1: (mode: 'stroke_play', direction: 'asc'),
  2: (mode: 'match_play', direction: 'desc'),
  3: (mode: 'redistribution', direction: 'desc'),
};
const _gameModes = {
  1: 'individual',
  2: 'scramble',
  3: 'greensome',
  4: 'best_ball',
};

/// OpenWeatherMap icon prefix -> closest WMO code (Q69), the format NUNI's
/// weather icon and label read.
const _owmIconToWmo = {
  '01': 0,
  '02': 1,
  '03': 2,
  '04': 3,
  '09': 80,
  '10': 61,
  '11': 95,
  '13': 71,
  '50': 45,
};

Future<void> _migrateSessions({
  required SupabaseClient legacy,
  required SupabaseClient nuni,
  required bool dryRun,
}) async {
  Future<List<Map<String, dynamic>>> legacyAll(
    String table,
    String columns, [
    String orderBy = 'id',
  ]) => _fetchAll(
    (from, to) => legacy
        .from(table)
        .select(columns)
        .order(orderBy, ascending: true)
        .range(from, to),
  );

  final sessions = await legacyAll(
    'sessions',
    'id, datetime, enddatetime, sessiontype, scoringmodeid, comment, '
        'isongoing, weatherdata, user_id, game_zones(name), cities(name)',
  );
  final teams = await legacyAll('teams', 'id, sessionid, player1id, player2id');
  final players = await legacyAll('players', 'id, name, photouri');
  final links = await legacyAll(
    'user_player_link',
    'user_id, player_id',
    'user_id',
  );
  final appUsers = await legacyAll('app_user', 'id, email');
  final playedHoles = await legacyAll(
    'played_holes',
    'id, sessionid, holeid, gamemodeid, position',
  );
  final legacyScores = await legacyAll(
    'played_hole_scores',
    'id, playedholeid, teamid, strokes',
  );

  // --- Who is who: legacy e-mails, NUNI accounts and their players (M3).
  final emailByLegacyUser = {
    for (final u in appUsers)
      if ((u['email'] as String?)?.isNotEmpty ?? false)
        u['id'] as String: (u['email'] as String).toLowerCase(),
  };
  final emailByLegacyPlayer = {
    for (final l in links)
      if (l['player_id'] != null && emailByLegacyUser[l['user_id']] != null)
        l['player_id'] as int: emailByLegacyUser[l['user_id']]!,
  };
  final accountIdByEmail = <String, String>{};
  for (var page = 1; ; page++) {
    final users = await nuni.auth.admin.listUsers(page: page, perPage: 1000);
    for (final user in users) {
      if (user.email != null) {
        accountIdByEmail[user.email!.toLowerCase()] = user.id;
      }
    }
    if (users.length < 1000) break;
  }
  final nuniPlayers = await _fetchAll(
    (from, to) => nuni
        .from('players')
        .select('id, user_id')
        .not('user_id', 'is', null)
        .order('id', ascending: true)
        .range(from, to),
  );
  final playerIdByAccount = {
    for (final p in nuniPlayers) p['user_id'] as String: p['id'] as String,
  };

  final holeRows = await _fetchAll(
    (from, to) => nuni
        .from('holes')
        .select('id, legacy_id, start_lat, start_lng')
        .not('legacy_id', 'is', null)
        .order('legacy_id', ascending: true)
        .range(from, to),
  );
  final holeByLegacyId = {for (final h in holeRows) h['legacy_id'] as int: h};

  // --- Prerequisite check (plan 13 step 2, point 1): every played hole but
  // "Generic" must exist in NUNI; unpositioned ones are listed.
  final missingHoles = <int>{};
  final unpositionedHoles = <int>{};
  for (final ph in playedHoles) {
    final legacyHoleId = ph['holeid'] as int;
    if (excludedLegacyHoleIds.contains(legacyHoleId)) continue;
    final hole = holeByLegacyId[legacyHoleId];
    if (hole == null) {
      missingHoles.add(legacyHoleId);
    } else if (hole['start_lat'] == null) {
      unpositionedHoles.add(legacyHoleId);
    }
  }
  if (unpositionedHoles.isNotEmpty) {
    stdout.writeln(
      'Warning: holes without a position (left out of session locations): '
      '${unpositionedHoles.join(', ')}',
    );
  }
  if (missingHoles.isNotEmpty) {
    stderr.writeln(
      'Legacy holes missing in NUNI: ${missingHoles.join(', ')} -- run '
      '"holes" (or replay supabase/remote_seed.sql) first.',
    );
    exit(1);
  }

  // --- Session owners (Q67): the NUNI account with the owner's e-mail.
  final ownerAccounts = <String, String>{};
  for (final s in sessions) {
    final email = emailByLegacyUser[s['user_id']];
    final account = email == null ? null : accountIdByEmail[email];
    if (account == null) {
      stderr.writeln(
        'Session ${s['id']}: its LsgScores owner has no NUNI account (M2).',
      );
      exit(1);
    }
    ownerAccounts[s['user_id'] as String] = account;
  }
  final anyOwner = ownerAccounts.values.first;

  // --- Players (Q64-Q66): only those who played; an existing NUNI account
  // (same e-mail) keeps its own player, the others get an imported one.
  final teamsBySession = <int, List<Map<String, dynamic>>>{};
  for (final t in teams) {
    (teamsBySession[t['sessionid'] as int] ??= []).add(t);
  }
  final playedLegacyPlayers = {
    for (final t in teams) ...[
      t['player1id'] as int,
      if (t['player2id'] != null) t['player2id'] as int,
    ],
  };
  final legacyPlayerById = {for (final p in players) p['id'] as int: p};
  final nuniPlayerIdByLegacy = <int, String>{};
  final accountIdByLegacyPlayer = <int, String>{};
  final playersToCreate = <Map<String, Object?>>[];
  final pendingEmails = <Map<String, Object?>>[];
  final playerReport = <String>[];

  for (final legacyPlayerId in playedLegacyPlayers.toList()..sort()) {
    final p = legacyPlayerById[legacyPlayerId]!;
    final name = (p['name'] as String).trim();
    final email = emailByLegacyPlayer[legacyPlayerId];
    final account = email == null ? null : accountIdByEmail[email];
    final accountPlayer = account == null ? null : playerIdByAccount[account];
    if (account != null && accountPlayer != null) {
      nuniPlayerIdByLegacy[legacyPlayerId] = accountPlayer;
      accountIdByLegacyPlayer[legacyPlayerId] = account;
      playerReport.add('$legacyPlayerId $name: existing NUNI account');
      continue;
    }
    final id = _stableId('player', legacyPlayerId);
    nuniPlayerIdByLegacy[legacyPlayerId] = id;
    final photo = await _copyPhoto(
      legacy: legacy,
      nuni: nuni,
      sourceUrl: p['photouri'] as String?,
      targetBucket: 'avatars',
      targetPath: 'legacy-players/$legacyPlayerId',
      dryRun: dryRun,
    );
    playersToCreate.add({
      'id': id,
      'name': name,
      'avatar_url': photo.path == null
          ? null
          : nuni.storage.from('avatars').getPublicUrl(photo.path!),
      'locale': 'fr',
      'created_by': anyOwner,
      'legacy_id': legacyPlayerId,
    });
    if (email != null) pendingEmails.add({'player_id': id, 'email': email});
    final linking = email == null
        ? 'no e-mail, never auto-linked'
        : 'linked at sign-up by e-mail';
    playerReport.add(
      '$legacyPlayerId $name: imported player ($linking), photo ${photo.status}',
    );
  }
  if (!dryRun) {
    await _insertIgnoring(nuni, 'players', playersToCreate, 'id');
    await _insertIgnoring(
      nuni,
      'legacy_player_emails',
      pendingEmails,
      'player_id',
    );
  }

  // --- Sessions and their children, each level idempotent.
  final report = <List<String>>[
    [
      'legacy_id',
      'started_at',
      'kind',
      'scoring',
      'teams',
      'played_holes',
      'scores',
      'photos',
      'location',
    ],
  ];
  final playedBySession = <int, List<Map<String, dynamic>>>{};
  for (final ph in playedHoles) {
    (playedBySession[ph['sessionid'] as int] ??= []).add(ph);
  }
  final scoresByPlayedHole = <int, List<Map<String, dynamic>>>{};
  for (final sc in legacyScores) {
    (scoresByPlayedHole[sc['playedholeid'] as int] ??= []).add(sc);
  }
  var photosCopied = 0;

  for (final s in sessions) {
    final legacyId = s['id'] as int;
    final sessionId = _stableId('session', legacyId);
    final owner = ownerAccounts[s['user_id']]!;
    final scoring = _scoringModes[s['scoringmodeid']]!;
    final startedAt = _parisToUtc(s['datetime'] as String);
    final endedAt = s['enddatetime'] == null
        ? null
        : _parisToUtc(s['enddatetime'] as String);
    final sessionTeams = [...?teamsBySession[legacyId]]
      ..sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
    final sessionPlayed = [...?playedBySession[legacyId]]
      ..sort((a, b) => (a['position'] as int).compareTo(b['position'] as int));

    // Location: centre of the session's distinct positioned holes (M1).
    final positioned = {
      for (final ph in sessionPlayed)
        if (holeByLegacyId[ph['holeid']]?['start_lat'] != null)
          ph['holeid'] as int,
    };
    String? location;
    if (positioned.isNotEmpty) {
      double mean(String column) =>
          positioned
              .map((id) => (holeByLegacyId[id]![column] as num).toDouble())
              .reduce((a, b) => a + b) /
          positioned.length;
      location = 'SRID=4326;POINT(${mean('start_lng')} ${mean('start_lat')})';
    }

    final comment = (s['comment'] as String?)?.trim();
    final sessionRow = <String, Object?>{
      'id': sessionId,
      'owner_id': owner,
      'status': 'completed',
      'kind': s['sessiontype'] == 'TEAM' ? 'team' : 'individual',
      'scoring_mode': scoring.mode,
      'ranking_direction': scoring.direction,
      'city': ((s['cities'] as Map?)?['name'] as String?)?.trim(),
      'zone': ((s['game_zones'] as Map?)?['name'] as String?)?.trim(),
      'location': location,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'weather': _convertWeather(s['weatherdata']),
      'comment': (comment?.isEmpty ?? true) ? null : comment,
      'legacy_id': legacyId,
    };

    final teamIdByLegacy = {
      for (final t in sessionTeams)
        t['id'] as int: _stableId('team', t['id'] as int),
    };
    final teamRows = <Map<String, Object?>>[];
    final teamPlayerRows = <Map<String, Object?>>[];
    final memberRows = <String, Map<String, Object?>>{};
    for (var i = 0; i < sessionTeams.length; i++) {
      final t = sessionTeams[i];
      final teamId = teamIdByLegacy[t['id']]!;
      teamRows.add({
        'id': teamId,
        'session_id': sessionId,
        'position': i + 1,
        'legacy_id': t['id'],
      });
      for (final legacyPlayerId in [t['player1id'], t['player2id']]) {
        if (legacyPlayerId == null) continue;
        teamPlayerRows.add({
          'team_id': teamId,
          'player_id': nuniPlayerIdByLegacy[legacyPlayerId]!,
        });
        final account = accountIdByLegacyPlayer[legacyPlayerId];
        if (account != null) {
          memberRows[account] = {
            'session_id': sessionId,
            'user_id': account,
            'team_id': teamId,
            'role': account == owner ? 'owner' : 'player',
          };
        }
      }
    }
    // The owner is always a member (Q67), with no team if they didn't play.
    memberRows.putIfAbsent(
      owner,
      () => {
        'session_id': sessionId,
        'user_id': owner,
        'team_id': null,
        'role': 'owner',
      },
    );

    final playedRows = <Map<String, Object?>>[];
    final scoreRows = <Map<String, Object?>>[];
    for (final ph in sessionPlayed) {
      final playedHoleId = _stableId('played_hole', ph['id'] as int);
      final legacyHoleId = ph['holeid'] as int;
      playedRows.add({
        'id': playedHoleId,
        'session_id': sessionId,
        // "Generic" becomes a free hole without a label (Q62).
        'hole_id': excludedLegacyHoleIds.contains(legacyHoleId)
            ? null
            : holeByLegacyId[legacyHoleId]!['id'],
        'game_mode': _gameModes[ph['gamemodeid']]!,
        'position': ph['position'],
        'legacy_id': ph['id'],
      });
      for (final sc in scoresByPlayedHole[ph['id']] ?? const []) {
        scoreRows.add({
          'played_hole_id': playedHoleId,
          'team_id': teamIdByLegacy[sc['teamid']]!,
          'value': sc['strokes'],
          'updated_by': owner,
          'updated_at': (endedAt ?? startedAt).toIso8601String(),
        });
      }
    }

    // Photos (Q70): <NUNI session id>/<original name>; "fav_" is the cover.
    final photoFiles = await legacy.storage
        .from('Sessions')
        .list(path: '$legacyId');
    final photoRows = <Map<String, Object?>>[];
    String? coverId;
    for (final file in photoFiles) {
      if (file.id == null) continue; // a sub-folder, not a file
      final copy = await _copyObject(
        legacy: legacy,
        nuni: nuni,
        sourceBucket: 'Sessions',
        sourceObject: '$legacyId/${file.name}',
        targetBucket: 'session-photos',
        targetPath: '$sessionId/${file.name}',
        dryRun: dryRun,
      );
      if (copy.path == null) continue;
      if (copy.copied) photosCopied++;
      final photoId = _stableId('session_photo', '$legacyId/${file.name}');
      photoRows.add({
        'id': photoId,
        'session_id': sessionId,
        'storage_path': copy.path,
        'uploaded_by': owner,
        'created_at': startedAt.toIso8601String(),
      });
      if (file.name.startsWith('fav_')) coverId = photoId;
    }

    if (!dryRun) {
      await _insertIgnoring(nuni, 'sessions', [sessionRow], 'id');
      await _insertIgnoring(nuni, 'teams', teamRows, 'id');
      await _insertIgnoring(
        nuni,
        'team_players',
        teamPlayerRows,
        'team_id,player_id',
      );
      await _insertIgnoring(
        nuni,
        'session_members',
        memberRows.values.toList(),
        'session_id,user_id',
      );
      await _insertIgnoring(nuni, 'played_holes', playedRows, 'id');
      await _insertIgnoring(
        nuni,
        'scores',
        scoreRows,
        'played_hole_id,team_id',
      );
      await _insertIgnoring(nuni, 'session_photos', photoRows, 'id');
      if (coverId != null) {
        // Only when none is set: a cover picked since in the app is kept.
        await nuni
            .from('sessions')
            .update({'cover_photo_id': coverId})
            .eq('id', sessionId)
            .isFilter('cover_photo_id', null);
      }
    }

    report.add([
      '$legacyId',
      startedAt.toIso8601String(),
      sessionRow['kind']! as String,
      scoring.mode,
      '${teamRows.length}',
      '${playedRows.length}',
      '${scoreRows.length}',
      '${photoRows.length}',
      location ?? 'none',
    ]);
  }

  _writeReport(_sessionsReportPath, report);
  stdout
    ..writeln(dryRun ? 'DRY RUN, nothing written to NUNI.' : 'Done.')
    ..writeln('Players:')
    ..writeAll(playerReport.map((line) => '  $line\n'))
    ..writeln(
      'Legacy: ${sessions.length} sessions, ${teams.length} teams, '
      '${playedHoles.length} played holes, ${legacyScores.length} scores',
    )
    ..writeln('Photos ${dryRun ? 'to copy' : 'copied'}: $photosCopied')
    ..writeln('Report: $_sessionsReportPath');

  if (!dryRun) {
    await _verifySessions(
      nuni: nuni,
      sessions: sessions,
      teams: teams,
      playedHoles: playedHoles,
      legacyScores: legacyScores,
    );
  }
}

/// Acceptance checks (plan 13 step 2): same counts on both sides, and the same
/// stroke total per team.
Future<void> _verifySessions({
  required SupabaseClient nuni,
  required List<Map<String, dynamic>> sessions,
  required List<Map<String, dynamic>> teams,
  required List<Map<String, dynamic>> playedHoles,
  required List<Map<String, dynamic>> legacyScores,
}) async {
  final sessionIds = [
    for (final s in sessions) _stableId('session', s['id'] as int),
  ];
  Future<List<Map<String, dynamic>>> rows(String table, String columns) =>
      nuni.from(table).select(columns).inFilter('session_id', sessionIds);

  final nuniSessions = await nuni
      .from('sessions')
      .select('id')
      .inFilter('id', sessionIds);
  final nuniTeams = await rows('teams', 'id');
  final nuniPlayed = await rows('played_holes', 'id');
  final nuniScores = await rows('scores', 'team_id, value');
  final nuniPhotos = await rows('session_photos', 'id');

  final legacyTotals = <String, int>{};
  for (final sc in legacyScores) {
    final team = _stableId('team', sc['teamid'] as int);
    legacyTotals[team] = (legacyTotals[team] ?? 0) + (sc['strokes'] as int);
  }
  final nuniTotals = <String, int>{};
  for (final sc in nuniScores) {
    final team = sc['team_id'] as String;
    nuniTotals[team] = (nuniTotals[team] ?? 0) + (sc['value'] as int);
  }
  final totalMismatches = [
    for (final team in {...legacyTotals.keys, ...nuniTotals.keys})
      if (legacyTotals[team] != nuniTotals[team]) team,
  ];

  String check(String label, int legacyCount, int nuniCount) =>
      '  $label: LsgScores $legacyCount, NUNI $nuniCount '
      '${legacyCount == nuniCount ? 'OK' : 'MISMATCH'}';
  final totals = totalMismatches.isEmpty
      ? 'OK'
      : 'MISMATCH for ${totalMismatches.join(', ')}';
  stdout
    ..writeln('Verification:')
    ..writeln(check('sessions', sessions.length, nuniSessions.length))
    ..writeln(check('teams', teams.length, nuniTeams.length))
    ..writeln(check('played holes', playedHoles.length, nuniPlayed.length))
    ..writeln(check('scores', legacyScores.length, nuniScores.length))
    ..writeln('  session photos in NUNI: ${nuniPhotos.length}')
    ..writeln('  stroke totals per team: $totals');
}

Future<void> _insertIgnoring(
  SupabaseClient nuni,
  String table,
  List<Map<String, Object?>> rows,
  String onConflict,
) async {
  if (rows.isEmpty) return;
  // Existing rows are left untouched, never overwritten (same rule as Q55).
  await nuni
      .from(table)
      .upsert(rows, onConflict: onConflict, ignoreDuplicates: true);
}

/// LsgScores stored the phone's wall-clock time without a time zone; every
/// session was played in Lyon, so it is read as Paris time (Q68): UTC+2 from
/// the last Sunday of March to the last Sunday of October (01:00 UTC), UTC+1
/// otherwise.
DateTime _parisToUtc(String wallClock) {
  final wall = DateTime.parse('${wallClock}Z');
  DateTime lastSunday(int year, int month) {
    final lastDay = DateTime.utc(year, month + 1, 0, 1);
    return lastDay.subtract(Duration(days: lastDay.weekday % 7));
  }

  final asWinter = wall.subtract(const Duration(hours: 1));
  final summer =
      !asWinter.isBefore(lastSunday(wall.year, 3)) &&
      asWinter.isBefore(lastSunday(wall.year, 10));
  return wall.subtract(Duration(hours: summer ? 2 : 1));
}

/// LsgScores stored OpenWeatherMap data as a JSON string; NUNI stores
/// Open-Meteo's shape (Q69).
Map<String, Object?>? _convertWeather(Object? raw) {
  if (raw == null) return null;
  final data = (raw is String ? jsonDecode(raw) : raw) as Map<String, dynamic>;
  final icon = (data['iconCode'] as String?) ?? '';
  final code = _owmIconToWmo[icon.length >= 2 ? icon.substring(0, 2) : icon];
  if (code == null || data['temperature'] == null) return null;
  return {
    'temperature_c': (data['temperature'] as num).toDouble(),
    'wind_kph': ((data['windSpeedKmh'] as num?) ?? 0).toDouble(),
    'code': code,
  };
}
