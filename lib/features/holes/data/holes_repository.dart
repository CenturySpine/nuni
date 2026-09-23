import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/location/location_service.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../domain/hole.dart';

part 'holes_repository.g.dart';

/// Proximity radius slider (Q10, revised PO 2026-09-16): 0 to 10 km, 500 m
/// steps, defaulting to 1 km and remembered on the device.
const holesRadiusMinM = 0;
const holesRadiusMaxM = 10000;
const holesRadiusStepM = 500;
const holesRadiusDefaultM = 1000;
const _holesRadiusPrefsKey = 'nuni.holes_radius_m';

class HolesRepository {
  HolesRepository(this._client);

  final SupabaseClient _client;

  Future<List<Hole>> fetchNearby({
    required double lat,
    required double lng,
    required int radiusM,
  }) async {
    final List<dynamic> rows = await _client.rpc(
      'holes_nearby',
      params: {'p_lat': lat, 'p_lng': lng, 'p_radius_m': radiusM},
    );
    return [for (final row in rows) Hole.fromJson(row as Map<String, Object?>)];
  }

  Future<List<Hole>> fetchMine() async {
    final userId = _client.auth.currentUser!.id;
    final rows = await _client
        .from('holes')
        .select()
        .eq('owner_id', userId)
        .order('name');
    return [for (final row in rows) Hole.fromJson(row)];
  }

  /// My most recently created or modified hole that has a position, other
  /// than [excludeId] (PO, 2026-09-23): lets the form jump the map straight
  /// to the area being worked on. Read from the database (`updated_at`, kept
  /// by a trigger) rather than remembered on the device, so it follows the
  /// user from one device to another.
  Future<Hole?> fetchLastPlaced({String? excludeId}) async {
    var query = _client
        .from('holes')
        .select()
        .eq('owner_id', _client.auth.currentUser!.id)
        .not('start', 'is', null);
    if (excludeId != null) query = query.neq('id', excludeId);
    final row = await query
        .order('updated_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return row == null ? null : Hole.fromJson(row);
  }

  Future<Hole> fetchById(String id) async {
    final row = await _client.from('holes').select().eq('id', id).single();
    return Hole.fromJson(row);
  }

  Future<String> create({
    required String name,
    String? description,
    required int par,
    int? distanceM,
    required double lat,
    required double lng,
    double? endLat,
    double? endLng,
    List<HolePathPoint>? path,
    required HoleVisibility visibility,
    String? photoStartPath,
    String? photoEndPath,
  }) async {
    final ownerId = _client.auth.currentUser!.id;
    final row = await _client
        .from('holes')
        .insert({
          'owner_id': ownerId,
          'name': name,
          'description': description,
          'par': par,
          'distance_m': distanceM,
          'start': 'SRID=4326;POINT($lng $lat)',
          'end_point': _pointOrNull(endLat, endLng),
          'path': _pathOrNull(path),
          'visibility': visibility.name,
          'photo_start_path': photoStartPath,
          'photo_end_path': photoEndPath,
        })
        .select('id')
        .single();
    return row['id'] as String;
  }

  Future<void> update({
    required String id,
    required String name,
    String? description,
    required int par,
    int? distanceM,
    required double lat,
    required double lng,
    double? endLat,
    double? endLng,
    List<HolePathPoint>? path,
    required HoleVisibility visibility,
    String? photoStartPath,
    String? photoEndPath,
  }) async {
    await _client
        .from('holes')
        .update({
          'name': name,
          'description': description,
          'par': par,
          'distance_m': distanceM,
          'start': 'SRID=4326;POINT($lng $lat)',
          'end_point': _pointOrNull(endLat, endLng),
          'path': _pathOrNull(path),
          'visibility': visibility.name,
          'photo_start_path': photoStartPath,
          'photo_end_path': photoEndPath,
        })
        .eq('id', id);
  }

  static String? _pointOrNull(double? lat, double? lng) =>
      (lat == null || lng == null) ? null : 'SRID=4326;POINT($lng $lat)';

  static List<Map<String, double>>? _pathOrNull(List<HolePathPoint>? path) =>
      (path == null || path.isEmpty)
      ? null
      : [
          for (final point in path) {'lat': point.lat, 'lng': point.lng},
        ];

  /// Throws a [PostgrestException] with code `23503` (foreign key violation)
  /// if the hole has been played in a session -- deletion is refused by a
  /// database constraint, not application logic (plan 06).
  Future<void> delete(String id) => _client.from('holes').delete().eq('id', id);

  /// [folderId] is a storage path segment, not necessarily the hole's row id:
  /// for a hole not created yet, the form generates a throwaway id upfront so
  /// the upload can start the moment a photo is picked, instead of waiting
  /// for the row to exist (PO, 2026-09-16).
  Future<String> uploadPhoto({
    required String folderId,
    required bool isStart,
    required Uint8List bytes,
  }) async {
    final ownerId = _client.auth.currentUser!.id;
    final path = '$ownerId/$folderId/${isStart ? 'start' : 'end'}.jpg';
    await _client.storage
        .from('holes')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );
    return path;
  }

  /// Deletes photos a hole no longer references, once it's saved (Q61:
  /// removing or replacing a photo deletes the old file). Best effort: the
  /// hole is already saved, so a failure only leaves an unreferenced file and
  /// must not surface as a failed save.
  Future<void> deletePhotos(Set<String> paths) async {
    if (paths.isEmpty) return;
    try {
      await _client.storage.from('holes').remove(paths.toList());
    } on StorageException catch (error) {
      debugPrint('Unreferenced hole photos not deleted: ${error.message}');
    }
  }

  String photoUrl(String path) =>
      _client.storage.from('holes').getPublicUrl(path);
}

final holesRepositoryProvider = Provider<HolesRepository>(
  (ref) => HolesRepository(ref.watch(supabaseClientProvider)),
);

@riverpod
Future<Position?> myPosition(Ref ref) =>
    ref.watch(locationServiceProvider).getCurrentPosition();

@riverpod
Future<List<Hole>> nearbyHoles(Ref ref, int radiusM) async {
  final position = await ref.watch(myPositionProvider.future);
  if (position == null) return const [];
  return ref
      .watch(holesRepositoryProvider)
      .fetchNearby(
        lat: position.latitude,
        lng: position.longitude,
        radiusM: radiusM,
      );
}

@riverpod
Future<List<Hole>> myHoles(Ref ref) =>
    ref.watch(holesRepositoryProvider).fetchMine();

@riverpod
Future<Hole> holeById(Ref ref, String id) =>
    ref.watch(holesRepositoryProvider).fetchById(id);

@riverpod
Future<Hole?> lastPlacedHole(Ref ref, String? excludeId) =>
    ref.watch(holesRepositoryProvider).fetchLastPlaced(excludeId: excludeId);

/// The last radius the user picked (device-local, `shared_preferences`),
/// falling back to [holesRadiusDefaultM] on first use.
@riverpod
class HolesRadius extends _$HolesRadius {
  @override
  Future<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_holesRadiusPrefsKey) ?? holesRadiusDefaultM;
  }

  Future<void> set(int radiusM) async {
    state = AsyncData(radiusM);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_holesRadiusPrefsKey, radiusM);
  }
}
