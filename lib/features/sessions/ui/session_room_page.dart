import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_loading.dart';
import '../../profile/domain/player.dart';
import '../data/sessions_repository.dart';
import '../domain/session.dart';
import '../domain/session_kind.dart';
import '../domain/session_member.dart';
import '../domain/session_room.dart';
import '../domain/team.dart';
import '../domain/team_composition.dart';
import 'add_participant_sheet.dart';
import 'invite_sheet.dart';

/// `/session/:id` (plan 07): the waiting room while `status = draft`. Plan
/// 08 owns what this route shows once the session goes live -- for now it's
/// a placeholder, since the live screen doesn't exist yet.
class SessionRoomPage extends ConsumerWidget {
  const SessionRoomPage({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final roomAsync = ref.watch(sessionRoomProvider(sessionId));

    return roomAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.sessionsRoomTitle)),
        body: const NuniLoading(),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.sessionsRoomTitle)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: NuniErrorBanner(
            message: describeError(error, l10n),
            onRetry: () => ref.invalidate(sessionRoomProvider(sessionId)),
          ),
        ),
      ),
      data: (room) {
        if (room.session.status != SessionStatus.draft) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.sessionsRoomTitle)),
            body: NuniEmptyState(
              icon: PhosphorIcons.golfFill,
              message: l10n.sessionsRoomStarted,
              action: NuniButton(
                label: l10n.sessionsRoomBackHome,
                onPressed: () => context.go('/'),
              ),
            ),
          );
        }
        return _WaitingRoomView(sessionId: sessionId, room: room);
      },
    );
  }
}

class _WaitingRoomView extends ConsumerStatefulWidget {
  const _WaitingRoomView({required this.sessionId, required this.room});

  final String sessionId;
  final SessionRoomSnapshot room;

  @override
  ConsumerState<_WaitingRoomView> createState() => _WaitingRoomViewState();
}

class _WaitingRoomViewState extends ConsumerState<_WaitingRoomView> {
  final _selected = <String>{};
  bool _busy = false;

