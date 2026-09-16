import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_loading.dart';
import '../../join/ui/join_by_code_sheet.dart';
import '../../sessions/data/sessions_repository.dart';
import '../../sessions/domain/my_session_entry.dart';
import '../../sessions/domain/session.dart';
import '../../sessions/domain/session_kind.dart';
import '../../sessions/domain/session_member.dart';

/// Home tab body (plan 09): create, join, my ongoing sessions, recent
/// sessions. Full history (beyond the short "Dernières sessions" list)
/// stays the History tab's job (plan 10).
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _join(BuildContext context) async {
    final code = await showJoinByCodeSheet(context);
    if (code != null && context.mounted) {
      context.push('/join/${code.toUpperCase()}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // No own Scaffold/AppBar: AppShell already provides the shared one
    // (title, settings action) for all three bottom-nav tabs.
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: NuniButton(
                icon: PhosphorIcons.plus,
                label: l10n.homeCreateSessionAction,
                onPressed: () => context.push('/session/new'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NuniButton(
                variant: NuniButtonVariant.secondary,
                icon: PhosphorIcons.signIn,
                label: l10n.homeJoinAction,
                onPressed: () => _join(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SessionSection(
          title: l10n.homeSectionOngoing,
          emptyMessage: l10n.homeOngoingEmpty,
          entries: ref.watch(myOngoingSessionsProvider),
        ),
        const SizedBox(height: 24),
        _SessionSection(
          title: l10n.homeSectionRecent,
          emptyMessage: l10n.homeRecentEmpty,
          entries: ref.watch(myRecentSessionsProvider),
        ),
      ],
    );
  }
}

class _SessionSection extends StatelessWidget {
  const _SessionSection({
    required this.title,
    required this.emptyMessage,
    required this.entries,
  });

  final String title;
  final String emptyMessage;
  final AsyncValue<List<MySessionEntry>> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        entries.when(
          data: (list) => list.isEmpty
              ? NuniCard(child: Text(emptyMessage))
              : Column(
                  children: [
                    for (final entry in list) ...[
                      _SessionCard(entry: entry),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: NuniLoading(),
          ),
          error: (error, _) =>
              NuniErrorBanner(message: describeError(error, l10n)),
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.entry});

  final MySessionEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = entry.session;
    final locale = Localizations.localeOf(context).toString();
    final date = session.startedAt ?? session.createdAt;

    final statusLabel = switch (session.status) {
      SessionStatus.draft => l10n.homeSessionStatusDraft,
      SessionStatus.live => l10n.homeSessionStatusLive,
      SessionStatus.completed => l10n.homeSessionStatusCompleted,
    };
    final roleLabel = entry.role == MemberRole.owner
        ? l10n.homeRoleOwner
        : l10n.homeRolePlayer;

    return NuniCard(
      onTap: () => context.push('/session/${session.id}'),
      child: Row(
        children: [
          Icon(
            session.kind == SessionKind.team
                ? PhosphorIcons.users
                : PhosphorIcons.golf,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.city ?? session.code,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '$statusLabel · $roleLabel · ${DateFormat.yMMMd(locale).format(date)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(PhosphorIcons.caretRight),
        ],
      ),
    );
  }
}
