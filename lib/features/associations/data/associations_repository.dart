import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/association.dart';

part 'associations_repository.g.dart';

/// The approved manager shown on an association's card (plan 18): only
/// their player name is public.
typedef ManagerSummary = ({String managerId, String userId, String name});

/// A creation request or a local-manager claim awaiting a super_admin
/// (plan 18, decision 9), with everything the review page shows.
typedef PendingRequest = ({
  Association association,
  AssociationManager manager,
  ManagerContact? contact,
  String requesterName,

  /// True for a new association, false for a claim on an existing one.
  bool isCreation,
});

/// Form fields of a creation request or an edit (plan 18, decisions 7-8).
/// Null fields are left out of an edit's payload (unchanged).
typedef AssociationDraft = ({
  String? name,
  String? shortName,
  String? city,
  double? lat,
  double? lng,
  String? websiteUrl,
  String? email,
  String? phone,
  String? message,
});

class AssociationsRepository {
  AssociationsRepository(this._client);

  final SupabaseClient _client;

  String get _myUserId => _client.auth.currentUser!.id;

  /// Approved associations, plus my own pending or refused request, plus
  /// every request for a super_admin -- the associations RLS decides.
  Future<List<Association>> fetchAll() async {
    final rows = await _client.from('associations').select().order('name');
    return [for (final row in rows) Association.fromJson(row)];
  }

  /// The approved manager of each association that has one.
  Future<Map<String, ManagerSummary>> fetchApprovedManagers() async {
    final rows = await _client
        .from('association_managers')
        .select('id, association_id, user_id')
        .eq('status', 'approved');
    final names = await _playerNames([
      for (final row in rows) row['user_id'] as String,
    ]);
    return {
      for (final row in rows)
        row['association_id'] as String: (
          managerId: row['id'] as String,
          userId: row['user_id'] as String,
          name: names[row['user_id']] ?? '?',
        ),
    };
  }

  /// My own claims and requests, whatever their status (to tell "pending"
  /// or "refused" on the association page).
  Future<List<AssociationManager>> fetchMyManagerRows() async {
    final rows = await _client
        .from('association_managers')
        .select('id, association_id, user_id, status, requested_at')
        .eq('user_id', _myUserId)
        .order('requested_at');
    return [for (final row in rows) AssociationManager.fromJson(row)];
  }

  /// My contact details as manager of [associationId], for the edit form.
  Future<ManagerContact?> fetchMyContact(String associationId) async {
    final manager = await _client
        .from('association_managers')
        .select('id')
        .eq('association_id', associationId)
        .eq('user_id', _myUserId)
        .eq('status', 'approved')
        .maybeSingle();
    if (manager == null) return null;
    final row = await _client
        .from('association_manager_contacts')
        .select()
        .eq('manager_id', manager['id'] as String)
        .maybeSingle();
    return row == null ? null : ManagerContact.fromJson(row);
  }

  /// Joins an approved association (Q79): the players guard refuses any
  /// other.
  Future<void> join(String associationId) => _client
      .from('players')
      .update({'association_id': associationId})
      .eq('user_id', _myUserId);

  /// Leaves my association (Q146): I'm back to no association, so I can't
  /// create sessions until I join one again.
  Future<void> leave() => _client
      .from('players')
      .update({'association_id': null})
      .eq('user_id', _myUserId);

  Future<Association> request(AssociationDraft draft) async {
    final row = await _client.rpc<Map<String, dynamic>>(
      'request_association',
      params: {'payload': _payload(draft)},
    );
    return Association.fromJson(row);
  }

  Future<void> claimManager({
    required String associationId,
    required String email,
    required String phone,
    String? message,
  }) => _client.rpc<void>(
    'claim_association_manager',
    params: {
      'p_association_id': associationId,
      'p_email': email,
      'p_phone': phone,
      'p_message': message,
    },
  );

  Future<void> update(String associationId, AssociationDraft draft) =>
      _client.rpc<void>(
        'update_association',
        params: {'p_association_id': associationId, 'payload': _payload(draft)},
      );

  /// Uploads a square logo (already cropped and resized) and points the
  /// association at it, then drops the previous one. A fresh file name each
  /// time, so no browser keeps showing the old image from its cache.
  Future<void> uploadLogo(Association association, Uint8List jpegBytes) async {
    final bucket = _client.storage.from('association-logos');
    final path = '${association.id}/${const Uuid().v4()}.jpg';
    await bucket.uploadBinary(
      path,
      jpegBytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg'),
    );
    await _client.rpc<void>(
      'update_association',
      params: {
        'p_association_id': association.id,
        'payload': {'logo_path': path},
      },
    );
    final previous = association.logoPath;
    if (previous != null) {
      // Best effort: the new logo is already in place.
      try {
        await bucket.remove([previous]);
      } on StorageException catch (error) {
        debugPrint('Previous logo not deleted: ${error.message}');
      }
    }
  }

