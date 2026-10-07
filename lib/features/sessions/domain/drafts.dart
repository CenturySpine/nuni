import 'session.dart';

/// The drafts offered when creating a session (plan 37, Q258), out of
/// [drafts], the ones the caller organizes: still unpublished and in their
/// waiting room; started from an event, only those of the event's
/// association ([eventAssociationId]), which an event's session always
/// belongs to. Most recently created first.
List<Session> offerableDrafts(
  List<Session> drafts, {
  String? eventAssociationId,
}) => [
  for (final session in drafts)
    if (!session.published &&
        session.status == SessionStatus.draft &&
        (eventAssociationId == null ||
            session.associationId == eventAssociationId))
      session,
]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
