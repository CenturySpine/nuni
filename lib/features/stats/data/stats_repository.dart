import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../live/domain/live_session_snapshot.dart';

part 'stats_repository.g.dart';

class StatsRepository {
  StatsRepository(this._client);

  final SupabaseClient _client;

  /// Every completed session [playerId] played in (plan 19), whoever asks:
  /// hiding one's statistics is a display choice only (Q133). Which ones
  /// count is decided by `isEligibleSession`, not here.
  Future<List<LiveSessionSnapshot>> fetchPlayerHistory(String playerId) async {
    final List<dynamic> rows = await _client.rpc(
      'player_history',
      params: {'p_player_id': playerId},
    );
    return [
      for (final row in rows)
        LiveSessionSnapshot.fromJson(row as Map<String, Object?>),
    ];
  }

  /// Every completed session one of [holeIds] was played in (plan 20; plan
  /// 21 asks for several holes at once), whatever the association: a
  /// hole's statistics are common to all (Q95).
  Future<List<LiveSessionSnapshot>> fetchHolesHistory(
    Iterable<String> holeIds,
  ) async {
    if (holeIds.isEmpty) return const [];
    final List<dynamic> rows = await _client.rpc(
      'holes_history',
      params: {'p_hole_ids': holeIds.toList()},
    );
    return [
      for (final row in rows)
        LiveSessionSnapshot.fromJson(row as Map<String, Object?>),
    ];
  }
}

final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => StatsRepository(ref.watch(supabaseClientProvider)),
);

/// A player's sessions, reloaded on every visit (auto-disposed) so a session
/// completed in between is counted. The statistics themselves are computed
/// from it per season choice (`computePlayerStats`, a few milliseconds).
@riverpod
Future<List<LiveSessionSnapshot>> playerHistory(Ref ref, String playerId) =>
    ref.watch(statsRepositoryProvider).fetchPlayerHistory(playerId);

/// A hole's sessions, reloaded on every opening of its sheet (auto-disposed).
@riverpod
Future<List<LiveSessionSnapshot>> holeHistory(Ref ref, String holeId) =>
    ref.watch(statsRepositoryProvider).fetchHolesHistory([holeId]);