  String logoUrl(String path) =>
      _client.storage.from('association-logos').getPublicUrl(path);

  /// Every creation request and claim awaiting review (super_admin only:
  /// the RLS hides other people's pending rows from anyone else).
  Future<List<PendingRequest>> fetchPendingRequests() async {
    final managerRows = await _client
        .from('association_managers')
        .select('id, association_id, user_id, status, requested_at')
        .eq('status', 'pending')
        .order('requested_at');
    if (managerRows.isEmpty) return const [];
    final managers = [
      for (final row in managerRows) AssociationManager.fromJson(row),
    ];

    final associationRows = await _client
        .from('associations')
        .select()
        .inFilter('id', {for (final m in managers) m.associationId}.toList());
    final associations = {
      for (final row in associationRows)
        row['id'] as String: Association.fromJson(row),
    };
    final contactRows = await _client
        .from('association_manager_contacts')
        .select()
        .inFilter('manager_id', [for (final m in managers) m.id]);
    final contacts = {
      for (final row in contactRows)
        row['manager_id'] as String: ManagerContact.fromJson(row),
    };
    final names = await _playerNames([for (final m in managers) m.userId]);

    return [
      for (final m in managers)
        if (associations[m.associationId] case final association?)
          (
            association: association,
            manager: m,
            contact: contacts[m.id],
            requesterName: names[m.userId] ?? '?',
            isCreation: association.status == AssociationStatus.pending,
          ),
    ];
  }

  Future<void> reviewAssociation(
    String associationId, {
    required bool approve,
  }) => _client.rpc<void>(
    'review_association',
    params: {'p_association_id': associationId, 'p_approve': approve},
  );

  Future<void> reviewManager(String managerId, {required bool approve}) =>
      _client.rpc<void>(
        'review_association_manager',
        params: {'p_manager_id': managerId, 'p_approve': approve},
      );

  /// Deletes an association (super_admin only, Q89) -- refused while it has
  /// sessions -- then, best effort, its logo files.
  Future<void> delete(String associationId) async {
    await _client.rpc<void>(
      'delete_association',
      params: {'p_association_id': associationId},
    );
    final bucket = _client.storage.from('association-logos');
    try {
      final files = await bucket.list(path: associationId);
      if (files.isNotEmpty) {
        await bucket.remove([
          for (final file in files) '$associationId/${file.name}',
        ]);
      }
    } on StorageException catch (error) {
      debugPrint('Association logos not deleted: ${error.message}');
    }
  }

  Future<void> revokeManager(String managerId) => _client.rpc<void>(
    'revoke_association_manager',
    params: {'p_manager_id': managerId},
  );

  Future<Map<String, String>> _playerNames(List<String> userIds) async {
    if (userIds.isEmpty) return const {};
    final rows = await _client
        .from('players')
        .select('user_id, name')
        .inFilter('user_id', userIds.toSet().toList());
    return {
      for (final row in rows) row['user_id'] as String: row['name'] as String,
    };
  }

  static Map<String, Object?> _payload(AssociationDraft draft) => {
    'name': ?draft.name,
    'short_name': ?draft.shortName,
    'city': ?draft.city,
    if (draft.lat != null && draft.lng != null)
      'location': {'lat': draft.lat, 'lng': draft.lng},
    'website_url': ?draft.websiteUrl,
    'email': ?draft.email,
    'phone': ?draft.phone,
    'message': ?draft.message,
  };
}

final associationsRepositoryProvider = Provider<AssociationsRepository>(
  (ref) => AssociationsRepository(ref.watch(supabaseClientProvider)),
);

@riverpod
Future<List<Association>> associations(Ref ref) =>
    ref.watch(associationsRepositoryProvider).fetchAll();

@riverpod
Future<Map<String, ManagerSummary>> associationManagers(Ref ref) =>
    ref.watch(associationsRepositoryProvider).fetchApprovedManagers();

@riverpod
Future<List<AssociationManager>> myManagerRows(Ref ref) =>
    ref.watch(associationsRepositoryProvider).fetchMyManagerRows();

@riverpod
Future<List<PendingRequest>> pendingRequests(Ref ref) =>
    ref.watch(associationsRepositoryProvider).fetchPendingRequests();

/// One association by id among those I can see, or null.
@riverpod
Future<Association?> associationById(Ref ref, String id) async {
  final all = await ref.watch(associationsProvider.future);
  for (final association in all) {
    if (association.id == id) return association;
  }
  return null;
}

/// My creation request still awaiting review, if any (Q81).
@riverpod
Future<Association?> myPendingRequest(Ref ref) async {
  final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  final all = await ref.watch(associationsProvider.future);
  for (final association in all) {
    if (association.createdBy == userId &&
        association.status == AssociationStatus.pending) {
      return association;
    }
  }
  return null;
}
