import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/router/app_bottom_nav.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../core/weather/weather_icon.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_confirm_dialog.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_grouped_list.dart';
import '../../../shared/nuni_icon_tile.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_rank_badge.dart';
import '../../../shared/nuni_section_header.dart';
import '../../../shared/nuni_status_pill.dart';
import '../../championship/domain/championship_session_result.dart';
import '../../exports/ui/image_export_dialog.dart';
import '../../exports/ui/pdf_export_action.dart';
import '../../live/domain/live_team.dart';
import '../../live/domain/team_standing.dart';
import '../../live/ui/played_hole_card.dart';
import '../../live/ui/ranking_card.dart';
import '../../sessions/data/sessions_repository.dart';
import '../../sessions/ui/scoring_mode_label.dart';
import '../data/history_repository.dart';
import '../domain/history_entry.dart';
import 'photo_gallery.dart';
import 'session_edit_sheet.dart';

/// `/history/:id` (plan 10): the same components as the live screen
/// (`RankingCard`, `PlayedHoleCard`), read-only, plus the gallery and the
/// creator's actions -- reusing plan 08's widgets rather than rebuilding an
/// equivalent read-only pair from scratch.
class HistoryDetailPage extends ConsumerWidget {
  const HistoryDetailPage({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final detailAsync = ref.watch(historyDetailProvider(sessionId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyDetailTitle)),
      body: detailAsync.when(
        loading: () => const NuniLoading(),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: NuniErrorBanner(
            message: describeError(error, l10n),
            onRetry: () => ref.invalidate(historyDetailProvider(sessionId)),
          ),
        ),
        data: (entry) => entry == null
            ? NuniEmptyState(
                icon: PhosphorIcons.warningCircle,
                message: l10n.sessionsLiveDeletedMessage,
              )
            : _DetailView(sessionId: sessionId, entry: entry),
      ),
      // Always a way back to the tabs (PO, 2026-09-23): this page is also
      // reached straight from a session that just ended.
      bottomNavigationBar: const NuniStandaloneBottomNav(selectedIndex: 2),
    );
  }
}

class _DetailView extends ConsumerWidget {
  const _DetailView({required this.sessionId, required this.entry});

  final String sessionId;
  final HistoryEntry entry;

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    await showSessionEditSheet(context, entry.snapshot.session);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await NuniConfirmDialog.show(
      context,
      title: l10n.sessionsRoomDeleteConfirmTitle,
      message: l10n.sessionsRoomDeleteConfirmMessage,
      confirmLabel: l10n.commonDelete,
      danger: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final photos = await ref.read(sessionPhotosProvider(sessionId).future);
      await ref
          .read(historyRepositoryProvider)
          .deleteSessionWithPhotos(sessionId: sessionId, photos: photos);
      ref.invalidate(historyEntriesProvider);
      // Home's "en cours" / "dernières sessions" lists are separate
      // providers (PO, 2026-09-18: a session deleted from history kept
      // showing there) -- they don't refresh on their own just because
      // history's list did.
      ref.invalidate(myOngoingSessionsProvider);
      ref.invalidate(myRecentSessionsProvider);
      if (context.mounted) context.go('/history');
    } catch (error) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(describeError(error, l10n))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = entry.snapshot.session;
    final locale = Localizations.localeOf(context).toString();
    final currentUserId = ref
        .watch(supabaseClientProvider)
        .auth
        .currentUser
        ?.id;
    final isOwner = entry.snapshot.isOwner(currentUserId);
    final playedHoles = entry.snapshot.playedHoles;

