import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/router/app_bottom_nav.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_confirm_dialog.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_menu_row.dart';
import '../../sessions/data/sessions_repository.dart';
import '../../sessions/domain/ranking_direction.dart';
import '../../sessions/domain/scoring_mode.dart';
import '../../sessions/domain/session.dart';
import '../../sessions/ui/invite_sheet.dart';
import '../../sessions/ui/scoring_mode_label.dart';
import '../data/live_repository.dart';
import '../domain/live_session_snapshot.dart';
import 'add_played_hole_sheet.dart';
import 'members_sheet.dart';
import 'played_hole_card.dart';
import 'ranking_card.dart';

/// The live screen (plan 08): shown by `SessionRoomPage` once `status` has
/// left `draft`. Owns both the in-progress view (`status = live`) and the
/// wrap-up view (`status = completed`) -- a realtime event on `sessions`
/// switches between the two without navigating anywhere.
class SessionLivePage extends ConsumerWidget {
  const SessionLivePage({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // `watchSession`'s stream surfaces a deleted session as an error (Q36's
    // "reload the whole snapshot" pattern can't just keep showing stale
    // data here the way the waiting room does -- plan 08 explicitly wants
    // members told the session is gone). `ref.listen` fires once per
    // transition, not on every rebuild, so the snackbar+redirect only
    // happens once.
    ref.listen<AsyncValue<LiveSessionSnapshot>>(
      liveSessionProvider(sessionId),
      (previous, next) {
        if (next case AsyncError(:final error)
            when error is LiveSessionDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.sessionsLiveDeletedMessage)),
          );
          context.go('/');
        }
      },
    );

    final liveAsync = ref.watch(liveSessionProvider(sessionId));

    return liveAsync.when(
      loading: () => const Scaffold(
        body: NuniLoading(),
        bottomNavigationBar: NuniStandaloneBottomNav(),
      ),
      error: (error, _) {
        if (error is LiveSessionDeleted) {
          return const Scaffold(
            body: NuniLoading(),
            bottomNavigationBar: NuniStandaloneBottomNav(),
          );
        }
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: NuniErrorBanner(
              message: describeError(error, l10n),
              onRetry: () => ref.invalidate(liveSessionProvider(sessionId)),
            ),
          ),
          bottomNavigationBar: const NuniStandaloneBottomNav(),
        );
      },
      data: (snapshot) {
        // No wrap-up screen of its own (PO, 2026-09-18): the moment a
        // session completes -- already on load, or via this realtime
        // snapshot switching status under the user's feet -- its recap
        // IS the history detail page, so go straight there instead of an
        // intermediate "session terminée" screen with a button to it.
        if (snapshot.session.status == SessionStatus.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/history/${snapshot.session.id}');
          });
          return const Scaffold(
            body: NuniLoading(),
            bottomNavigationBar: NuniStandaloneBottomNav(),
          );
        }
        return _LiveView(sessionId: sessionId, snapshot: snapshot);
      },
    );
  }
}

enum _MenuAction { members, end, delete }

class _LiveView extends ConsumerStatefulWidget {
  const _LiveView({required this.sessionId, required this.snapshot});

  final String sessionId;
  final LiveSessionSnapshot snapshot;

  @override
  ConsumerState<_LiveView> createState() => _LiveViewState();
}

