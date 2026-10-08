import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/authorization/authorization_repository.dart';
import '../../../core/errors/app_error_message.dart';
import '../../../core/router/app_bottom_nav.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../core/weather/weather_client.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_avatar.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_confirm_dialog.dart';
import '../../../shared/nuni_grouped_list.dart';
import '../../../shared/nuni_hero.dart';
import '../../../shared/nuni_section_header.dart';
import '../../../shared/nuni_status_pill.dart';
import '../../associations/data/association_rights.dart';
import '../../profile/data/profile_repository.dart';
import '../../stats/data/stats_repository.dart';
import '../data/sessions_repository.dart';
import '../domain/session.dart';
import '../domain/session_member.dart';
import '../domain/session_room.dart';
import 'add_participant_sheet.dart';
import 'draft_session_notice.dart';
import 'invite_sheet.dart';
import 'member_join_indicator.dart';
import 'session_nature.dart';
import 'session_nature_rules.dart';
import 'super_admin_outsider_banner.dart';

/// A session without scorecard (plan 29) while it's a draft or live: its
/// natures, place, attendees and report -- no holes, scores or ranking. The
/// attendees are the players of its single team (the base keeps them in
/// step with `session_members.team_id`); the organizer adds them by hand,
/// or they join with the code. "End" works straight from the draft, for a
/// logbook filled in afterwards (the date is corrected in the history).
class AttendanceRoomView extends ConsumerStatefulWidget {
  const AttendanceRoomView({
    super.key,
    required this.sessionId,
    required this.room,
  });

  final String sessionId;
  final SessionRoomSnapshot room;

  @override
  ConsumerState<AttendanceRoomView> createState() => _AttendanceRoomViewState();
}

class _AttendanceRoomViewState extends ConsumerState<AttendanceRoomView> {
  bool _busy = false;

  Session get _session => widget.room.session;

  String? get _currentUserId =>
      ref.read(supabaseClientProvider).auth.currentUser?.id;

