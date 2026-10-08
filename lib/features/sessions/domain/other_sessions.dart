import 'session.dart';

/// A super_admin's "Autres sessions" on home (plan 38, Q274): out of
/// [sessions], the ones not completed that home doesn't show already --
/// neither one I'm a member of ([memberSessionIds]) nor a live one of my
/// association ([myAssociationId]), which I follow among mine (plan 26,
/// Q132). Most recently created first. Completed ones are the history's.
List<Session> otherSessionsForHome(
  Iterable<Session> sessions, {
  required Set<String> memberSessionIds,
  required String? myAssociationId,
}) => [
  for (final session in sessions)
    if (session.status != SessionStatus.completed &&
        !memberSessionIds.contains(session.id) &&
        !(session.status == SessionStatus.live &&
            myAssociationId != null &&
            session.associationId == myAssociationId))
      session,
]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
