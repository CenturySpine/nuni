import 'session.dart';
import 'session_member.dart';

/// A session the current account is a member of, with its own role in it
/// ("Mes sessions en cours" / "Dernières sessions", plan 09) -- or, with a
/// null [role], a live session of its association it only follows (plan 26,
/// Q132), or a session a super_admin only sees as such ("Autres
/// sessions", plan 38), with its [creatorName].
class MySessionEntry {
  const MySessionEntry({
    required this.session,
    required this.role,
    this.creatorName,
  });

  final Session session;
  final MemberRole? role;

  /// Who created it, shown instead of the role on "Autres sessions" (plan
  /// 38, Q276): the role there would always read "En spectateur".
  final String? creatorName;
}
