import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../live/domain/live_session_snapshot.dart';
import '../domain/championship_membership.dart';
import '../domain/championship_session_result.dart';
import '../domain/player_standing.dart';

part 'championship_repository.g.dart';

class ChampionshipRepository {
  ChampionshipRepository(this._client);

  final SupabaseClient _client;

  /// Every zone/season the caller has at least one completed championship
  /// session in (plan 15, parcours 2): a plain `sessions` read, no RPC --
  /// the existing member-only RLS already limits this to sessions the
  /// caller took part in, same as any other session read.
  Future<List<ChampionshipMembership>> fetchMyMemberships() async {
    final rows = await _client
        .from('sessions')
        .select('championship_zone_id, championship_season')
        .eq('is_championship', true)
        .eq('status', 'completed');

    final seen = <String>{};
    final memberships = <ChampionshipMembership>[];
    for (final row in rows) {
      final zoneId = row['championship_zone_id'] as String?;
      final season = row['championship_season'] as String?;
      if (zoneId == null || season == null) continue;
      if (seen.add('$zoneId|$season')) {
        memberships.add((zoneId: zoneId, season: season));
      }
    }
    return memberships;
  }

  Future<String?> fetchZoneLabel(String zoneId) => _client.rpc<String?>(
    'championship_zone_label',
    params: {'p_zone_id': zoneId},
  );

  /// Every championship session of [zoneId]/[season], already folded into
  /// per-player points (plan 15's calculation, kept in Dart -- the RPC
  /// returns only raw already-entered data, same shape as a
  /// `session_snapshot` call).
  Future<List<ChampionshipSessionResult>> fetchZoneResults({
    required String zoneId,
    required String season,
  }) async {
    final List<dynamic> rows = await _client.rpc(
      'championship_zone_results',
      params: {'p_zone_id': zoneId, 'p_season': season},
    );
    return [
      for (final row in rows)
        ChampionshipSessionResult.fromSnapshot(
          LiveSessionSnapshot.fromJson(row as Map<String, Object?>),
        ),
    ];
  }
}

final championshipRepositoryProvider = Provider<ChampionshipRepository>(
  (ref) => ChampionshipRepository(ref.watch(supabaseClientProvider)),
);

@riverpod
Future<List<ChampionshipMembership>> myChampionshipMemberships(Ref ref) =>
    ref.watch(championshipRepositoryProvider).fetchMyMemberships();

@riverpod
Future<String?> championshipZoneLabel(Ref ref, String zoneId) =>
    ref.watch(championshipRepositoryProvider).fetchZoneLabel(zoneId);

@riverpod
Future<List<PlayerStanding>> championshipZoneStandings(
  Ref ref,
  String zoneId,
  String season,
) async {
  final results = await ref
      .watch(championshipRepositoryProvider)
      .fetchZoneResults(zoneId: zoneId, season: season);
  return seasonStandings(results);
}