class _LiveViewState extends ConsumerState<_LiveView> {
  bool _busy = false;

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      await action();
    } catch (error) {
      _showSnack(describeError(error, l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitScore(String playedHoleId, String teamId, int value) =>
      _run(
        () => ref
            .read(liveRepositoryProvider)
            .upsertScore(
              playedHoleId: playedHoleId,
              teamId: teamId,
              value: value,
            ),
      );

  Future<void> _deleteHole(String playedHoleId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await NuniConfirmDialog.show(
      context,
      title: l10n.sessionsLiveDeleteHoleConfirmTitle,
      message: l10n.sessionsLiveDeleteHoleConfirmMessage,
      confirmLabel: l10n.commonDelete,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    await _run(
      () => ref.read(liveRepositoryProvider).deletePlayedHole(playedHoleId),
    );
  }

  Future<void> _endSession() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await NuniConfirmDialog.show(
      context,
      title: l10n.sessionsLiveEndConfirmTitle,
      message: l10n.sessionsLiveEndConfirmMessage,
      confirmLabel: l10n.sessionsLiveEndSession,
    );
    if (!confirmed || !mounted) return;
    await _run(
      () => ref.read(liveRepositoryProvider).closeSession(widget.sessionId),
    );
  }

  Future<void> _deleteSession() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await NuniConfirmDialog.show(
      context,
      title: l10n.sessionsRoomDeleteConfirmTitle,
      message: l10n.sessionsRoomDeleteConfirmMessage,
      confirmLabel: l10n.commonDelete,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      // Deletion drops this member's own access via RLS the moment it
      // commits, so the live snapshot stream may never deliver the "it's
      // gone" signal to the person who just triggered it -- navigate away
      // explicitly instead of waiting for it, same reasoning as the
      // waiting room's own `_delete`.
      await ref
          .read(sessionsRepositoryProvider)
          .deleteSession(widget.sessionId);
      if (mounted) context.go('/');
    } catch (error) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showSnack(describeError(error, l10n));
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final snapshot = widget.snapshot;
    final session = snapshot.session;
    final currentUserId = ref
        .watch(supabaseClientProvider)
        .auth
        .currentUser
        ?.id;
    final isOwner = snapshot.isOwner(currentUserId);
    final myTeamId = snapshot.myTeamId(currentUserId);
    final locale = Localizations.localeOf(context).toString();

    final subtitleParts = [
      if (session.city != null && session.city!.isNotEmpty) session.city!,
      if (session.zone != null && session.zone!.isNotEmpty) session.zone!,
      if (session.startedAt != null)
        DateFormat.yMMMd(locale).format(session.startedAt!),
    ];
    var scoringLine = scoringModeLabel(l10n, session.scoringMode);
    if (session.scoringMode == ScoringMode.free) {
      scoringLine +=
          ' · ${session.rankingDirection == RankingDirection.desc ? l10n.sessionsCreateFreeDirectionHighest : l10n.sessionsCreateFreeDirectionLowest}';
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitleParts.isEmpty ? session.code : subtitleParts.join(' · '),
            ),
            Text(scoringLine, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIcons.shareNetwork),
            tooltip: l10n.sessionsInviteTitle,
            onPressed: () => InviteSheet.show(context, session.code),
          ),
          if (isOwner)
            PopupMenuButton<_MenuAction>(
              onSelected: (action) => switch (action) {
                _MenuAction.members => showMembersSheet(
                  context,
                  sessionId: widget.sessionId,
                  members: snapshot.members,
                ),
                _MenuAction.end => _endSession(),
                _MenuAction.delete => _deleteSession(),
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _MenuAction.members,
                  child: NuniMenuRow(
                    icon: PhosphorIcons.users,
                    label: l10n.sessionsLiveMembersAction,
                  ),
                ),
                PopupMenuItem(
                  value: _MenuAction.end,
                  child: NuniMenuRow(
                    icon: PhosphorIcons.checkCircle,
                    label: l10n.sessionsLiveEndSession,
                  ),
                ),
                PopupMenuItem(
                  value: _MenuAction.delete,
                  child: NuniMenuRow(
                    icon: PhosphorIcons.trash,
                    label: l10n.sessionsRoomDeleteSession,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          RankingCard(
            session: session,
            teams: snapshot.teams,
            playedHoles: snapshot.playedHoles,
          ),
          const SizedBox(height: 16),
          if (snapshot.playedHoles.isEmpty)
            NuniEmptyState(
              icon: PhosphorIcons.golf,
              message: l10n.sessionsLiveNoHoles,
            )
          else
            for (final entry in snapshot.playedHolesRecentFirst.asMap().entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PlayedHoleCard(
                  playedHole: entry.value,
                  teams: snapshot.teams,
                  scoringMode: session.scoringMode,
                  canEditTeam: (teamId) => isOwner || myTeamId == teamId,
                  onScoreSubmit: _submitScore,
                  highlighted: entry.key == 0,
                  onDelete: isOwner
                      ? (_busy ? null : () => _deleteHole(entry.value.id))
                      : null,
                ),
              ),
        ],
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              onPressed: _busy
                  ? null
                  : () => showAddPlayedHoleSheet(
                      context,
                      sessionId: widget.sessionId,
                      kind: session.kind,
                    ),
              icon: const Icon(PhosphorIcons.plus),
              label: Text(l10n.sessionsLiveAddHoleTitle),
            )
          : null,
      bottomNavigationBar: const NuniStandaloneBottomNav(),
    );
  }
}
