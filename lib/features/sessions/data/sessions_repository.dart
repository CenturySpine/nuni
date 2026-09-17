import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// Hides gotrue's own `Session` type, which otherwise clashes with this
// feature's `Session` (mirroring the `sessions` table).
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../../../core/supabase/supabase_providers.dart';
import '../../../core/weather/weather.dart';
import '../../profile/domain/player.dart';
import '../domain/my_session_entry.dart';
import '../domain/ranking_direction.dart';
import '../domain/scoring_mode.dart';
import '../domain/session.dart';
import '../domain/session_kind.dart';
import '../domain/session_member.dart';
import '../domain/session_room.dart';
import '../domain/team.dart';
import '../domain/team_composition.dart';

part 'sessions_repository.g.dart';

class SessionsRepository {
  SessionsRepository(this._client);

  final SupabaseClient _client;

  Future<Session> create({
    required SessionKind kind,
    required ScoringMode scoringMode,
    required RankingDirection rankingDirection,
    String? city,
    String? zone,
    double? lat,
    double? lng,
  }) async {
    final payload = <String, Object?>{
      'kind': kind.toPostgresValue(),
      'scoring_mode': scoringMode.toPostgresValue(),
      'ranking_direction': rankingDirection.name,
      'city': city,
      'zone': zone,
      if (lat != null && lng != null) 'location': {'lat': lat, 'lng': lng},
    };
    final row = await _client.rpc<Map<String, dynamic>>(
      'create_session',
      params: {'payload': payload},
    );
    return Session.fromJson(row);
  }

  /// Set right after [startSession] when the session's position was known
  /// (fixed 2026-09-17: capturing weather at creation instead of at start
  /// gave the wrong day's weather for a session prepared in advance, Q26
  /// "cas 1") -- a plain owner update, not part of `start_session`, since the
  /// owner-update RLS policy has no status restriction. Also reused by plan
  /// 10 to recapture weather when the organizer edits the session's start
  /// date/time after the fact.
  Future<void> attachWeather(String sessionId, Weather weather) => _client
      .from('sessions')
      .update({'weather': weather.toJson()})
      .eq('id', sessionId);

  Future<Session> fetchSession(String id) async {
    final row = await _client.from('sessions').select().eq('id', id).single();
    return Session.fromJson(row);
  }

  /// Edits a completed session's schedule and comment (plan 10, owner-only --
  /// `sessions_update_owner` has no status restriction). Weather recapture on
  /// a start date/time change is the caller's job (`WeatherClient.fetchArchive`
  /// + [attachWeather]), not done here: it needs a network round trip of its
  /// own and a best-effort failure mode, same as the rest of the app's
  /// weather handling.
  Future<void> updateSchedule({
    required String sessionId,
    required DateTime startedAt,
    required DateTime endedAt,
    String? comment,
  }) => _client
      .from('sessions')
      .update({
        'started_at': startedAt.toUtc().toIso8601String(),
        'ended_at': endedAt.toUtc().toIso8601String(),
        'comment': comment,
      })
      .eq('id', sessionId);

  /// Join by code (plan 09, Q15): the `join_session` RPC applies the three
  /// cases (attached to a team, dropped in the pool, or refused) and is
  /// idempotent for someone already a member.
  Future<Session> joinByCode(String code) async {
    final row = await _client.rpc<Map<String, dynamic>>(
      'join_session',
      params: {'p_code': code},
    );
    return Session.fromJson(row);
  }

  /// Deletes a session outright (owner-only -- RLS `sessions_delete_owner`,
  /// no status restriction). Cascades to teams, team_players,
  /// session_members, played_holes, scores and session_photos.
  Future<void> deleteSession(String sessionId) =>
      _client.from('sessions').delete().eq('id', sessionId);

  /// Leaves a session the caller is a member of (self-service, draft only --
  /// RLS `session_members_self_leave_draft`).
  Future<void> leaveSession(String sessionId) async {
    final userId = _client.auth.currentUser!.id;
    await _client
        .from('session_members')
        .delete()
        .eq('session_id', sessionId)
        .eq('user_id', userId);
  }

  /// Promotes a member to co-organizer (owner-only, any status but
  /// completed -- RLS `session_members_owner_update`).
  Future<void> promoteToOwner({
    required String sessionId,
    required String userId,
  }) => _client
      .from('session_members')
      .update({'role': 'owner'})
      .eq('session_id', sessionId)
      .eq('user_id', userId);

