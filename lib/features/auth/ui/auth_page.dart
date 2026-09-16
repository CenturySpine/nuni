import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/google_logo.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_legal_footer.dart';
import '../../../shared/nuni_logo.dart';
import '../data/auth_repository.dart';

/// Sign-in / sign-up screen (plan 05), styled after Vercel's own auth pages
/// (PO reference, 2026-09-16): brand top-left, a link to the other page
/// top-right, the provider choice as its own cartouche. Google is the only
/// provider for now (password auth is a later plan) and both routes do the
/// exact same thing -- `signInWithOAuth` creates the account on first use --
/// so one widget serves `/login` and `/signup`, differing only in heading
/// and which way the top-right link points.
class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key, required this.isSignUp});

  final bool isSignUp;

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  const NuniLogo(size: 32),
                  const SizedBox(width: 8),
                  Text(l10n.tagline, style: textTheme.titleLarge),
                  const Spacer(),
                  NuniButton(
                    variant: NuniButtonVariant.secondary,
                    label: widget.isSignUp
                        ? l10n.authSwitchToLogin
                        : l10n.authSwitchToSignUp,
                    onPressed: () =>
                        context.go(widget.isSignUp ? '/login' : '/signup'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.isSignUp
                              ? l10n.authSignUpHeading
                              : l10n.authLoginHeading,
                          style: textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: NuniCard(
                            onTap: _signingIn ? null : _signIn,
                            child: Row(
                              children: [
                                const GoogleLogo(size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.authContinueWithGoogle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: NuniLegalFooter(),
            ),
          ],
        ),
      ),
    );
  }
}
