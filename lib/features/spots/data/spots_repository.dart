import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/spot.dart';

part 'spots_repository.g.dart';

/// What the spot form, or the "+" of the session form, writes (plan 28).
/// Null fields are left out: on an edit, they keep their value.
class SpotDraft {
  const SpotDraft({
    required this.name,
    this.description,
    this.address,
    this.city,
    this.lat,
    this.lng,
    this.variableLocation,
  });

  final String name;
  final String? description;
  final String? address;
  final String? city;
  final double? lat;
  final double? lng;

  /// Staff only (Q186): no point nor address, each use keeps its own.
  final bool? variableLocation;

  Map<String, Object?> toPayload() => {
    'name': name.trim(),
    'description': ?description,
    'address': ?address,
    'city': ?city,
    if (lat != null && lng != null) 'location': {'lat': lat, 'lng': lng},
    'variable_location': ?variableLocation,
  };
}

/// How many sessions and events use a spot, shown before deleting it.
class SpotUsage {
  const SpotUsage({required this.sessions, required this.events});

  final int sessions;
  final int events;
}

/// The spots table is read-only for the app (plan 28): every write is one of
/// the RPCs of rpc.sql, which decide who may.
class SpotsRepository {
  SpotsRepository(this._client);

  final SupabaseClient _client;

  /// [associationId]'s spots, by name (accents and case ignored).
  Future<List<Spot>> fetchSpots(String associationId) async {
    final rows = await _client
        .from('spots')
        .select()
        .eq('association_id', associationId);
    return sortSpots(rows.map(Spot.fromJson).toList());
  }

  Future<Spot> create(String associationId, SpotDraft draft) async {
    final row = await _client.rpc<Map<String, dynamic>>(
      'create_spot',
      params: {'p_association_id': associationId, 'payload': draft.toPayload()},
    );
    return Spot.fromJson(row);
  }

  Future<Spot> update(String spotId, SpotDraft draft) async {
    final row = await _client.rpc<Map<String, dynamic>>(
      'update_spot',
      params: {'p_spot_id': spotId, 'payload': draft.toPayload()},
    );
    return Spot.fromJson(row);
  }

  Future<void> delete(String spotId) =>
      _client.rpc<void>('delete_spot', params: {'p_spot_id': spotId});

  /// The sessions and events linked to [spotId] that the caller can read:
  /// all of them for its association's staff.
  Future<SpotUsage> usage(String spotId) async {
    final sessions = await _client
        .from('sessions')
        .select('id')
        .eq('spot_id', spotId)
        .count(CountOption.exact);
    final events = await _client
        .from('events')
        .select('id')
        .eq('spot_id', spotId)
        .count(CountOption.exact);
    return SpotUsage(sessions: sessions.count, events: events.count);
  }
}

final spotsRepositoryProvider = Provider<SpotsRepository>(
  (ref) => SpotsRepository(ref.watch(supabaseClientProvider)),
);

@riverpod
Future<List<Spot>> associationSpots(Ref ref, String associationId) =>
    ref.watch(spotsRepositoryProvider).fetchSpots(associationId);

/// The messages of the spot RPCs' errors.
String describeSpotError(Object error, AppLocalizations l10n) {
  if (error is PostgrestException) {
    switch (error.message) {
      case 'spot_name_taken':
        return l10n.spotsErrorNameTaken;
      case 'spot_location_required':
        return l10n.spotsErrorLocationRequired;
    }
  }
  return describeError(error, l10n);
}
