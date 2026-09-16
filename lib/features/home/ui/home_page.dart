import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/phosphor_icons.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_empty_state.dart';

/// Home tab body: "my live sessions, create, join" (plan 07+). Only
/// "create" (plan 07) is wired so far -- "Mes sessions en cours" and
/// "Rejoindre" are plan 09's full redesign of this page. Deliberately NOT
/// the NUNI/tagline branding block, which is the login page's alone (the
/// two are separate pages: a landing page before sign-in, a dashboard
/// after).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NuniEmptyState(
      icon: PhosphorIcons.golf,
      message: l10n.homeComingSoon,
      action: NuniButton(
        icon: PhosphorIcons.plus,
        label: l10n.homeCreateSessionAction,
        onPressed: () => context.push('/session/new'),
      ),
    );
  }
}
