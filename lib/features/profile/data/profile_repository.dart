import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/player.dart';
import '../domain/profile.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<Profile> fetchMyProfile() async {
    final userId = _client.auth.currentUser!.id;
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return Profile.fromJson(row);
  }

  Future<Player> fetchMyPlayer() async {
    final userId = _client.auth.currentUser!.id;
    final row = await _client
        .from('players')
        .select()
        .eq('user_id', userId)
        .single();
    return Player.fromJson(row);
  }

  /// Saves the profile, then mirrors the display name and avatar onto the
  /// linked player (plan 05: "le joueur lié reprend le nom et l'avatar du
  /// profil, synchronisation à la sauvegarde").
  Future<void> updateMyProfile({
    required String displayName,
    String? avatarUrl,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client
        .from('profiles')
        .update({'display_name': displayName, 'avatar_url': ?avatarUrl})
        .eq('id', userId);
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
Future<Profile> myProfile(Ref ref) =>
    ref.watch(profileRepositoryProvider).fetchMyProfile();

@riverpod
Future<Player> myPlayer(Ref ref) =>
    ref.watch(profileRepositoryProvider).fetchMyPlayer();
