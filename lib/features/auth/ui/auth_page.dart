import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/google_logo.dart';
import '../../../shared/nuni_hero.dart';
import '../../../shared/nuni_legal_footer.dart';
import '../../../shared/nuni_logo.dart';
import '../data/auth_repository.dart';

/// Sign-in / sign-up screen (plan 05): the brand hero on top, then the
/// heading, the provider button and the link to the other page. Google is the only
/// provider for now (password auth is a later plan) and both routes do the
/// exact same thing -- `signInWithOAuth` creates the account on first use --
/// so one widget serves `/login` and `/signup`, differing only in heading
/// and which way the switch link points.
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final onHero = theme.colorScheme.onPrimary;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        NuniHero(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                          borderRadius: BorderRadius.circular(NuniRadius.sheet),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: onHero.withValues(alpha: 0.35),
                                    width: 2,
                                  ),
                                ),
                                child: const NuniLogo(size: 68),
                              ),
                              const SizedBox(height: 56),
                              Text(
                                l10n.appTitle,
                                style: textTheme.displaySmall?.copyWith(
                                  color: onHero,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.tagline,
                                style: textTheme.titleMedium?.copyWith(
                                  color: onHero.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.authHeroSubtitle,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: onHero,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 32),
                        Text(
                          widget.isSignUp
                              ? l10n.authSignUpHeading
                              : l10n.authLoginHeading,
                          style: textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        // Google's branding guidelines: white button, the
                        // unmodified G mark, neutral outline.
                        OutlinedButton(
                          onPressed: _signingIn ? null : _signIn,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_signingIn)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                )
                              else
                                const GoogleLogo(size: 20),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  l10n.authContinueWithGoogle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              widget.isSignUp
                                  ? l10n.authSwitchPromptToLogin
                                  : l10n.authSwitchPromptToSignUp,
                              style: textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go(
                                widget.isSignUp ? '/login' : '/signup',
                              ),
                              child: Text(
                                widget.isSignUp
                                    ? l10n.authSwitchToLogin
                                    : l10n.authSwitchToSignUp,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(height: 16),
                        const NuniLegalFooter(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
