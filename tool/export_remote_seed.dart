// Saves the remote NUNI project's real data as seeds replayed after a schema
// reconstruction (AGENTS.md point 8, docs/DEV.md; PO 2026-09-23, Q63/Q73).
// Run from the repo root, then review and commit the diff:
//
//   fvm dart run tool/export_remote_seed.dart             # export both seeds
//   fvm dart run tool/export_remote_seed.dart --decrypt   # data seed -> build/seed/
//
// 1. supabase/remote_seed.sql (plain, committed): the holes -- public in the
//    app, photos of places.
// 2. supabase/data_seed.sql.enc (encrypted, committed): players, sessions,
//    teams, members, played holes, scores, session photo rows and the
//    sign-up linking e-mails (Q64) -- names, e-mails and photo paths of real
//    people, so never committed in clear (the repo is public). Encrypted with
//    openssl (AES-256, PBKDF2 key derivation) and a passphrase kept by the PO
//    in their password manager and in env/seed.json (git-ignored).
//
// Reads with the NUNI service key (env/migration.json, NUNI_* keys only).
import 'dart:convert';
import 'dart:io';

import 'package:supabase/supabase.dart';

const _holesSeedPath = 'supabase/remote_seed.sql';
const _dataSeedPath = 'supabase/data_seed.sql.enc';
const _decryptedPath = 'build/seed/data_seed.sql';
const _pbkdf2Iterations = '600000';

/// LsgScores holes never kept in NUNI (mirrors `excludedLegacyHoleIds` in
/// migrate_lsgscores.dart).
const _excludedLegacyIds = {32};

Future<void> main(List<String> args) async {
  final passphrase = _readPassphrase();
  if (args.contains('--decrypt')) {
    await _decrypt(passphrase);
    return;
  }

  final envIndex = args.indexOf('--env');
  final envPath = envIndex >= 0 && envIndex + 1 < args.length
      ? args[envIndex + 1]
      : 'env/migration.json';
  final env = (jsonDecode(File(envPath).readAsStringSync()) as Map)
      .cast<String, Object?>();
  final nuni = SupabaseClient(
    env['NUNI_SUPABASE_URL']! as String,
    env['NUNI_SUPABASE_SERVICE_KEY']! as String,
  );
  try {
    final rows = await nuni
        .from('holes')
        .select(
          'id, owner_id, name, description, par, distance_m, start_lat, '
          'start_lng, end_lat, end_lng, path, photo_start_path, '
          'photo_end_path, visibility, legacy_id, created_at, updated_at',
        )
        .order('created_at', ascending: true);
    final kept = [
      for (final row in rows)
        if (!_excludedLegacyIds.contains(row['legacy_id'])) row,
    ];
    File(_holesSeedPath).writeAsStringSync(_render(kept));
    stdout.writeln('${kept.length} holes written to $_holesSeedPath.');

    final data = await _renderData(nuni);
    await _encrypt(data.sql, passphrase);
    stdout.writeln('${data.summary} written (encrypted) to $_dataSeedPath.');
  } finally {
    await nuni.dispose();
  }
}

String _readPassphrase() {
  final file = File('env/seed.json');
  if (!file.existsSync()) {
    stderr.writeln(
      'Missing env/seed.json (see env/seed.example.json): it holds the data '
      'seed passphrase, also kept in the PO\'s password manager.',
    );
    exit(66);
  }
  final passphrase =
      (jsonDecode(file.readAsStringSync()) as Map)['SEED_PASSPHRASE']
          as String?;
  if (passphrase == null || passphrase.length < 20) {
    stderr.writeln('SEED_PASSPHRASE missing or shorter than 20 characters.');
    exit(78);
  }
  return passphrase;
}

/// openssl from the PATH, else the copy shipped with Git for Windows.
String get _openssl {
  const gitCopy = r'C:\Program Files\Git\mingw64\bin\openssl.exe';
  return File(gitCopy).existsSync() ? gitCopy : 'openssl';
}

// The passphrase goes through an environment variable, never the command
// line (visible to other processes).
List<String> _opensslArgs(String inputPath, String outputPath, bool decrypt) =>
    [
      'enc',
      if (decrypt) '-d',
      '-aes-256-cbc',
      '-pbkdf2',
      '-iter',
      _pbkdf2Iterations,
      '-salt',
      '-in',
      inputPath,
      '-out',
      outputPath,
      '-pass',
      'env:NUNI_SEED_PASSPHRASE',
    ];

