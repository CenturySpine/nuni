import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../../core/text/compare_names.dart';
import '../../profile/domain/player.dart';

part 'players_repository.g.dart';

class PlayersRepository {
  PlayersRepository(this._client);

  final SupabaseClient _client;

  /// Any player, imported ones included (plan 26, volet C): the `players`
  /// table is readable by every signed-in account (RLS `players_select`).
  /// Null when no such player exists.
  Future<Player?> fetchById(String id) async {
    final row = await _client
        .from('players')
        .select()
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : Player.fromJson(row);
  }

  /// The members of an association who have a NUNI account, sorted by name
  /// (the association page's member list). Imported players are left out
  /// until they are matched with an account (PO, 2026-09-24).
  Future<List<Player>> fetchByAssociation(String associationId) async {
    final rows = await _client
        .from('players')
        .select()
        .eq('association_id', associationId)
        .not('user_id', 'is', null);
    return rows.map(Player.fromJson).toList()
      ..sort((a, b) => compareNames(a.name, b.name));
  }
}

final playersRepositoryProvider = Provider<PlayersRepository>(
  (ref) => PlayersRepository(ref.watch(supabaseClientProvider)),
);

@riverpod
Future<Player?> playerById(Ref ref, String id) =>
    ref.watch(playersRepositoryProvider).fetchById(id);

@riverpod
Future<List<Player>> associationPlayers(Ref ref, String associationId) =>
    ref.watch(playersRepositoryProvider).fetchByAssociation(associationId);
