import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_legal_footer.dart';
import '../../../shared/nuni_logo.dart';
import '../data/auth_repository.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _signingIn = false;

  Future<void> _signIn() async {
    setState(() => _signingIn = true);
    try {
      // On success this navigates the whole page away to Google; it only
      // returns here (with an error) if the request itself failed.
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (error) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(describeError(error, l10n))));
      }
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

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
                  const SizedBox(height: 8),
                  Text(l10n.tagline, style: textTheme.titleLarge),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _signingIn ? null : _signIn,
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