  /// Sessions the caller is a member of, still in draft or live, most
  /// recent first ("Mes sessions en cours", plan 09).
  Future<List<MySessionEntry>> myOngoingSessions() =>
      _mySessionsByStatus(const ['draft', 'live']);

  /// The caller's most recently completed sessions, capped at [limit]
  /// ("Dernières sessions", plan 09 -- not otherwise specified by the plan;
  /// a short recency-ordered list, same shape as the rest of the app,
  /// applied as a hypothesis).
  Future<List<MySessionEntry>> myRecentSessions({int limit = 5}) =>
      _mySessionsByStatus(const ['completed'], limit: limit);

  /// Two plain queries instead of a nested PostgREST embed filter, same
  /// tradeoff as `_recentPlayerIds`: `session_members` has no status column
  /// to filter on directly.
  Future<List<MySessionEntry>> _mySessionsByStatus(
    List<String> statuses, {
    int? limit,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final memberRows = await _client
        .from('session_members')
        .select('session_id, role')
        .eq('user_id', userId);
    final roleBySessionId = {
      for (final row in memberRows)
        row['session_id'] as String: row['role'] as String,
    };
    if (roleBySessionId.isEmpty) return const [];

    var builder = _client
        .from('sessions')
        .select()
        .inFilter('id', roleBySessionId.keys.toList())
        .inFilter('status', statuses)
        .order('created_at', ascending: false);
    if (limit != null) builder = builder.limit(limit);
    final rows = await builder;
    return [
      for (final row in rows)
        MySessionEntry(
          session: Session.fromJson(row),
          role: memberRoleFromPostgresValue(roleBySessionId[row['id']]!),
        ),
    ];
  }

  Future<Session> startSession(String sessionId) async {
    final row = await _client.rpc<Map<String, dynamic>>(
      'start_session',
      params: {'p_session_id': sessionId},
    );
    return Session.fromJson(row);
  }

  /// Zones the owner has already typed for [city] on a past session
  /// (most recent first), deduplicated client-side -- PostgREST has no
  /// `select distinct`.
  Future<List<String>> zonesForCity(String city) async {
    if (city.trim().isEmpty) return const [];
    final ownerId = _client.auth.currentUser!.id;
    final rows = await _client
        .from('sessions')
        .select('zone, created_at')
        .eq('owner_id', ownerId)
        .eq('city', city)
        .not('zone', 'is', null)
        .order('created_at', ascending: false)
        .limit(50);

    final seen = <String>{};
    final zones = <String>[];
    for (final row in rows) {
      final zone = row['zone'] as String;
      if (seen.add(zone)) zones.add(zone);
    }
    return zones;
  }

  /// Players linked to a user (Q24), matching [query] by name (or all of
  /// them when empty), with the current user's own recently-played-with
  /// players surfaced first.
  Future<List<Player>> searchPlayers(String? query) async {
    final ownerId = _client.auth.currentUser!.id;
    final trimmed = query?.trim() ?? '';

    var builder = _client.from('players').select().not('user_id', 'is', null);
    if (trimmed.isNotEmpty) builder = builder.ilike('name', '%$trimmed%');
    final rows = await builder.order('name').limit(50);
    final players = [for (final row in rows) Player.fromJson(row)];

    final recency = await _recentPlayerIds(ownerId);
    players.sort((a, b) {
      final rankA = recency.indexOf(a.id);
      final rankB = recency.indexOf(b.id);
      if (rankA == -1 && rankB == -1) return a.name.compareTo(b.name);
      if (rankA == -1) return 1;
      if (rankB == -1) return -1;
      return rankA.compareTo(rankB);
    });
    return players;
  }

  /// Player ids from the owner's own past sessions, most recent session
  /// first, deduplicated. Three plain queries instead of a nested PostgREST
  /// embed: simpler to get right and to test against than a
  /// `team_players.select('player_id, teams!inner(sessions!inner(...))')`
  /// filter chain, at the cost of a couple of extra round trips -- fine at
  /// this app's scale.
  Future<List<String>> _recentPlayerIds(String ownerId) async {
    final sessionRows = await _client
        .from('sessions')
        .select('id')
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false)
        .limit(20);
    final sessionIds = [for (final row in sessionRows) row['id'] as String];
    if (sessionIds.isEmpty) return const [];

    final teamRows = await _client
        .from('teams')
        .select('id, session_id')
        .inFilter('session_id', sessionIds);
    final teamIdsBySessionOrder = [
      for (final sessionId in sessionIds)
        for (final row in teamRows)
          if (row['session_id'] == sessionId) row['id'] as String,
    ];
    if (teamIdsBySessionOrder.isEmpty) return const [];

    final memberRows = await _client
        .from('team_players')
        .select('team_id, player_id')
        .inFilter('team_id', teamIdsBySessionOrder);

    final seen = <String>{};
    final ordered = <String>[];
    for (final teamId in teamIdsBySessionOrder) {
      for (final row in memberRows) {
        if (row['team_id'] == teamId) {
          final playerId = row['player_id'] as String;
          if (seen.add(playerId)) ordered.add(playerId);
        }
      }
    }
    return ordered;
  }

