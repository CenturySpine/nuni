import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/authorization/authorization_repository.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../associations/data/associations_repository.dart';

part 'championship_rights.g.dart';

/// Whether the signed-in user may tag or untag a session of
/// [associationId] for the championship (plan 26, decision 11): a
/// super_admin, or that association's approved local manager. Only decides
/// what the app shows -- the `set_session_championship` RPC enforces it.
@riverpod
Future<bool> canTagChampionship(Ref ref, String associationId) async {
  if (await ref.watch(isSuperAdminProvider.future)) return true;
  final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) return false;
  final managers = await ref.watch(associationManagersProvider.future);
  return managers[associationId]?.userId == userId;
}
