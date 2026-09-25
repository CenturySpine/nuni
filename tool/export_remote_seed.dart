// Saves the remote NUNI project's real data as seeds replayed after a schema
// reconstruction (AGENTS.md point 8, docs/DEV.md; PO 2026-09-23, Q63/Q73).
// Run from the repo root, then review and commit the diff:
//
//   fvm dart run tool/export_remote_seed.dart             # export both seeds
//   fvm dart run tool/export_remote_seed.dart --decrypt   # data seed -> build/seed/
//
// 1. supabase/remote_seed.sql (plain, committed): the holes -- public in the
//    app, photos of places.
// 2. supabase/data_seed.sql.enc (encrypted, committed): associations (plan
//    18: requests, edits of the initial ones), their local managers and
//    their contact details, players, sessions, teams, members, played holes,
//    scores, session photo rows, the spots (plan 28), the planning (plan 23: events, answers,
//    comments) and the sign-up linking e-mails (Q64) --
//    names, e-mails, phones and photo paths of real people, so never
//    committed in clear (the repo is public). The initial associations
//    themselves are supabase/associations_seed.sql, replayed before. Encrypted with
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
    // Every column, not a fixed list (plan 26): the same run reads a base
    // still on the previous schema (with `visibility`, without
    // `cloned_from`) just before a reconstruction, and the new one after --
    // `_render` picks the columns it writes and ignores the others.
    final rows = await nuni
        .from('holes')
        .select()
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
      '  photo_start_path, photo_end_path, cloned_from, legacy_id, created_at, updated_at',
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
      // Absent before plan 26; rows are in creation order, so an original
      // is always inserted before its clones.
      _text(h['cloned_from']),
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

  // A table or column the base doesn't have yet (plan 23) reads as empty:
  // the same run reads a base still on the previous schema just before a
  // reconstruction, and the new one after.
  Future<List<Map<String, dynamic>>> optional(
    Future<List<Map<String, dynamic>>> Function() read,
  ) async {
    try {
      return await read();
    } on PostgrestException {
      return const [];
    }
  }

  // Every column (plan 27), same reason as the players below: `partners`
  // doesn't exist yet on a base still on the previous schema.
  final associations = await all('associations', '*', 'created_at');
  final managers = await all(
    'association_managers',
    'id, association_id, user_id, status, requested_at, reviewed_by, '
        'reviewed_at',
    'requested_at',
  );
  final contacts = await all(
    'association_manager_contacts',
    'manager_id, email, phone, request_message',
    'manager_id',
  );
  // Every column (plan 19), same reason as the played holes below:
  // `stats_public` and `badges_public` don't exist yet on a base still on the
  // previous schema, and a "private" choice must survive a reconstruction.
  final players = await all('players', '*', 'created_at');
  // Plan 27: the local admins, absent from a base still on the previous schema.
  final admins = await optional(
    () => all('association_admins', '*', 'created_at'),
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
        'comment, cover_photo_id, association_id, is_championship, legacy_id, '
        'created_at',
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
  // Every column (plan 26), same reason as the holes above: `par` and
  // `comment` don't exist yet on a base still on the previous schema. Replayed
  // without a par, a played hole gets its hole's par, or 3 for a free hole
  // (Q122), from the `played_holes_set_par` trigger.
  final playedHoles = await all('played_holes', '*', 'created_at');
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
  // Plan 28: the spots, before the events and sessions that point to them,
  // absent from a base still on the previous schema; each session's spot is
  // set once the session exists (the column is new too).
  final spots = await optional(() => all('spots', '*', 'created_at'));
  final sessionSpots = await optional(
    () => nuni
        .from('sessions')
        .select('id, spot_id')
        .not('spot_id', 'is', null)
        .limit(100000),
  );
  // Plan 23: the planning, and the event each session was started from.
  final events = await optional(() => all('events', '*', 'created_at'));
  final responses = await optional(
    () => all('event_responses', '*', 'updated_at'),
  );
  final comments = await optional(
    () => all('event_comments', '*', 'created_at'),
  );
  final sessionEvents = await optional(
    () => nuni
        .from('sessions')
        .select('id, event_id')
        .not('event_id', 'is', null)
        .limit(100000),
  );

  final eventRows = [
    for (final e in events)
      {
        ...Map.of(e)
          ..remove('location')
          ..remove('location_lat')
          ..remove('location_lng'),
        'location': e['location_lat'] == null
            ? null
            : _Raw(
                "'SRID=4326;POINT(${e['location_lng']} ${e['location_lat']})'",
              ),
      },
  ];

  final spotRows = [
    for (final s in spots)
      {
        ...Map.of(s)
          ..remove('location_lat')
          ..remove('location_lng'),
        'location': s['location_lat'] == null
            ? null
            : _Raw(
                "'SRID=4326;POINT(${s['location_lng']} ${s['location_lat']})'",
              ),
      },
  ];

  final associationRows = [
    for (final a in associations)
      {
        ...Map.of(a)
          ..remove('location_lat')
          ..remove('location_lng'),
        'location': _Raw(
          "'SRID=4326;POINT(${a['location_lng']} ${a['location_lat']})'",
        ),
      },
  ];

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
      '-- Associations already there (supabase/associations_seed.sql) are',
    )
    ..writeln('-- updated, to keep the edits made in the app.')
    ..writeln('begin;');
  _insert(buffer, 'associations', associationRows, upsertOn: 'id');
  _insert(buffer, 'association_managers', managers);
  _insert(buffer, 'association_manager_contacts', contacts);
  _insert(buffer, 'players', players);
  _insert(buffer, 'association_admins', admins);
  _insert(buffer, 'legacy_player_emails', emails);
  _insert(buffer, 'spots', spotRows);
  _insert(buffer, 'events', eventRows);
  _insert(buffer, 'event_responses', responses);
  _insert(buffer, 'event_comments', comments);
  _insert(buffer, 'sessions', sessionRows);
  _insert(buffer, 'teams', teams);
  _insert(buffer, 'team_players', teamPlayers);
  _insert(buffer, 'session_members', members);
  _insert(buffer, 'played_holes', playedHoles);
  _insert(buffer, 'scores', scores);
  _insert(buffer, 'session_photos', photos);
  for (final s in sessionEvents) {
    buffer.writeln(
      'update sessions set event_id = ${_sql(s['event_id'])} '
      'where id = ${_sql(s['id'])} and event_id is null;',
    );
  }
  for (final s in sessionSpots) {
    buffer.writeln(
      'update sessions set spot_id = ${_sql(s['spot_id'])} '
      'where id = ${_sql(s['id'])} and spot_id is null;',
    );
  }
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
        '${associations.length} associations, ${managers.length} manager '
        'requests, ${players.length} players, ${sessions.length} sessions, '
        '${teams.length} teams, ${playedHoles.length} played holes, '
        '${scores.length} scores, ${photos.length} session photos, '
        '${emails.length} pending e-mails, ${admins.length} local admins, ${events.length} events, '
        '${responses.length} event answers, ${comments.length} event comments, '
        '${spots.length} spots',
  );
}

/// One statement per row, which keeps the file readable once decrypted.
/// Rows already there are left as they are, unless [upsertOn] names the key
/// to update them on.
void _insert(
  StringBuffer buffer,
  String table,
  List<Map<String, dynamic>> rows, {
  String? upsertOn,
}) {
  for (final row in rows) {
    final conflict = upsertOn == null
        ? 'on conflict do nothing'
        : 'on conflict ($upsertOn) do update set '
              '${[for (final key in row.keys)
                if (key != upsertOn) '$key = excluded.$key'].join(', ')}';
    buffer.writeln(
      'insert into $table (${row.keys.join(', ')}) values '
      '(${row.values.map(_sql).join(', ')}) $conflict;',
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