  /// Adds a participant exactly as if they had joined (Q26): a plain
  /// `session_members` row, owner-only, draft-only (RLS).
  Future<void> addParticipant({
    required String sessionId,
    required String userId,
  }) => _client.from('session_members').insert({
    'session_id': sessionId,
    'user_id': userId,
    'role': 'player',
  });

  /// Forms one team from [selection] (userId -> playerId) and assigns its
  /// members (Q5: manual mode passes exactly 2).
  Future<void> formTeam({
    required String sessionId,
    required Map<String, String> selection,
  }) async {
    final position = await _nextTeamPosition(sessionId);
    final teamRow = await _client
        .from('teams')
        .insert({'session_id': sessionId, 'position': position})
        .select('id')
        .single();
    final teamId = teamRow['id'] as String;

    await _client.from('team_players').insert([
      for (final playerId in selection.values)
        {'team_id': teamId, 'player_id': playerId},
    ]);

    await _client
        .from('session_members')
        .update({'team_id': teamId})
        .eq('session_id', sessionId)
        .inFilter('user_id', selection.keys.toList());
  }

  /// Draws random pairs from [selection] (userId -> playerId) and forms a
  /// team per pair, sequentially (each `formTeam` call needs the position
  /// the previous one just took).
  Future<void> formRandomTeams({
    required String sessionId,
    required Map<String, String> selection,
    Random? random,
  }) async {
    final pairs = drawRandomTeams(selection.keys.toList(), random: random);
    for (final pair in pairs) {
      await formTeam(
        sessionId: sessionId,
        selection: {for (final userId in pair) userId: selection[userId]!},
      );
    }
  }

  Future<int> _nextTeamPosition(String sessionId) async {
    final rows = await _client
        .from('teams')
        .select('position')
        .eq('session_id', sessionId)
        .order('position', ascending: false)
        .limit(1);
    if (rows.isEmpty) return 1;
    return (rows.first['position'] as int) + 1;
  }

  /// Moves a member back to the pool without removing them from the session.
  Future<void> unassignMember({
    required String sessionId,
    required String userId,
    required String teamId,
    required String playerId,
  }) async {
    await _client
        .from('team_players')
        .delete()
        .eq('team_id', teamId)
        .eq('player_id', playerId);
    await _client
        .from('session_members')
        .update({'team_id': null})
        .eq('session_id', sessionId)
        .eq('user_id', userId);
  }

  /// Removes a participant from the session entirely, freeing their team
  /// slot first if they had one.
  Future<void> removeMember({
    required String sessionId,
    required String userId,
    String? teamId,
    String? playerId,
  }) async {
    if (teamId != null && playerId != null) {
      await _client
          .from('team_players')
          .delete()
          .eq('team_id', teamId)
          .eq('player_id', playerId);
    }
    await _client
        .from('session_members')
        .delete()
        .eq('session_id', sessionId)
        .eq('user_id', userId);
  }

  /// Deletes a team; `team_players` cascades and every member's
  /// `session_members.team_id` is set back to null by the foreign key
  /// (Q5, "suppression d'une équipe libère ses joueurs").
  Future<void> deleteTeam(String teamId) =>
      _client.from('teams').delete().eq('id', teamId);