  String? get _currentUserId =>
      ref.read(supabaseClientProvider).auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    final myId = _currentUserId;
    if (myId != null &&
        widget.room.pool.any((member) => member.userId == myId)) {
      _selected.add(myId);
    }
  }

  @override
  void didUpdateWidget(covariant _WaitingRoomView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final poolIds = widget.room.pool.map((member) => member.userId).toSet();
    _selected.removeWhere((id) => !poolIds.contains(id));
  }

  SessionMember? _findMember(SessionRoomSnapshot room, String? userId) {
    if (userId == null) return null;
    for (final member in room.members) {
      if (member.userId == userId) return member;
    }
    return null;
  }

  Map<String, String> get _selectionAsPlayerIds {
    final map = <String, String>{};
    for (final userId in _selected) {
      final player = widget.room.playersByUserId[userId];
      if (player != null) map[userId] = player.id;
    }
    return map;
  }

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
    } on UnevenPlayerCountException {
      _showSnack(l10n.sessionsRoomRandomDrawOddError);
    } on NotEnoughPlayersException {
      _showSnack(l10n.sessionsRoomRandomDrawTooFewError);
    } catch (error) {
      _showSnack(describeError(error, l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addParticipant() async {
    final excluded = {for (final m in widget.room.members) m.userId};
    final player = await showAddParticipantSheet(
      context,
      excludedUserIds: excluded,
    );
    final userId = player?.userId;
    if (userId == null) return;
    await _run(
      () => ref
          .read(sessionsRepositoryProvider)
          .addParticipant(sessionId: widget.sessionId, userId: userId),
    );
  }

  Future<void> _formTeam() async {
    final selection = _selectionAsPlayerIds;
    await _run(
      () => ref
          .read(sessionsRepositoryProvider)
          .formTeam(sessionId: widget.sessionId, selection: selection),
    );
    if (mounted) setState(_selected.clear);
  }

  Future<void> _drawRandom() async {
    final selection = _selectionAsPlayerIds;
    await _run(
      () => ref
          .read(sessionsRepositoryProvider)
          .formRandomTeams(sessionId: widget.sessionId, selection: selection),
    );
    if (mounted) setState(_selected.clear);
  }

  Future<void> _unassign(SessionMember member) async {
    final playerId = widget.room.playersByUserId[member.userId]?.id;
    final teamId = member.teamId;
    if (playerId == null || teamId == null) return;
    await _run(
      () => ref
          .read(sessionsRepositoryProvider)
          .unassignMember(
            sessionId: widget.sessionId,
            userId: member.userId,
            teamId: teamId,
            playerId: playerId,
          ),
    );
  }

  Future<void> _removeMember(SessionMember member) async {
    final playerId = widget.room.playersByUserId[member.userId]?.id;
    await _run(
      () => ref
          .read(sessionsRepositoryProvider)
          .removeMember(
            sessionId: widget.sessionId,
            userId: member.userId,
            teamId: member.teamId,
            playerId: playerId,
          ),
    );
  }

  Future<void> _deleteTeam(Team team) =>
      _run(() => ref.read(sessionsRepositoryProvider).deleteTeam(team.id));

  Future<void> _promote(SessionMember member) => _run(
    () => ref
        .read(sessionsRepositoryProvider)
        .promoteToOwner(sessionId: widget.sessionId, userId: member.userId),
  );

  Future<void> _leave() async {
    await _run(
      () => ref.read(sessionsRepositoryProvider).leaveSession(widget.sessionId),
    );
    // RLS drops access the moment the membership row is gone; the realtime
    // room stream won't necessarily keep delivering updates past that
    // point, so leave the page explicitly instead of waiting for it to
    // reflect the departure.
    if (mounted) context.go('/');
  }

  Future<void> _start() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await ref.read(sessionsRepositoryProvider).startSession(widget.sessionId);
    } on PostgrestException catch (error) {
      _showSnack(_startErrorMessage(error, l10n));
    } catch (error) {
      _showSnack(describeError(error, l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _startErrorMessage(PostgrestException error, AppLocalizations l10n) {
    const prefix = 'unassigned_participants: ';
    final message = error.message;
    if (message.startsWith(prefix)) {
      return l10n.sessionsRoomStartBlockedTeam(
        message.substring(prefix.length),
      );
    }
    if (message == 'no_participants' || message == 'no_teams') {
      return l10n.sessionsRoomStartBlockedEmpty;
    }
    return describeError(error, l10n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final room = widget.room;
    final myMember = _findMember(room, _currentUserId);
    final isOwner = myMember?.role == MemberRole.owner;
    final canStart = canStartSession(
      kind: room.session.kind,
      members: room.members,
      teamCount: room.teams.length,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionsRoomTitle),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIcons.shareNetwork),
            tooltip: l10n.sessionsInviteTitle,
            onPressed: () => InviteSheet.show(context, room.session.code),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          NuniCard(
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.signpost,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.sessionsRoomCodeLabel(room.session.code),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
          ),
          if (!isOwner) ...[
            const SizedBox(height: 16),
            Text(
              l10n.sessionsRoomWaitingForOwner(
                room.playersByUserId[room.session.ownerId]?.name ?? '',
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (myMember != null) ...[
              const SizedBox(height: 12),
              NuniButton(
                variant: NuniButtonVariant.secondary,
                icon: PhosphorIcons.signOut,
                label: l10n.sessionsRoomLeave,
                onPressed: _busy ? null : _leave,
              ),
            ],
          ],
          const SizedBox(height: 24),
          if (room.session.kind == SessionKind.team)
            _TeamsSection(
              room: room,
              isOwner: isOwner,
              selected: _selected,
              busy: _busy,
              currentUserId: _currentUserId,
              onDeleteTeam: _deleteTeam,
              onUnassign: _unassign,
              onPromote: _promote,
            ),
          if (room.session.kind == SessionKind.team) const SizedBox(height: 24),
          _PoolSection(
            room: room,
            isOwner: isOwner,
            selected: _selected,
            busy: _busy,
            currentUserId: _currentUserId,
            showSelection: room.session.kind == SessionKind.team,
            onToggle: (userId, value) => setState(() {
              if (value) {
                _selected.add(userId);
              } else {
                _selected.remove(userId);
              }
            }),
            onRemove: _removeMember,
            onPromote: _promote,
          ),
          if (isOwner) ...[
            const SizedBox(height: 16),
            NuniButton(
              variant: NuniButtonVariant.secondary,
              icon: PhosphorIcons.userPlus,
              label: l10n.sessionsRoomAddParticipant,
              onPressed: _busy ? null : _addParticipant,
            ),
            if (room.session.kind == SessionKind.team) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: NuniButton(
                      variant: NuniButtonVariant.secondary,
                      icon: PhosphorIcons.users,
                      label: l10n.sessionsRoomFormTeam,
                      onPressed:
                          (!_busy &&
                              _selected.length == room.session.kind.teamSize)
                          ? _formTeam
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NuniButton(
                      variant: NuniButtonVariant.secondary,
                      icon: PhosphorIcons.shuffle,
                      label: l10n.sessionsRoomRandomDraw,
                      onPressed: _busy || _selected.length < 4
                          ? null
                          : _drawRandom,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
      bottomNavigationBar: isOwner
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: NuniButton(
                  icon: PhosphorIcons.play,
                  label: l10n.sessionsRoomStart,
                  onPressed: (_busy || !canStart) ? null : _start,
                ),
              ),
            )
          : null,
    );
  }
}

class _TeamsSection extends StatelessWidget {
  const _TeamsSection({
    required this.room,
    required this.isOwner,
    required this.selected,
    required this.busy,
    required this.currentUserId,
    required this.onDeleteTeam,
    required this.onUnassign,
    required this.onPromote,
  });

  final SessionRoomSnapshot room;
  final bool isOwner;
  final Set<String> selected;
  final bool busy;
  final String? currentUserId;
  final ValueChanged<Team> onDeleteTeam;
  final ValueChanged<SessionMember> onUnassign;
  final ValueChanged<SessionMember> onPromote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (room.teams.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.sessionsRoomTeamsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        for (final team in room.teams) ...[
          NuniCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.sessionsRoomTeamLabel(team.position),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    if (isOwner)
                      IconButton(
                        icon: const Icon(PhosphorIcons.trash, size: 18),
                        tooltip: l10n.sessionsRoomDeleteTeam,
                        onPressed: busy ? null : () => onDeleteTeam(team),
                      ),
                  ],
                ),
                for (final member in room.membersOf(team.id))
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.playerFor(member)?.name ?? '',
                          style: member.userId == currentUserId
                              ? Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)
                              : null,
                        ),
                      ),
                      if (isOwner && member.role != MemberRole.owner)
                        IconButton(
                          icon: const Icon(PhosphorIcons.crown, size: 18),
                          tooltip: l10n.sessionsRoomPromote,
                          onPressed: busy ? null : () => onPromote(member),
                        ),
                      if (isOwner)
                        IconButton(
                          icon: const Icon(PhosphorIcons.minusCircle, size: 18),
                          tooltip: l10n.sessionsRoomUnassign,
                          onPressed: busy ? null : () => onUnassign(member),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PoolSection extends StatelessWidget {
  const _PoolSection({
    required this.room,
    required this.isOwner,
    required this.selected,
    required this.busy,
    required this.currentUserId,
    required this.showSelection,
    required this.onToggle,
    required this.onRemove,
    required this.onPromote,
  });

  final SessionRoomSnapshot room;
  final bool isOwner;
  final Set<String> selected;
  final bool busy;
  final String? currentUserId;
  final bool showSelection;
  final void Function(String userId, bool value) onToggle;
  final ValueChanged<SessionMember> onRemove;
  final ValueChanged<SessionMember> onPromote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pool = room.pool;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.sessionsRoomPoolTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (pool.isEmpty)
          NuniCard(child: Text(l10n.sessionsRoomPoolEmpty))
        else
          NuniCard(
            child: Column(
              children: [
                for (final member in pool)
                  _PoolRow(
                    member: member,
                    player: room.playerFor(member),
                    isOwner: isOwner,
                    busy: busy,
                    isCurrentUser: member.userId == currentUserId,
                    showSelection: showSelection,
                    selected: selected.contains(member.userId),
                    onToggle: (value) => onToggle(member.userId, value),
                    onRemove: () => onRemove(member),
                    onPromote: () => onPromote(member),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PoolRow extends StatelessWidget {
  const _PoolRow({
    required this.member,
    required this.player,
    required this.isOwner,
    required this.busy,
    required this.isCurrentUser,
    required this.showSelection,
    required this.selected,
    required this.onToggle,
    required this.onRemove,
    required this.onPromote,
  });

  final SessionMember member;
  final Player? player;
  final bool isOwner;
  final bool busy;
  final bool isCurrentUser;
  final bool showSelection;
  final bool selected;
  final ValueChanged<bool> onToggle;
  final VoidCallback onRemove;
  final VoidCallback onPromote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = player?.name ?? '';
    final label = isCurrentUser ? '$name (${l10n.sessionsRoomYou})' : name;
    final canPromote = isOwner && member.role != MemberRole.owner;

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canPromote)
          IconButton(
            icon: const Icon(PhosphorIcons.crown, size: 18),
            tooltip: l10n.sessionsRoomPromote,
            onPressed: busy ? null : onPromote,
          ),
        if (isOwner)
          IconButton(
            icon: const Icon(PhosphorIcons.xCircle, size: 18),
            tooltip: l10n.sessionsRoomRemoveParticipant,
            onPressed: busy ? null : onRemove,
          ),
      ],
    );

    if (isOwner && showSelection) {
      return CheckboxListTile(
        value: selected,
        onChanged: busy ? null : (value) => onToggle(value ?? false),
        title: Text(label),
        controlAffinity: ListTileControlAffinity.leading,
        secondary: actions,
      );
    }

    return ListTile(title: Text(label), trailing: isOwner ? actions : null);
  }
}
