import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../live/data/live_repository.dart';
import '../../live/domain/live_session_snapshot.dart';
import '../domain/history_entry.dart';
import '../domain/session_photo.dart';

part 'history_repository.g.dart';

class HistoryRepository {
  HistoryRepository(this._client);

  final SupabaseClient _client;

  /// Every completed session the caller is a member of (`history_snapshots`
  /// RPC, plan 10), most recent first -- see the migration's own comment for
  /// why this reuses `session_snapshot`'s shape instead of a slimmer one.
  Future<List<HistoryEntry>> fetchHistory() async {
    final List<dynamic> rows = await _client.rpc('history_snapshots');
    return [
      for (final row in rows)
        HistoryEntry(LiveSessionSnapshot.fromJson(row as Map<String, Object?>)),
    ];
  }

  Future<List<SessionPhoto>> fetchPhotos(String sessionId) async {
    final rows = await _client
        .from('session_photos')
        .select()
        .eq('session_id', sessionId)
        .order('created_at');
    return [for (final row in rows) SessionPhoto.fromJson(row)];
  }

  /// Uploads and inserts in one call (owner-only, RLS `session_photos_owner_write`
  /// and the matching `session-photos_bucket_owner_insert` storage policy).
  /// Path is `<session_id>/<uuid>.jpg` -- the bucket's ownership follows the
  /// session, not the uploader (plan 03), so the path's first segment must
  /// be the session id, not the caller's own id (unlike `holes`/`avatars`).
  Future<SessionPhoto> uploadPhoto({
    required String sessionId,
    required Uint8List bytes,
  }) async {
    final path = '$sessionId/${const Uuid().v4()}.jpg';
    await _client.storage
        .from('session-photos')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );
    final row = await _client
        .from('session_photos')
        .insert({
          'session_id': sessionId,
          'storage_path': path,
          'uploaded_by': _client.auth.currentUser!.id,
        })
        .select()
        .single();
    return SessionPhoto.fromJson(row);
  }

  String photoUrl(String path) =>
      _client.storage.from('session-photos').getPublicUrl(path);

  /// Purge order (Q37): the storage object first, so the operation never
  /// leaves a `session_photos` row pointing at a file that's already gone --
  /// if the storage call fails, the row (and the acceptance criterion "a
  /// deleted photo disappears from the bucket") simply isn't satisfied yet,
  /// and the caller can retry.
  Future<void> deletePhoto(SessionPhoto photo) async {
    await _client.storage.from('session-photos').remove([photo.storagePath]);
    await _client.from('session_photos').delete().eq('id', photo.id);
  }

  Future<void> setCoverPhoto({
    required String sessionId,
    required String? photoId,
  }) => _client
      .from('sessions')
      .update({'cover_photo_id': photoId})
      .eq('id', sessionId);

  /// "Supprimer la session" from the history detail (plan 10): purges every
  /// photo's storage object first (best-effort per file, a partial bucket
  /// failure shouldn't block deleting the session itself -- unlike a single
  /// photo delete, there's no row left afterwards to retry against), then
  /// deletes the session row, which cascades everything else in the
  /// database (teams, played_holes, scores, session_photos rows).
  Future<void> deleteSessionWithPhotos({
    required String sessionId,
    required List<SessionPhoto> photos,
  }) async {
    if (photos.isNotEmpty) {
      try {
        await _client.storage.from('session-photos').remove([
          for (final p in photos) p.storagePath,
        ]);
      } catch (_) {
        // Best-effort: an orphaned file is a smaller problem than being
        // unable to delete the session at all.
      }
    }
    await _client.from('sessions').delete().eq('id', sessionId);
  }
}

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(supabaseClientProvider)),
);

@riverpod
Future<List<HistoryEntry>> historyEntries(Ref ref) =>
    ref.watch(historyRepositoryProvider).fetchHistory();

@riverpod
Future<List<SessionPhoto>> sessionPhotos(Ref ref, String sessionId) =>
    ref.watch(historyRepositoryProvider).fetchPhotos(sessionId);

/// The detail screen's data (plan 10): the exact same `session_snapshot`
/// call the live screen makes (Q36's shape, reused), wrapped with its
/// standings -- read-only here, no realtime subscription (a completed
/// session's data doesn't change under the viewer the way a live one does).
@riverpod
Future<HistoryEntry?> historyDetail(Ref ref, String sessionId) async {
  final snapshot = await ref
      .watch(liveRepositoryProvider)
      .fetchSnapshot(sessionId);
  return snapshot == null ? null : HistoryEntry(snapshot);
}