  /// The single team, created with the session.
  String? get _teamId =>
      widget.room.teams.isEmpty ? null : widget.room.teams.first.id;

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
      ref.invalidate(sessionRoomProvider(widget.sessionId));
    } catch (error) {
      _showSnack(sessionNatureErrorMessage(error, l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addAttendee() async {
    final excluded = {
      for (final m in widget.room.members)
        if (m.teamId != null) m.userId,
    };
    final player = await showAddParticipantSheet(
      context,
      excludedUserIds: excluded,
    );
    final userId = player?.userId;
    if (userId == null) return;
    final repo = ref.read(sessionsRepositoryProvider);
    final isMember = widget.room.members.any((m) => m.userId == userId);
    await _run(
      () => isMember
          // The organizer who had stepped out of the attendees.
          ? repo.setAttending(
              sessionId: widget.sessionId,
              userId: userId,
              teamId: _teamId,
            )
          : repo.addParticipant(sessionId: widget.sessionId, userId: userId),
    );
  }

  Future<void> _removeAttendee(SessionMember member) {
    final repo = ref.read(sessionsRepositoryProvider);
    return _run(
      () => member.role == MemberRole.owner
          // An organizer stays one, just not among the attendees.
          ? repo.setAttending(
              sessionId: widget.sessionId,
              userId: member.userId,
              teamId: null,
            )
          : repo.removeMember(
              sessionId: widget.sessionId,
              userId: member.userId,
            ),
    );
  }

  Future<void> _setMeAttending(bool value) => _run(
    () => ref
        .read(sessionsRepositoryProvider)
        .setAttending(
          sessionId: widget.sessionId,
          userId: _currentUserId!,
          teamId: value ? _teamId : null,
        ),
  );

  /// The session form (plan 31); it refreshes this room once saved.
  void _edit() => unawaited(context.push('/session/${widget.sessionId}/edit'));

  Future<void> _start() async {
    final repo = ref.read(sessionsRepositoryProvider);
    await _run(() async {
      await repo.startSession(widget.sessionId);
      ref.invalidate(myOngoingSessionsProvider);
      unawaited(_captureWeather(repo));
    });
  }

  Future<void> _finish() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await NuniConfirmDialog.show(
      context,
      title: l10n.sessionsLiveEndConfirmTitle,
      message: l10n.sessionsFinishConfirmMessage,
      confirmLabel: l10n.sessionsLiveEndSession,
    );
    if (!confirmed || !mounted) return;
    final repo = ref.read(sessionsRepositoryProvider);
    await _run(() async {
      if (_session.weather == null) await _captureWeather(repo);
      await repo.finish(_session);
      ref
        ..invalidate(myOngoingSessionsProvider)
        ..invalidate(myRecentSessionsProvider);
      // My activity sessions changed: recompute my badges (family L).
      final myPlayerId = ref.read(myPlayerProvider).value?.id;
      if (myPlayerId != null) ref.invalidate(playerHistoryProvider(myPlayerId));
    });
  }

  /// Best-effort and silent, like the waiting room's (plan 07).
  Future<void> _captureWeather(SessionsRepository repo) async {
    final lat = _session.locationLat;
    final lng = _session.locationLng;
    if (lat == null || lng == null) return;
    final weather = await ref
        .read(weatherClientProvider)
        .fetch(lat: lat, lng: lng);
    if (weather != null) await repo.attachWeather(widget.sessionId, weather);
  }

  Future<void> _leave() async {
    await _run(
      () => ref.read(sessionsRepositoryProvider).leaveSession(widget.sessionId),
    );
    ref.invalidate(myOngoingSessionsProvider);
    if (mounted) context.go('/');
  }

  Future<void> _delete() async {
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
      await ref
          .read(sessionsRepositoryProvider)
          .deleteSession(widget.sessionId);
      ref.invalidate(myOngoingSessionsProvider);
      if (mounted) context.go('/');
    } catch (error) {
      if (mounted) {
        _showSnack(describeError(error, AppLocalizations.of(context)!));
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final room = widget.room;
    final session = _session;
    final locale = Localizations.localeOf(context).toString();
    final myId = _currentUserId;
    SessionMember? me;
    for (final member in room.members) {
      if (member.userId == myId) me = member;
    }
    final isOwner = canOrganizeSession(
      me?.role,
      isSuperAdmin: ref.watch(isSuperAdminProvider).value ?? false,
    );
    final isDraft = session.status == SessionStatus.draft;
    // Plan 37: not played until picked to create a session (Q261).
    final isUnpublished = !session.published;
    final associationId = session.associationId;
    final isStaff =
        associationId != null &&
        (ref.watch(canManageAssociationProvider(associationId)).value ?? false);
    final attendees =
        [
          for (final member in room.members)
            if (member.teamId != null) member,
        ]..sort(
          (a, b) => (room.playerFor(a)?.name ?? '').compareTo(
            room.playerFor(b)?.name ?? '',
          ),
        );
    return Scaffold(
      appBar: AppBar(title: Text(sessionHeading(session))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          // Plan 38 (Q277): a super_admin outside it; what follows opens
          // with its own spacing, the hero being a member's only.
          SuperAdminOutsiderBanner(isMember: me != null),
          if (me != null)
            NuniHero(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.sessionsRoomCodeLabel(session.code),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  NuniButton(
                    variant: NuniButtonVariant.onHero,
                    icon: PhosphorIcons.shareNetwork,
                    label: l10n.sessionsInviteTitle,
                    onPressed: () => InviteSheet.show(context, session.code),
                  ),
                ],
              ),
            ),
          if (isUnpublished) ...[
            const SizedBox(height: 16),
            const DraftSessionNotice(),
          ],
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SessionNaturePills(
                  session: session,
                  trailing: [
                    if (session.status == SessionStatus.live)
                      NuniStatusPill(
                        label: l10n.homeSessionStatusLive,
                        tone: NuniTone.fairway,
                        dot: true,
                      ),
                  ],
                ),
              ),
              if (isOwner || isStaff)
                IconButton(
                  icon: const Icon(PhosphorIcons.pencilSimple, size: 20),
                  tooltip: l10n.historyEditTitle,
                  visualDensity: VisualDensity.compact,
                  onPressed: _busy ? null : _edit,
                ),
            ],
          ),
          if (session.startedAt != null) ...[
            const SizedBox(height: 6),
            Text(
              DateFormat.yMMMMd(locale)
                  .add_Hm()
                  .format(session.startedAt!.toLocal()),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 24),
          NuniSectionHeader(
            title: l10n.sessionsAttendeesTitle,
            trailing: attendees.isEmpty
                ? null
                : JoinedCountPill(members: attendees),
          ),
          if (attendees.isEmpty)
            SizedBox(
              width: double.infinity,
              child: NuniCard(
                child: Text(
                  l10n.sessionsAttendeesEmpty,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            NuniGroupedList(
              children: [
                for (final member in attendees)
                  ListTile(
                    leading: NuniAvatar(
                      name: room.playerFor(member)?.name,
                      imageUrl: room.playerFor(member)?.avatarUrl,
                      size: 36,
                    ),
                    title: MemberNameWithJoin(
                      name: member.userId == myId
                          ? '${room.playerFor(member)?.name ?? ''} '
                                '(${l10n.sessionsRoomYou})'
                          : room.playerFor(member)?.name ?? '',
                      member: member,
                    ),
                    trailing: isOwner
                        ? IconButton(
                            icon: const Icon(PhosphorIcons.xCircle, size: 18),
                            tooltip: l10n.sessionsRoomRemoveParticipant,
                            onPressed: _busy
                                ? null
                                : () => _removeAttendee(member),
                          )
                        : null,
                  ),
              ],
            ),
          if (isOwner) ...[
            const SizedBox(height: 8),
            // An organizer of the session; not a super_admin outside it.
            if (me != null)
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: Text(l10n.sessionsAttendeesMe),
                value: me.teamId != null,
                onChanged: _busy || _teamId == null ? null : _setMeAttending,
              ),
            NuniButton(
              variant: NuniButtonVariant.secondary,
              icon: PhosphorIcons.userPlus,
              label: l10n.sessionsAttendeesAdd,
              onPressed: _busy ? null : _addAttendee,
            ),
          ],
          const SizedBox(height: 24),
          SessionReportCard(
            report: session.comment,
            onEdit: (isOwner || isStaff) && !_busy ? _edit : null,
          ),
          if (!isOwner && me != null && isDraft) ...[
            const SizedBox(height: 16),
            NuniButton(
              variant: NuniButtonVariant.secondary,
              icon: PhosphorIcons.signOut,
              label: l10n.sessionsRoomLeave,
              onPressed: _busy ? null : _leave,
            ),
          ],
          if (isOwner) ...[
            const SizedBox(height: 16),
            NuniButton(
              variant: NuniButtonVariant.danger,
              icon: PhosphorIcons.trash,
              label: l10n.sessionsRoomDeleteSession,
              onPressed: _busy ? null : _delete,
            ),
          ],
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOwner && !isUnpublished)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (isDraft) ...[
                      Expanded(
                        child: NuniButton(
                          variant: NuniButtonVariant.secondary,
                          icon: PhosphorIcons.play,
                          label: l10n.sessionsRoomStart,
                          onPressed: _busy ? null : _start,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: NuniButton(
                        icon: PhosphorIcons.checkCircle,
                        label: l10n.sessionsLiveEndSession,
                        onPressed: _busy ? null : _finish,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const NuniStandaloneBottomNav(),
        ],
      ),
    );
  }
}
