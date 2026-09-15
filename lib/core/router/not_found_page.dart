import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/phosphor_icons.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../shared/nuni_empty_state.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notFoundTitle)),
      body: NuniEmptyState(
        icon: PhosphorIcons.signpost,
        message: l10n.notFoundMessage,
        action: FilledButton(
          onPressed: () => context.go('/'),
          child: Text(l10n.notFoundAction),
        ),
      ),
    );
  }
}
