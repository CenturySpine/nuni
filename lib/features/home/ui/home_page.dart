import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_hero.dart';
import '../../../shared/nuni_icon_tile.dart';
import '../../../shared/nuni_list_card.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_section_header.dart';
import '../../../shared/nuni_status_pill.dart';
import '../../championship/ui/championship_home_card.dart';
import '../../join/ui/join_by_code_sheet.dart';
import '../../sessions/data/sessions_repository.dart';
import '../../sessions/domain/my_session_entry.dart';
import '../../sessions/domain/session.dart';
import '../../sessions/domain/session_kind.dart';
import '../../sessions/domain/session_member.dart';
import '../../sessions/ui/session_kind_label.dart';

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
    // (title, settings action) for all three bottom-nav tabs. Pull to
    // refresh (plan 26): the association's live sessions start and end
    // without any action of mine, so the list can't know on its own.
    return RefreshIndicator(
      onRefresh: () async {
        ref
          ..invalidate(myOngoingSessionsProvider)
          ..invalidate(myRecentSessionsProvider)
          ..invalidate(associationLiveSessionsProvider);
        await ref.read(associationLiveSessionsProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _HeroBanner(onJoin: () => _join(context)),
          const SizedBox(height: 28),
          const ChampionshipHomeSection(),
          _SessionSection(
            title: l10n.homeSectionOngoing,
            emptyMessage: l10n.homeOngoingEmpty,
            entries: _withAssociationLive(
              ref.watch(myOngoingSessionsProvider),
              ref.watch(associationLiveSessionsProvider),
            ),
          ),
          const SizedBox(height: 28),
          _SessionSection(
            title: l10n.homeSectionRecent,
            emptyMessage: l10n.homeRecentEmpty,
            entries: ref.watch(myRecentSessionsProvider),
          ),
        ],
      ),
    );
  }
}

/// My ongoing sessions, then my association's live ones I only follow (plan
/// 26, Q132) -- the latter left out while loading or on error, so they never
/// hold up or break my own list.
AsyncValue<List<MySessionEntry>> _withAssociationLive(
  AsyncValue<List<MySessionEntry>> mine,
  AsyncValue<List<Session>> association,
) => mine.whenData(
  (list) => [
    ...list,
    for (final session in association.value ?? const <Session>[])
      MySessionEntry(session: session, role: null),
  ],
);

/// The brand banner at the top of home, holding its two main actions.
class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onJoin});

  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final onHero = Theme.of(context).colorScheme.onPrimary;

    return NuniHero(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeHeroTitle,
            style: textTheme.headlineMedium?.copyWith(color: onHero),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(right: 64),
            child: Text(
              l10n.homeHeroSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: onHero.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Stacked full-width: side by side, "Créer une session" was cut
          // off on a phone.
          SizedBox(
            width: double.infinity,
            child: NuniButton(
              variant: NuniButtonVariant.onHero,
              icon: PhosphorIcons.plus,
              label: l10n.homeCreateSessionAction,
              onPressed: () => context.push('/session/new'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: NuniButton(
              variant: NuniButtonVariant.onHeroSecondary,
              icon: PhosphorIcons.signIn,
              label: l10n.homeJoinAction,
              onPressed: onJoin,
            ),
          ),
        ],
      ),
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
    final count = entries.asData?.value.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NuniSectionHeader(
          title: title,
          trailing: count == 0
              ? null
              : NuniStatusPill(label: '$count', tone: NuniTone.neutral),
        ),
        entries.when(
          data: (list) => list.isEmpty
              ? SizedBox(
                  width: double.infinity,
                  child: NuniCard(
                    child: Text(
                      emptyMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (final entry in list) ...[
                      _SessionCard(entry: entry),
                      const SizedBox(height: 10),
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

    // No status for a completed session (PO, 2026-09-23): it only ever
    // appears under "recent sessions", where it can only be finished.
    final status = switch (session.status) {
      SessionStatus.draft => NuniStatusPill(
        label: l10n.homeSessionStatusDraft,
        tone: NuniTone.highlight,
      ),
      SessionStatus.live => NuniStatusPill(
        label: l10n.homeSessionStatusLive,
        tone: NuniTone.fairway,
        dot: true,
      ),
      SessionStatus.completed => null,
    };
    final roleLabel = switch (entry.role) {
      MemberRole.owner => l10n.homeRoleOwner,
      MemberRole.player => l10n.homeRolePlayer,
      null => l10n.homeRoleSpectator,
    };
    final isTeam = session.kind == SessionKind.team;

    return NuniListCard(
      onTap: () => context.push(
        session.status == SessionStatus.completed
            ? '/history/${session.id}'
            : '/session/${session.id}',
      ),
      leading: NuniIconTile(
        icon: isTeam ? PhosphorIcons.users : PhosphorIcons.golf,
        tone: isTeam ? NuniTone.primary : NuniTone.fairway,
      ),
      title: session.city ?? session.code,
      badge: status,
      subtitle: [
        sessionKindLabel(l10n, session.kind),
        roleLabel,
        DateFormat.yMMMd(locale).format(date),
      ].join(' · '),
    );
  }
}