    final subtitleParts = [
      if (session.city != null && session.city!.isNotEmpty) session.city!,
      if (session.zone != null && session.zone!.isNotEmpty) session.zone!,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        Text(
          subtitleParts.isEmpty ? session.code : subtitleParts.join(' · '),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (session.startedAt != null) ...[
          const SizedBox(height: 2),
          Text(
            DateFormat.yMMMMd(locale)
                .add_Hm()
                .format(session.startedAt!.toLocal()),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            NuniStatusPill(label: scoringModeLabel(l10n, session.scoringMode)),
            if (session.isChampionship)
              NuniStatusPill(
                label: l10n.championshipTitle,
                icon: PhosphorIcons.crown,
                tone: NuniTone.sunshine,
              ),
            if (session.weather != null)
              NuniStatusPill(
                label: '${session.weather!.temperatureC.round()}°C',
                icon: weatherIcon(session.weather!.code),
                tone: NuniTone.neutral,
              ),
          ],
        ),
        if (session.comment != null && session.comment!.isNotEmpty) ...[
          const SizedBox(height: 14),
          NuniCard(
            color: context.nuni.surfaceMuted,
            child: Text(
              session.comment!,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
        const SizedBox(height: 20),
        RankingCard(
          session: session,
          teams: entry.snapshot.teams,
          playedHoles: playedHoles,
        ),
        if (session.isChampionship) ...[
          const SizedBox(height: 12),
          _ChampionshipPointsCard(
            teams: entry.snapshot.teams,
            standings: entry.standings,
          ),
        ],
        if (playedHoles.isNotEmpty) ...[
          const SizedBox(height: 28),
          NuniSectionHeader(
            title: l10n.navHoles,
            trailing: NuniStatusPill(
              label: '${playedHoles.length}',
              tone: NuniTone.neutral,
            ),
          ),
        ],
        for (final playedHole in playedHoles)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PlayedHoleCard(
              playedHole: playedHole,
              teams: entry.snapshot.teams,
              scoringMode: session.scoringMode,
              canEditTeam: (_) => false,
              onScoreSubmit: (_, _, _) async {},
            ),
          ),
        const SizedBox(height: 18),
        PhotoGallery(
          sessionId: sessionId,
          isOwner: isOwner,
          coverPhotoId: session.coverPhotoId,
        ),
        const SizedBox(height: 28),
        NuniGroupedList(
          children: [
            _ActionTile(
              icon: PhosphorIcons.filePdf,
              label: l10n.historyExportPdfAction,
              onTap: () => exportSessionPdf(
                context,
                entry,
                photoUrl: ref.read(historyRepositoryProvider).photoUrl,
              ),
            ),
            _ActionTile(
              icon: PhosphorIcons.imageSquare,
              label: l10n.historyExportImageAction,
              onTap: () => showImageExportDialog(context, entry),
            ),
            if (isOwner) ...[
              _ActionTile(
                icon: PhosphorIcons.pencilSimple,
                label: l10n.historyEditAction,
                onTap: () => _edit(context, ref),
              ),
              _ActionTile(
                icon: PhosphorIcons.trash,
                label: l10n.sessionsRoomDeleteSession,
                tone: NuniTone.danger,
                onTap: () => _delete(context, ref),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// One row of the actions list at the bottom of the page; a [NuniTone.danger]
/// row also gets red text.
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tone = NuniTone.primary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final NuniTone tone;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: NuniIconTile(icon: icon, tone: tone, size: 36),
      title: Text(
        label,
        style: tone == NuniTone.danger
            ? TextStyle(color: context.nuni.danger.onContainer)
            : null,
      ),
      trailing: const Icon(PhosphorIcons.caretRight, size: 18),
      onTap: onTap,
    );
  }
}

/// Championship points earned this session (plan 15, parcours 4), per team
/// -- every teammate of a Team-mode session earns identically (Q43), so a
/// per-team line already shows each player's own total. Ranking points
/// alone come from the same [TeamStanding] the ranking card above already
/// computed; the fixed attendance point is added here.
class _ChampionshipPointsCard extends StatelessWidget {
  const _ChampionshipPointsCard({required this.teams, required this.standings});

  final List<LiveTeam> teams;
  final List<TeamStanding> standings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rankingPoints = sessionRankingPoints(standings);
    final teamById = {for (final t in teams) t.id: t};
    final ordered = [...standings]
      ..sort((a, b) => a.position.compareTo(b.position));

    return NuniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const NuniIconTile(
                icon: PhosphorIcons.crown,
                tone: NuniTone.sunshine,
                size: 36,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.championshipPointsCardTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final standing in ordered)
            if (teamById[standing.teamId] case final team?)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    NuniRankBadge(
                      label: '${standing.position}',
                      position: standing.position,
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(team.playerNames())),
                    Text(
                      l10n.championshipPointsValue(
                        (rankingPoints[team.id] ?? 0) +
                            championshipAttendancePoints,
                      ),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
