import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

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

  /// Replaces my photo with [jpegBytes] (already cropped and resized by the
  /// caller): uploads it to `avatars/<user id>/`, points `players.avatar_url`
  /// at it -- overriding the Google photo copied at sign-up -- then deletes
  /// [previousUrl] if it was a photo uploaded here. A fresh file name each
  /// time, so no browser keeps showing the old image from its cache.
  Future<String> uploadMyAvatar(
    Uint8List jpegBytes, {
    String? previousUrl,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final bucket = _client.storage.from('avatars');
    final path = '$userId/${const Uuid().v4()}.jpg';
    await bucket.uploadBinary(
      path,
      jpegBytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg'),
    );
    final url = bucket.getPublicUrl(path);
    await _client
        .from('players')
        .update({'avatar_url': url})
        .eq('user_id', userId);

    final marker = '/avatars/$userId/';
    if (previousUrl != null && previousUrl.contains(marker)) {
      // Best effort: the new photo is already in place.
      try {
        await bucket.remove([
          '$userId/${previousUrl.split(marker).last.split('?').first}',
        ]);
      } on StorageException catch (error) {
        debugPrint('Previous avatar not deleted: ${error.message}');
      }
    }
    return url;
  }

  /// Shows or hides my statistics on my public page (plan 19, Q108) --
  /// display only, the sessions behind them stay readable (Q133).
  Future<void> updateMyStatsPublic(bool statsPublic) async {
    final userId = _client.auth.currentUser!.id;
    await _client
        .from('players')
        .update({'stats_public': statsPublic})
        .eq('user_id', userId);
  }

  Future<void> updateMyLocale(String locale) async {
    final userId = _client.auth.currentUser!.id;
    await _client
        .from('players')
        .update({'locale': locale})
        .eq('user_id', userId);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(supabaseClientProvider)),
);

@riverpod
Future<Player> myPlayer(Ref ref) =>
    ref.watch(profileRepositoryProvider).fetchMyPlayer();
