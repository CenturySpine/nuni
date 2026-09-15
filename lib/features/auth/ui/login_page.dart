import 'package:flutter/material.dart';

import '../../../core/theme/phosphor_icons.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_legal_footer.dart';
import '../../../shared/nuni_logo.dart';

/// Sign-in screen. Google sign-in itself is wired in plan 05; the button is
/// disabled until then.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  const NuniLogo(size: 96),
                  const SizedBox(height: 16),
                  Text(l10n.appTitle, style: textTheme.headlineMedium),
                  Text(l10n.tagline, style: textTheme.titleLarge),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: null,
                    icon: const Icon(PhosphorIcons.googleLogo),
                    label: Text(l10n.loginSignInWithGoogle),
                  ),
                  const Spacer(),
                  const NuniLegalFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
