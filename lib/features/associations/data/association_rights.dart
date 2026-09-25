import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/authorization/authorization_repository.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../profile/data/profile_repository.dart';
import 'associations_repository.dart';

part 'association_rights.g.dart';

/// Whether the signed-in user runs [associationId] day to day (plan 27): a
/// super_admin, its approved local manager, or one of its local admins --
/// championship tagging and the planning's moderation, import and "start
/// the session". Editing the association itself stays the manager's and the
/// super_admin's. Only decides what the app shows: the base's
/// `is_association_staff` enforces the same rule.
@riverpod
Future<bool> canManageAssociation(Ref ref, String associationId) async {
  if (await ref.watch(isSuperAdminProvider.future)) return true;
  final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) return false;
  final managers = await ref.watch(associationManagersProvider.future);
  if (managers[associationId]?.userId == userId) return true;
  final admins = await ref.watch(associationAdminsProvider.future);
  final player = await ref.watch(myPlayerProvider.future);
  return admins[associationId]?.contains(player.id) ?? false;
}