  /// A live view of the waiting room: the session row, its participant pool
  /// and its teams. Each of the three tables has its own session-filtered
  /// realtime subscription (plan 03's "jamais sur une table entière" rule),
  /// but the subscription is used only as a "something changed" signal --
  /// on any event, all three are freshly re-selected and the snapshot is
  /// rebuilt from that. Trusting `.stream()`'s own cached row list directly
  /// (the first approach here) surfaced two distinct bugs in testing: a
  /// duplicated row on `session_members` (composite primary key) and a
  /// deleted `teams` row that kept reappearing after a delete -- re-fetching
  /// plain `select()`s on every change sidesteps that caching entirely
  /// rather than trying to patch each symptom.
  Stream<SessionRoomSnapshot> watchRoom(String sessionId) {
    late final StreamController<SessionRoomSnapshot> controller;
    StreamSubscription<List<Map<String, dynamic>>>? sessionSub;
    StreamSubscription<List<Map<String, dynamic>>>? membersSub;
    StreamSubscription<List<Map<String, dynamic>>>? teamsSub;

    final playersByUserId = <String, Player>{};
    var isRefreshing = false;
    var pending = false;

    Future<void> refresh() async {
      if (isRefreshing) {
        pending = true;
        return;
      }
      isRefreshing = true;
      try {
        final sessionRow = await _client
            .from('sessions')
            .select()
            .eq('id', sessionId)
            .maybeSingle();
        if (sessionRow == null) {
          if (!controller.isClosed) controller.close();
          return;
        }

        final memberRows = await _client
            .from('session_members')
            .select()
            .eq('session_id', sessionId);
        final teamRows = await _client
            .from('teams')
            .select()
            .eq('session_id', sessionId);

        final userIds = {
          for (final row in memberRows) row['user_id'] as String,
        };
        final missing = userIds.difference(playersByUserId.keys.toSet());
        if (missing.isNotEmpty) {
          final rows = await _client
              .from('players')
              .select()
              .inFilter('user_id', missing.toList());
          for (final row in rows) {
            final player = Player.fromJson(row);
            if (player.userId != null) playersByUserId[player.userId!] = player;
          }
        }
        if (controller.isClosed) return;

        final teams = [for (final row in teamRows) Team.fromJson(row)]
          ..sort((a, b) => a.position.compareTo(b.position));
        controller.add(
          SessionRoomSnapshot(
            session: Session.fromJson(sessionRow),
            members: [
              for (final row in memberRows) SessionMember.fromJson(row),
            ],
            teams: teams,
            playersByUserId: Map.unmodifiable(playersByUserId),
          ),
        );
      } catch (error, stackTrace) {
        if (!controller.isClosed) controller.addError(error, stackTrace);
      } finally {
        isRefreshing = false;
        if (pending) {
          pending = false;
          unawaited(refresh());
        }
      }
    }

    controller = StreamController<SessionRoomSnapshot>.broadcast(
      onListen: () {
        sessionSub = _client
            .from('sessions')
            .stream(primaryKey: ['id'])
            .eq('id', sessionId)
            .listen((_) => unawaited(refresh()), onError: controller.addError);
        membersSub = _client
            .from('session_members')
            .stream(primaryKey: ['session_id', 'user_id'])
            .eq('session_id', sessionId)
            .listen((_) => unawaited(refresh()), onError: controller.addError);
        teamsSub = _client
            .from('teams')
            .stream(primaryKey: ['id'])
            .eq('session_id', sessionId)
            .listen((_) => unawaited(refresh()), onError: controller.addError);
      },
      onCancel: () {
        unawaited(sessionSub?.cancel());
        unawaited(membersSub?.cancel());
        unawaited(teamsSub?.cancel());
      },
    );

    return controller.stream;
  }
}

final sessionsRepositoryProvider = Provider<SessionsRepository>(
  (ref) => SessionsRepository(ref.watch(supabaseClientProvider)),
);

@riverpod
Stream<SessionRoomSnapshot> sessionRoom(Ref ref, String sessionId) =>
    ref.watch(sessionsRepositoryProvider).watchRoom(sessionId);

@riverpod
Future<List<Player>> playerSearch(Ref ref, String query) =>
    ref.watch(sessionsRepositoryProvider).searchPlayers(query);

@riverpod
Future<List<String>> zoneSuggestions(Ref ref, String city) =>
    ref.watch(sessionsRepositoryProvider).zonesForCity(city);

@riverpod
Future<List<MySessionEntry>> myOngoingSessions(Ref ref) =>
    ref.watch(sessionsRepositoryProvider).myOngoingSessions();

@riverpod
Future<List<MySessionEntry>> myRecentSessions(Ref ref) =>
    ref.watch(sessionsRepositoryProvider).myRecentSessions();
