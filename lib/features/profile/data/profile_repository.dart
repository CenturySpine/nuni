import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/player.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<Player> fetchMyPlayer() async {
    final userId = _client.auth.currentUser!.id;
    final row = await _client
        .from('players')
        .select()
        .eq('user_id', userId)
        .single();
    return Player.fromJson(row);
  }

  Future<void> updateMyPlayer({
    required String displayName,
    String? avatarUrl,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client
        .from('players')
        .update({'name': displayName, 'avatar_url': ?avatarUrl})
        .eq('user_id', userId);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(supabaseClientProvider)),
);

@riverpod
Future<Player> myPlayer(Ref ref) =>
    ref.watch(profileRepositoryProvider).fetchMyPlayer();
