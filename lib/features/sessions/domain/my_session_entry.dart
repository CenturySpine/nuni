import 'session.dart';
import 'session_member.dart';

/// A session the current account is a member of, with its own role in it
/// ("Mes sessions en cours" / "Dernières sessions", plan 09).
class MySessionEntry {
  const MySessionEntry({required this.session, required this.role});

  final Session session;
  final MemberRole role;
}
