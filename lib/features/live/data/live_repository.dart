import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/game_mode.dart';
import '../domain/live_session_snapshot.dart';

part 'live_repository.g.dart';

/// Surfaced by [LiveRepository.watchSession] when the session has been
/// deleted out from under a viewer (plan 08: "si supprimée, retour à
/// l'accueil avec message" for everyone but the owner, who already
/// navigates away the moment their own delete call returns).
class LiveSessionDeleted implements Exception {}

class LiveRepository {
  LiveRepository(this._client);

  final SupabaseClient _client;

  /// Null when the session no longer exists (deleted by the owner, plan
  /// 08's "Annulation") -- `session_snapshot`'s `session` field comes back
  /// JSON null rather than the RPC raising, since every other field it
  /// builds is a `coalesce`d array that stays empty for a session_id
  /// matching nothing.
  Future<LiveSessionSnapshot?> fetchSnapshot(String sessionId) async {
    final json = await _client.rpc<Map<String, dynamic>>(
      'session_snapshot',
      params: {'p_session_id': sessionId},
    );
    if (json['session'] == null) return null;
    return LiveSessionSnapshot.fromJson(json);
  }

  /// Immediate save on every chip tap (plan 08, no "Enregistrer" button):
  /// RLS decides whether the caller may write this team's score (Q8 --
  /// their own team, or any team for the owner/a co-organizer).
  Future<void> upsertScore({
    required String playedHoleId,
    required String teamId,
    required int value,
  }) => _client.from('scores').upsert({
    'played_hole_id': playedHoleId,
    'team_id': teamId,
    'value': value,
    'updated_by': _client.auth.currentUser!.id,
  });

  /// Owner-only (RLS `played_holes_owner_write`); appends at the next
  /// position server-side (`add_played_hole` RPC) to avoid a client-side
  /// "next position" race between two owners adding at once. A null
  /// [holeId] adds a generic free hole (plan 17), with an optional [label].
  Future<void> addPlayedHole({
    required String sessionId,
    required String? holeId,
    required GameMode gameMode,
    String? label,
  }) => _client.rpc<Map<String, dynamic>>(
    'add_played_hole',
    params: {
      'p_session_id': sessionId,
      'p_hole_id': holeId,
      'p_game_mode': gameMode.toPostgresValue(),
      'p_label': label,
    },
  );

  /// Owner-only; its scores cascade (plan 08).
  Future<void> deletePlayedHole(String playedHoleId) =>
      _client.from('played_holes').delete().eq('id', playedHoleId);

  /// "Terminer la session" (owner-only, plan 08): a plain update, same RLS
  /// policy as every other owner write to `sessions` (no status
  /// restriction). `.toUtc()` matters here (found while testing plan 10's
  /// duration/export math, 2026-09-17): a plain local `DateTime.now()`
  /// serializes without a timezone offset, so Postgres read it as if it
  /// were already UTC -- every session closed before this fix has an
  /// `ended_at` shifted by the closer's local UTC offset.
  Future<void> closeSession(String sessionId) => _client
      .from('sessions')
      .update({
        'status': 'completed',
        'ended_at': DateTime.now().toUtc().toIso8601String(),
      })
      .eq('id', sessionId);

  /// A live view of a session in progress: the full snapshot, refreshed
  /// from scratch on every realtime "something changed" signal (Q36) on
  /// any of the six session-scoped tables the live screen cares about --
  /// same reasoning as `SessionsRepository.watchRoom`, extended to the
  /// tables plan 08 adds (`played_holes`, `scores`, `team_players`).
  Stream<LiveSessionSnapshot> watchSession(String sessionId) {
    late final StreamController<LiveSessionSnapshot> controller;
    final subscriptions = <StreamSubscription<List<Map<String, dynamic>>>>[];

    var isRefreshing = false;
    var pending = false;

    Future<void> refresh() async {
      if (isRefreshing) {
        pending = true;
        return;
      }
      isRefreshing = true;
      try {
        final snapshot = await fetchSnapshot(sessionId);
        if (controller.isClosed) return;
        if (snapshot == null) {
          controller.addError(LiveSessionDeleted());
          unawaited(controller.close());
          return;
        }
        controller.add(snapshot);
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

    void subscribe(String table, List<String> primaryKey) {
      subscriptions.add(
        _client
            .from(table)
            .stream(primaryKey: primaryKey)
            .eq('session_id', sessionId)
            .listen((_) => unawaited(refresh()), onError: controller.addError),
      );
    }

    controller = StreamController<LiveSessionSnapshot>.broadcast(
      onListen: () {
        subscriptions.add(
          _client
              .from('sessions')
              .stream(primaryKey: ['id'])
              .eq('id', sessionId)
              .listen(
                (_) => unawaited(refresh()),
                onError: controller.addError,
              ),
        );
        subscribe('session_members', ['session_id', 'user_id']);
        subscribe('teams', ['id']);
        subscribe('team_players', ['team_id', 'player_id']);
        subscribe('played_holes', ['id']);
        subscribe('scores', ['played_hole_id', 'team_id']);
      },
      onCancel: () {
        for (final sub in subscriptions) {
          unawaited(sub.cancel());
        }
      },
    );

    return controller.stream;
  }
}

final liveRepositoryProvider = Provider<LiveRepository>(
  (ref) => LiveRepository(ref.watch(supabaseClientProvider)),
);

@riverpod
Stream<LiveSessionSnapshot> liveSession(Ref ref, String sessionId) =>
    ref.watch(liveRepositoryProvider).watchSession(sessionId);
