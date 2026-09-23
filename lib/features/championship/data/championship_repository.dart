import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../associations/data/associations_repository.dart';
import '../../live/domain/live_session_snapshot.dart';
import '../domain/championship_membership.dart';
import '../domain/championship_session_result.dart';
import '../domain/player_standing.dart';

part 'championship_repository.g.dart';

class ChampionshipRepository {
  ChampionshipRepository(this._client);

  final SupabaseClient _client;

  /// Every association/season the caller has at least one completed championship
  /// session in (plan 15, parcours 2): a plain `sessions` read, no RPC --
  /// the existing member-only RLS already limits this to sessions the
  /// caller took part in, same as any other session read.
  Future<List<ChampionshipMembership>> fetchMyMemberships() async {
    final rows = await _client
        .from('sessions')
        .select('association_id, championship_season')
        .eq('is_championship', true)
        .eq('status', 'completed');

    final seen = <String>{};
    final memberships = <ChampionshipMembership>[];
    for (final row in rows) {
      final associationId = row['association_id'] as String?;
      final season = row['championship_season'] as String?;
      if (associationId == null || season == null) continue;
      if (seen.add('$associationId|$season')) {
        memberships.add((associationId: associationId, season: season));
      }
    }
    return memberships;
  }

  /// Every championship session of [associationId]/[season], already folded into
  /// per-player points (plan 15's calculation, kept in Dart -- the RPC
  /// returns only raw already-entered data, same shape as a
  /// `session_snapshot` call).
  Future<List<ChampionshipSessionResult>> fetchResults({
    required String associationId,
    required String season,
  }) async {
    final List<dynamic> rows = await _client.rpc(
      'championship_association_results',
      params: {'p_association_id': associationId, 'p_season': season},
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

/// A championship's name (plan 18, Q77): its association's abbreviation, or
/// its name when it has none.
@riverpod
Future<String?> championshipAssociationLabel(
  Ref ref,
  String associationId,
) async =>
    (await ref.watch(associationByIdProvider(associationId).future))?.label;

@riverpod
Future<List<PlayerStanding>> championshipStandings(
  Ref ref,
  String associationId,
  String season,
) async {
  final results = await ref
      .watch(championshipRepositoryProvider)
      .fetchResults(associationId: associationId, season: season);
  return seasonStandings(results);
}
