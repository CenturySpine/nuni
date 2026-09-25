import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_avatar.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_confirm_dialog.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_linked_text.dart';
import '../../../shared/nuni_list_card.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_map_attribution.dart';
import '../../../shared/nuni_section_header.dart';
import '../../../shared/nuni_share.dart';
import '../../../shared/nuni_status_pill.dart';
import '../../players/data/players_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/player.dart';
import '../../sessions/domain/session.dart';
import '../data/events_repository.dart';
import '../data/planning_rights.dart';
import '../domain/event.dart';
import '../domain/planning.dart';
import 'event_comments_section.dart';
import 'event_widgets.dart';

/// The link that opens [eventId]'s detail (Q168), built on the running
/// page's origin like the invitation link (plan 09).
Uri eventUrl(String eventId, {Uri? origin}) =>
    Uri.parse('${(origin ?? Uri.base).origin}/planning/$eventId');

/// `/planning/:id` (plan 23, decision 9): an event in full -- every detail,
/// a large map, the answers, the comment thread -- and what may be done
/// with it (share, edit, clone, delete, start the session).
class EventDetailPage extends ConsumerWidget {
  const EventDetailPage({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final event = ref.watch(eventByIdProvider(eventId));

    return event.when(
      data: (event) => event == null
          ? Scaffold(
              appBar: AppBar(),
              body: NuniEmptyState(
                icon: PhosphorIcons.calendarBlank,
                message: l10n.planningEventNotFound,
                action: NuniButton(
                  label: l10n.navPlanning,
                  onPressed: () => context.go('/planning'),
                ),
              ),
            )
          : _EventDetail(event: event),
      loading: () => Scaffold(appBar: AppBar(), body: const NuniLoading()),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: NuniErrorBanner(message: describeError(error, l10n)),
        ),
      ),
    );
  }
}

class _EventDetail extends ConsumerWidget {
  const _EventDetail({required this.event});

  final Event event;

  void _refresh(WidgetRef ref) {
    ref
      ..invalidate(eventByIdProvider(event.id))
      ..invalidate(myPlanningProvider);
  }

  /// Copies the event's link, nothing else, on every device (PO,
  /// 2026-09-25): no system share sheet -- the link is then pasted where
  /// one wants (WhatsApp...), and its preview shows the app.
  Future<void> _share(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return copyAndConfirm(
      context,
      text: eventUrl(event.id).toString(),
      copiedMessage: l10n.planningLinkCopied,
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await NuniConfirmDialog.show(
      context,
      title: l10n.planningDeleteTitle,
      message: l10n.planningDeleteMessage,
      confirmLabel: l10n.commonDelete,
      danger: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(eventsRepositoryProvider).delete(event.id);
      ref.invalidate(myPlanningProvider);
      if (context.mounted) context.go('/planning');
    } catch (error) {
      if (context.mounted) _snack(context, describePlanningError(error, l10n));
    }
  }

  Future<void> _answer(
    BuildContext context,
    WidgetRef ref,
    String playerId,
    EventResponse? response,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(eventsRepositoryProvider)
          .answer(eventId: event.id, playerId: playerId, response: response);
    } catch (error) {
      if (context.mounted) _snack(context, describePlanningError(error, l10n));
    }
    _refresh(ref);
  }

  void _snack(BuildContext context, String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final me = ref.watch(myPlayerProvider).value;
    final rights = ref.watch(eventRightsProvider(event)).value;
    final members =
        ref.watch(associationPlayersProvider(event.associationId)).value ??
        const <Player>[];
    final open = acceptsAnswers(event, DateTime.now());
    final hue = eventHue(event.color);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l10n.planningShare,
            icon: const Icon(PhosphorIcons.shareNetwork),
            onPressed: () => _share(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(PhosphorIcons.dotsThreeVertical),
            onSelected: (action) => switch (action) {
              'edit' => context.push('/planning/${event.id}/edit'),
              'clone' => context.push('/planning/new?from=${event.id}'),
              _ => _delete(context, ref),
            },
            itemBuilder: (context) => [
              if (rights?.canManage ?? false)
                PopupMenuItem(value: 'edit', child: Text(l10n.planningEdit)),
              PopupMenuItem(value: 'clone', child: Text(l10n.planningClone)),
              if (rights?.canManage ?? false)
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    l10n.planningDelete,
                    style: TextStyle(color: scheme.error),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(ref),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            if (hue != null)
              Container(
                height: 6,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: hue,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            Text(
              event.label,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  PhosphorIcons.clock,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    eventDateTimeLabel(context, event.startsAt),
                    style: textTheme.titleSmall,
                  ),
                ),
                if (event.origin == EventOrigin.imported)
                  NuniStatusPill(
                    label: l10n.planningImported,
                    tone: NuniTone.neutral,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _PlaceBlock(event: event),
            if (event.managerPlayerId != null) ...[
              const SizedBox(height: 16),
              _ManagerTile(playerId: event.managerPlayerId!),
            ],
            if (event.description != null) ...[
              const SizedBox(height: 16),
              NuniCard(
                child: NuniLinkedText(
                  event.description!,
                  style: textTheme.bodyMedium,
                ),
              ),
            ],
            _SessionsBlock(
              event: event,
              canStart: rights?.canStartSession ?? false,
            ),
            const SizedBox(height: 24),
            NuniSectionHeader(title: l10n.planningAnswers),
            if (me != null) ...[
              Text(l10n.planningYourAnswer, style: textTheme.labelLarge),
              const SizedBox(height: 8),
              EventResponseButtons(
                current: event.responseOf(me.id),
                onChanged: open
                    ? (response) => _answer(context, ref, me.id, response)
                    : null,
              ),
              if (!open) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.planningAnswersClosed,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
            _AnswersBlock(event: event, members: members),
            const SizedBox(height: 24),
            EventCommentsSection(
              event: event,
              members: members,
              canModerate: rights?.canModerate ?? false,
            ),
          ],
        ),
      ),
    );
  }
}

