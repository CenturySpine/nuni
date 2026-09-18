import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../core/weather/weather_icon.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_confirm_dialog.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_loading.dart';
import '../../exports/ui/image_export_dialog.dart';
import '../../exports/ui/pdf_export_action.dart';
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

    final subtitleParts = [
      if (session.city != null && session.city!.isNotEmpty) session.city!,
      if (session.zone != null && session.zone!.isNotEmpty) session.zone!,
      if (session.startedAt != null)
        DateFormat.yMMMd(locale).add_Hm().format(session.startedAt!.toLocal()),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          subtitleParts.isEmpty ? session.code : subtitleParts.join(' · '),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Row(
          children: [
            Text(
              scoringModeLabel(l10n, session.scoringMode),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (session.weather != null) ...[
              const SizedBox(width: 12),
              Icon(
                weatherIcon(session.weather!.code),
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${session.weather!.temperatureC.round()}°C',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        if (session.comment != null && session.comment!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(session.comment!, style: Theme.of(context).textTheme.bodyMedium),
        ],
        const SizedBox(height: 16),
        RankingCard(
          session: session,
          teams: entry.snapshot.teams,
          playedHoles: entry.snapshot.playedHoles,
        ),
        const SizedBox(height: 16),
        for (final playedHole in entry.snapshot.playedHoles)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PlayedHoleCard(
              playedHole: playedHole,
              teams: entry.snapshot.teams,
              scoringMode: session.scoringMode,
              canEditTeam: (_) => false,
              playerNameForUserId: (userId) =>
                  entry.snapshot.memberFor(userId)?.playerName,
              onScoreSubmit: (_, _, _) async {},
            ),
          ),
        const SizedBox(height: 8),
        PhotoGallery(
          sessionId: sessionId,
          isOwner: isOwner,
          coverPhotoId: session.coverPhotoId,
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => exportSessionPdf(
                context,
                entry,
                photoUrl: ref.read(historyRepositoryProvider).photoUrl,
              ),
              icon: const Icon(PhosphorIcons.filePdf),
              label: Text(l10n.historyExportPdfAction),
            ),
            OutlinedButton.icon(
              onPressed: () => showImageExportDialog(context, entry),
              icon: const Icon(PhosphorIcons.imageSquare),
              label: Text(l10n.historyExportImageAction),
            ),
            if (isOwner) ...[
              OutlinedButton.icon(
                onPressed: () => _edit(context, ref),
                icon: const Icon(PhosphorIcons.pencilSimple),
                label: Text(l10n.historyEditAction),
              ),
              OutlinedButton.icon(
                onPressed: () => _delete(context, ref),
                icon: Icon(
                  PhosphorIcons.trash,
                  color: Theme.of(context).colorScheme.error,
                ),
                label: Text(
                  l10n.sessionsRoomDeleteSession,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
