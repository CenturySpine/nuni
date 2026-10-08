import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/authorization/authorization_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_alert_banner.dart';
import '../domain/session_member.dart';

/// The red banner of a session screen (plan 38, Q277): shown to a
/// super_admin who doesn't take part in the session ([isMember] false),
/// whatever they came for, reading or changing it; nothing for anyone else.
/// [padding] places it in the screen's layout when shown.
class SuperAdminOutsiderBanner extends ConsumerWidget {
  const SuperAdminOutsiderBanner({
    super.key,
    required this.isMember,
    this.padding = EdgeInsets.zero,
  });

  final bool isMember;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shown = isSuperAdminOutsider(
      isMember: isMember,
      isSuperAdmin: ref.watch(isSuperAdminProvider).value ?? false,
    );
    if (!shown) return const SizedBox.shrink();
    return Padding(
      padding: padding,
      child: NuniAlertBanner(
        message: AppLocalizations.of(context)!.superAdminOutsiderBanner,
      ),
    );
  }
}
