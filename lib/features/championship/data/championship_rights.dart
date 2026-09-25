import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../associations/data/association_rights.dart';

part 'championship_rights.g.dart';

/// Whether the signed-in user may tag or untag a session of
/// [associationId] for the championship (plan 26, decision 11; plan 27): a
/// super_admin, that association's approved local manager or one of its
/// local admins. Only decides what the app shows -- the
/// `set_session_championship` RPC enforces it.
@riverpod
Future<bool> canTagChampionship(Ref ref, String associationId) =>
    ref.watch(canManageAssociationProvider(associationId).future);
