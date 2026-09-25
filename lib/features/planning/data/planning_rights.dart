import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../associations/data/association_rights.dart';
import '../../profile/data/profile_repository.dart';
import '../domain/event.dart';
import '../domain/planning.dart';

part 'planning_rights.g.dart';

/// What the signed-in user may do with an event (plan 23). Only decides what
/// the app shows: RLS and the base's triggers enforce the same rules.
class EventRights {
  const EventRights({
    required this.canManage,
    required this.canModerate,
    required this.canStartSession,
  });

  /// Edit and delete (Q151, Q161): creator, person in charge, local manager or
  /// admins, super_admin.
  final bool canManage;

  /// Delete anyone's comment, import an agenda: local manager or admins,
  /// super_admin.
  final bool canModerate;

  /// "Start the session" (Q164): on the event's day, for its person in
  /// charge, the local manager or admins, a super_admin.
  final bool canStartSession;
}

/// Whether the user is [associationId]'s local manager or admin, or a
/// super_admin (plan 27) -- the same people who tag the championship.
@riverpod
Future<bool> canModeratePlanning(Ref ref, String associationId) =>
    ref.watch(canManageAssociationProvider(associationId).future);

@riverpod
Future<EventRights> eventRights(Ref ref, Event event) async {
  final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  final player = await ref.watch(myPlayerProvider.future);
  final moderator = await ref.watch(
    canModeratePlanningProvider(event.associationId).future,
  );
  final inCharge =
      event.managerPlayerId != null && event.managerPlayerId == player.id;
  return EventRights(
    canManage: moderator || inCharge || event.createdBy == userId,
    canModerate: moderator,
    canStartSession:
        (moderator || inCharge) && isEventToday(event, DateTime.now()),
  );
}