/// The place: a large map with the point and "Directions" (decision 9), or
/// the spot's name alone, or "place to be decided".
class _PlaceBlock extends StatelessWidget {
  const _PlaceBlock({required this.event});

  final Event event;

  Uri _directions() => Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': event.hasLocation
        ? '${event.locationLat},${event.locationLng}'
        : event.spot!,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final spotText = event.spot ?? l10n.planningSpotToBeDecided;
    final hasPlace = event.hasLocation || event.spot != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (event.hasLocation) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(NuniRadius.card),
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height / 3,
              child: _EventMap(
                point: LatLng(event.locationLat!, event.locationLng!),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (context) => Scaffold(
                      appBar: AppBar(title: Text(spotText)),
                      body: _EventMap(
                        point: LatLng(event.locationLat!, event.locationLng!),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Icon(
              PhosphorIcons.mapPin,
              size: 20,
              color: context.nuni.primaryInk,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                spotText,
                style: textTheme.titleSmall?.copyWith(
                  color: event.spot == null ? scheme.onSurfaceVariant : null,
                ),
              ),
            ),
            if (hasPlace)
              TextButton.icon(
                onPressed: () => launchUrl(
                  _directions(),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(PhosphorIcons.path, size: 18),
                label: Text(l10n.planningDirections),
              ),
          ],
        ),
      ],
    );
  }
}

class _EventMap extends StatelessWidget {
  const _EventMap({required this.point, this.onTap});

  final LatLng point;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: point,
        initialZoom: 16,
        onTap: onTap == null ? null : (_, _) => onTap!(),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'org.centuryspine.nuni',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: point,
              width: 44,
              height: 44,
              alignment: Alignment.topCenter,
              child: Icon(
                PhosphorIcons.mapPinFill,
                color: context.nuni.primaryInk,
                size: 40,
              ),
            ),
          ],
        ),
        const NuniMapAttribution(),
      ],
    );
  }
}

class _ManagerTile extends ConsumerWidget {
  const _ManagerTile({required this.playerId});

  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final player = ref.watch(playerByIdProvider(playerId)).value;
    return NuniListCard(
      leading: NuniAvatar(name: player?.name, imageUrl: player?.avatarUrl),
      title: player?.name ?? '…',
      subtitle: l10n.planningManager,
      onTap: () => context.push('/players/$playerId'),
    );
  }
}

/// "Start the session" on the event's day for who may (Q164), and the
/// sessions already started from it -- so a second person doesn't start one
/// twice without knowing.
class _SessionsBlock extends ConsumerWidget {
  const _SessionsBlock({required this.event, required this.canStart});

  final Event event;
  final bool canStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sessions =
        ref.watch(eventSessionsProvider(event.id)).value ?? const <Session>[];
    if (!canStart && sessions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        if (canStart)
          NuniButton(
            icon: PhosphorIcons.play,
            label: l10n.planningStartSession,
            onPressed: () => context.push('/session/new?event=${event.id}'),
          ),
        if (sessions.isNotEmpty) ...[
          const SizedBox(height: 16),
          NuniSectionHeader(title: l10n.planningSessionsFromEvent),
          for (final session in sessions) ...[
            NuniListCard(
              leading: const Icon(PhosphorIcons.golf),
              title: session.zone ?? session.city ?? session.code,
              subtitle: session.code,
              onTap: () => context.push(
                session.status == SessionStatus.completed
                    ? '/history/${session.id}'
                    : '/session/${session.id}',
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

/// Who answered what (Q157), and how many members haven't answered.
class _AnswersBlock extends StatelessWidget {
  const _AnswersBlock({required this.event, required this.members});

  final Event event;
  final List<Player> members;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final byId = {for (final member in members) member.id: member};
    final answered = {for (final answer in event.answers) answer.playerId};
    final silent = members.where((m) => !answered.contains(m.id)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final response in EventResponse.values) ...[
          Builder(
            builder: (context) {
              final players = [
                for (final answer in event.answers)
                  if (answer.response == response) byId[answer.playerId],
              ];
              if (players.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NuniStatusPill(
                      label:
                          '${responseLabel(l10n, response)} · ${players.length}',
                      tone: responseTone(response),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        for (final player in players)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              NuniAvatar(
                                name: player?.name,
                                imageUrl: player?.avatarUrl,
                                size: 28,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                player?.name ?? '…',
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        if (silent > 0)
          Text(
            l10n.planningNoAnswerCount(silent),
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