Future<void> _runOpenssl(List<String> args, String passphrase) async {
  final result = await Process.run(
    _openssl,
    args,
    environment: {'NUNI_SEED_PASSPHRASE': passphrase},
  );
  if (result.exitCode != 0) {
    stderr.writeln('openssl failed: ${result.stderr}');
    exit(1);
  }
}

Future<void> _encrypt(String sql, String passphrase) async {
  final plain = File(_decryptedPath)..createSync(recursive: true);
  plain.writeAsStringSync(sql);
  try {
    await _runOpenssl(
      _opensslArgs(_decryptedPath, _dataSeedPath, false),
      passphrase,
    );
  } finally {
    // The clear copy only ever lives under build/ (git-ignored), and not
    // even there once encrypted.
    plain.deleteSync();
  }
}

Future<void> _decrypt(String passphrase) async {
  File(_decryptedPath).parent.createSync(recursive: true);
  await _runOpenssl(
    _opensslArgs(_dataSeedPath, _decryptedPath, true),
    passphrase,
  );
  stdout.writeln(
    'Decrypted to $_decryptedPath (git-ignored). Replay it, then delete it.',
  );
}

String _render(List<Map<String, dynamic>> holes) {
  final buffer = StringBuffer()
    ..writeln(
      '-- Remote seed data: the holes of the real "nuni" project, replayed after a schema',
    )
    ..writeln(
      '-- reconstruction (AGENTS.md point 8, docs/DEV.md) so they come back without re-creating',
    )
    ..writeln(
      '-- anything -- their photos already sit in the "holes" storage bucket, which a',
    )
    ..writeln('-- reconstruction never touches (only the schema is rebuilt).')
    ..writeln('--')
    ..writeln(
      '-- GENERATED by tool/export_remote_seed.dart -- do not edit by hand, re-run the tool after',
    )
    ..writeln(
      '-- editing holes in the app. Since 2026-09-23 (Q63) it holds the holes imported from LsgScores',
    )
    ..writeln(
      '-- (legacy_id set, repositioned by the PO) and the ones created in the app since; legacy_id is',
    )
    ..writeln(
      '-- kept so the LsgScores session import (plan 13, step 2) finds them, and so replaying',
    )
    ..writeln(
      '-- tool/migrate_lsgscores.dart holes after this file inserts nothing.',
    )
    ..writeln('--')
    ..writeln(
      '-- Distinct from supabase/seed.sql (local-Docker-only fixtures). Owner is the PO\'s own',
    )
    ..writeln(
      '-- auth.users row, untouched by a reconstruction, so the ids stay valid across replays.',
    )
    ..writeln()
    ..writeln('insert into holes (')
    ..writeln(
      '  id, owner_id, name, description, par, distance_m, start, end_point, path,',
    )
    ..writeln(
      '  photo_start_path, photo_end_path, visibility, legacy_id, created_at, updated_at',
    )
    ..writeln(') values');
  for (var i = 0; i < holes.length; i++) {
    final h = holes[i];
    final values = [
      _text(h['id']),
      _text(h['owner_id']),
      _text(h['name']),
      _text(h['description']),
      '${h['par']}',
      _number(h['distance_m']),
      _point(h['start_lat'], h['start_lng']),
      _point(h['end_lat'], h['end_lng']),
      h['path'] == null ? 'null' : '${_text(jsonEncode(h['path']))}::jsonb',
      _text(h['photo_start_path']),
      _text(h['photo_end_path']),
      _text(h['visibility']),
      _number(h['legacy_id']),
      _text(h['created_at']),
      _text(h['updated_at']),
    ];
    buffer
      ..writeln('  (')
      ..writeln(values.map((v) => '    $v').join(',\n'))
      ..writeln(i == holes.length - 1 ? '  )' : '  ),');
  }
  buffer.writeln('on conflict do nothing;');
  return buffer.toString();
}

String _text(Object? value) =>
    value == null ? 'null' : "'${value.toString().replaceAll("'", "''")}'";

String _number(Object? value) => value == null ? 'null' : '$value';

String _point(Object? lat, Object? lng) =>
    lat == null || lng == null ? 'null' : "'SRID=4326;POINT($lng $lat)'";

// ---------------------------------------------------------------------------
// Data seed (Q73): everything but the holes, in dependency order. Replayed
// BEFORE supabase/backfill_players.sql so every account gets its original
// player back (same id, edited name kept) instead of a fresh one.
// ---------------------------------------------------------------------------

/// A value written to SQL as-is (not quoted).
class _Raw {
  const _Raw(this.sql);
  final String sql;
}

Future<({String sql, String summary})> _renderData(SupabaseClient nuni) async {
  Future<List<Map<String, dynamic>>> all(
    String table,
    String columns,
    String orderBy,
  ) => nuni
      .from(table)
      .select(columns)
      .order(orderBy, ascending: true)
      .limit(100000);

  final players = await all(
    'players',
    'id, name, avatar_url, locale, created_by, user_id, legacy_id, created_at',
    'created_at',
  );
  final emails = await all(
    'legacy_player_emails',
    'player_id, email',
    'player_id',
  );
  final sessions = await all(
    'sessions',
    'id, code, owner_id, status, kind, scoring_mode, ranking_direction, city, '
        'zone, location_lat, location_lng, started_at, ended_at, weather, '
        'comment, cover_photo_id, is_championship, legacy_id, created_at',
    'created_at',
  );
  final teams = await all('teams', 'id, session_id, position, legacy_id', 'id');
  final teamPlayers = await all(
    'team_players',
    'team_id, player_id',
    'team_id',
  );
  final members = await all(
    'session_members',
    'session_id, user_id, team_id, role, joined_at',
    'joined_at',
  );
  final playedHoles = await all(
    'played_holes',
    'id, session_id, hole_id, label, game_mode, position, legacy_id, '
        'created_at',
    'created_at',
  );
  final scores = await all(
    'scores',
    'played_hole_id, team_id, value, updated_by, updated_at',
    'updated_at',
  );
  final photos = await all(
    'session_photos',
    'id, session_id, storage_path, uploaded_by, created_at',
    'created_at',
  );

  final sessionRows = [
    for (final s in sessions)
      {
        ...Map.of(s)
          ..remove('location_lat')
          ..remove('location_lng')
          // Set once the photos exist (foreign key), see the update below.
          ..remove('cover_photo_id'),
        'location': s['location_lat'] == null
            ? null
            : _Raw(
                "'SRID=4326;POINT(${s['location_lng']} ${s['location_lat']})'",
              ),
      },
  ];

  final buffer = StringBuffer()
    ..writeln('-- NUNI data seed, generated by tool/export_remote_seed.dart --')
    ..writeln(
      '-- do not edit. Contains personal data: committed ENCRYPTED only.',
    )
    ..writeln('-- Replay after supabase/remote_seed.sql (holes) and before')
    ..writeln('-- supabase/backfill_players.sql, see docs/DEV.md.')
    ..writeln(
      '-- Championship zones are not saved: the sessions trigger rebuilds',
    )
    ..writeln(
      '-- them, sessions being inserted in their original creation order.',
    )
    ..writeln('begin;');
  _insert(buffer, 'players', players);
  _insert(buffer, 'legacy_player_emails', emails);
  _insert(buffer, 'sessions', sessionRows);
  _insert(buffer, 'teams', teams);
  _insert(buffer, 'team_players', teamPlayers);
  _insert(buffer, 'session_members', members);
  _insert(buffer, 'played_holes', playedHoles);
  _insert(buffer, 'scores', scores);
  _insert(buffer, 'session_photos', photos);
  for (final s in sessions) {
    if (s['cover_photo_id'] == null) continue;
    buffer.writeln(
      'update sessions set cover_photo_id = ${_sql(s['cover_photo_id'])} '
      'where id = ${_sql(s['id'])} and cover_photo_id is null;',
    );
  }
  buffer.writeln('commit;');

  return (
    sql: buffer.toString(),
    summary:
        '${players.length} players, ${sessions.length} sessions, '
        '${teams.length} teams, ${playedHoles.length} played holes, '
        '${scores.length} scores, ${photos.length} session photos, '
        '${emails.length} pending e-mails',
  );
}

/// One statement per row: sessions must go in one by one anyway (the zone
/// trigger reads the rows inserted before), and it keeps the file readable
/// once decrypted.
void _insert(
  StringBuffer buffer,
  String table,
  List<Map<String, dynamic>> rows,
) {
  for (final row in rows) {
    buffer.writeln(
      'insert into $table (${row.keys.join(', ')}) values '
      '(${row.values.map(_sql).join(', ')}) on conflict do nothing;',
    );
  }
}

String _sql(Object? value) => switch (value) {
  null => 'null',
  _Raw(:final sql) => sql,
  num() || bool() => '$value',
  Map() || List() => '${_sql(jsonEncode(value))}::jsonb',
  _ => "'${value.toString().replaceAll("'", "''")}'",
};
