import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/geocoding/reverse_geocoding_client.dart';
import '../../../core/location/location_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_chip.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_form_section.dart';
import '../../../shared/nuni_list_card.dart';
import '../../../shared/nuni_segmented.dart';
import '../../associations/data/associations_repository.dart';
import '../../associations/ui/association_logo.dart';
import '../../championship/data/championship_rights.dart';
import '../../planning/data/events_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../spots/data/spots_repository.dart';
import '../../spots/domain/spot.dart';
import '../../spots/ui/spot_picker.dart';
import '../data/libre_ranking_direction_pref.dart';
import '../data/sessions_repository.dart';
import '../domain/ranking_direction.dart';
import '../domain/scoring_mode.dart';
import '../domain/session_kind.dart';
import 'championship_toggle.dart';
import 'scoring_mode_info_sheet.dart';

/// `/session/new` (plan 07): parameters only -- team composition happens
/// afterwards, in the waiting room (`SessionRoomPage`).
///
/// `/session/new?event=:id` (plan 23, Q164) is the same form reached from
/// "Start the session" on today's event: the spot starts as the event's
/// when it has one, and the members who answered "present" join the waiting
/// room (create_session does it). Nothing else changes: a shortcut only.
///
/// The spot is required and chosen among the association's (plan 28); its
/// name and city become the session's zone and city (Q184).
class SessionCreatePage extends ConsumerStatefulWidget {
  const SessionCreatePage({super.key, this.eventId});

  final String? eventId;

  @override
  ConsumerState<SessionCreatePage> createState() => _SessionCreatePageState();
}

class _SessionCreatePageState extends ConsumerState<SessionCreatePage> {
  SessionKind _kind = SessionKind.individual;
  ScoringMode _scoringMode = ScoringMode.strokePlay;
  bool _isChampionship = false;
  Spot? _spot;

  /// Set once "Create" was tapped without a spot, to say it's missing.
  bool _spotMissing = false;

  Position? _position;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    unawaited(_detectLocation());
    unawaited(_prefillFromEvent());
  }

  Future<void> _prefillFromEvent() async {
    final eventId = widget.eventId;
    if (eventId == null) return;
    final event = await ref.read(eventByIdProvider(eventId).future);
    final spotId = event?.spotId;
    if (event == null || spotId == null) return;
    final spots = await ref.read(
      associationSpotsProvider(event.associationId).future,
    );
    final spot = spots.where((s) => s.id == spotId).firstOrNull;
    if (mounted && spot != null && _spot == null) {
      setState(() => _spot = spot);
    }
  }

  Future<void> _detectLocation() async {
    final position = await ref
        .read(locationServiceProvider)
        .getCurrentPosition();
    if (!mounted || position == null) return;
    setState(() => _position = position);
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final spot = _spot;
    if (spot == null) {
      setState(() => _spotMissing = true);
      return;
    }
    setState(() => _creating = true);
    try {
      final implied = _scoringMode.impliedRankingDirection;
      final RankingDirection rankingDirection;
      if (implied != null) {
        rankingDirection = implied;
      } else {
        rankingDirection = await ref.read(
          libreRankingDirectionPrefProvider.future,
        );
      }

      // The session's point: where its creator stands -- except on a spot
      // with a variable location (Q186), where the event it's started from
      // says where it is today. Such a spot has no city: it's found from
      // that point, as before plan 28 (Q11).
      var lat = _position?.latitude;
      var lng = _position?.longitude;
      String? city;
      if (spot.variableLocation) {
        final event = widget.eventId == null
            ? null
            : ref.read(eventByIdProvider(widget.eventId!)).value;
        if (event != null && event.hasLocation) {
          lat = event.locationLat;
          lng = event.locationLng;
        }
        if (lat != null && lng != null) {
          city = await ref
              .read(reverseGeocodingClientProvider)
              .cityFor(lat: lat, lng: lng, languageCode: languageCode);
        }
      }

      final repo = ref.read(sessionsRepositoryProvider);
      final session = await repo.create(
        kind: _kind,
        scoringMode: _scoringMode,
        rankingDirection: rankingDirection,
        spotId: spot.id,
        city: city,
        lat: lat,
        lng: lng,
        eventId: widget.eventId,
      );
      if (widget.eventId != null) {
        ref.invalidate(eventSessionsProvider(widget.eventId!));
      }

      var taggedSession = session;
      if (_isChampionship) {
        taggedSession = await repo.setChampionship(
          sessionId: session.id,
          isChampionship: true,
        );
        if (mounted) {
          final associationLabel = taggedSession.associationId == null
              ? null
              : (await ref.read(
                  associationByIdProvider(taggedSession.associationId!).future,
                ))?.label;
          if (mounted) {
            await showChampionshipTagConfirmation(
              context,
              associationLabel: associationLabel,
              season: taggedSession.championshipSeason ?? '',
            );
          }
        }
      }

      // Home's "Mes sessions en cours" list is a plain Future provider kept
      // alive by the bottom-nav IndexedStack (never disposed by navigating
      // away), so it won't pick up the new session on its own.
      ref.invalidate(myOngoingSessionsProvider);
      if (mounted) context.go('/session/${taggedSession.id}');
    } on PostgrestException catch (error) {
      // No approved association (plan 18, Q81): normally caught earlier by
      // the screen, but the association may have changed meanwhile.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(switch (error.message) {
              'association_required' => l10n.sessionsCreateNeedsAssociation,
              // Plan 23, Q164: no longer the event's day, or no longer in
              // charge of it.
              'event_not_startable' => l10n.planningErrorNotStartable,
              // Plan 28: the spot was deleted, or belongs elsewhere, meanwhile.
              'spot_required' ||
              'spot_not_in_association' => l10n.spotsFieldRequired,
              _ => describeError(error, l10n),
            }),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(describeError(error, l10n))));
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _showScoringInfo(ScoringMode mode) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => ScoringModeInfoSheet(mode: mode),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final player = ref.watch(myPlayerProvider).value;
    final associationId = player?.associationId;
    final event = widget.eventId == null
        ? null
        : ref.watch(eventByIdProvider(widget.eventId!)).value;
    final association = associationId == null
        ? null
        : ref.watch(associationByIdProvider(associationId)).value;
    // Only the local manager or a super_admin tags the championship (plan
    // 26, decision 11): the toggle isn't offered to anyone else.
    final canTagChampionship =
        associationId != null &&
        (ref.watch(canTagChampionshipProvider(associationId)).value ?? false);

    // Only an approved association's member creates sessions (plan 18, Q81).
    if (player != null && associationId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.sessionsCreateTitle)),
        body: NuniEmptyState(
          icon: PhosphorIcons.usersThree,
          message: l10n.sessionsCreateNeedsAssociation,
          action: NuniButton(
            label: l10n.sessionsCreateSeeAssociations,
            onPressed: () => context.go('/associations'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionsCreateTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // The session belongs to its creator's association (plan 18),
          // shown read-only.
          if (association != null) ...[
            NuniListCard(
              leading: AssociationLogo(association: association, size: 40),
              title: association.name,
              subtitle: l10n.sessionsCreateAssociation,
            ),
            const SizedBox(height: 20),
          ],
          if (event != null) ...[
            NuniListCard(
              leading: const Icon(PhosphorIcons.calendarDots),
              title: l10n.sessionsCreateFromEvent(event.label),
              subtitle: l10n.sessionsCreateFromEventMembers(event.yesCount),
            ),
            const SizedBox(height: 20),
          ],
          NuniFormSection(
            title: l10n.sessionsCreateSectionLocation,
            children: [
              if (associationId != null)
                SpotPickerField(
                  associationId: associationId,
                  value: _spot,
                  lat: _position?.latitude,
                  lng: _position?.longitude,
                  onChanged: (spot) => setState(() {
                    _spot = spot;
                    _spotMissing = false;
                  }),
                ),
              if (_spotMissing)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 12),
                  child: Text(
                    l10n.spotsFieldRequired,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          NuniFormSection(
            title: l10n.sessionsCreateSectionType,
            children: [
              NuniSegmented<SessionKind>(
                segments: [
                  NuniSegment(
                    value: SessionKind.individual,
                    label: l10n.sessionsCreateKindIndividual,
                    icon: PhosphorIcons.golf,
                  ),
                  NuniSegment(
                    value: SessionKind.team,
                    label: l10n.sessionsCreateKindTeam,
                    icon: PhosphorIcons.users,
                  ),
                ],
                selected: _kind,
                onChanged: (kind) => setState(() => _kind = kind),
              ),
            ],
          ),
          const SizedBox(height: 24),
          NuniFormSection(
            title: l10n.sessionsCreateSectionScoring,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final mode in ScoringMode.values)
                    _ScoringModeChip(
                      label: _scoringModeLabel(mode, l10n),
                      selected: _scoringMode == mode,
                      onTap: () => setState(() => _scoringMode = mode),
                      onInfo: () => _showScoringInfo(mode),
                    ),
                ],
              ),
              if (_scoringMode == ScoringMode.free) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.sessionsCreateFreeDirectionLabel,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, _) {
                    final preference = ref.watch(
                      libreRankingDirectionPrefProvider,
                    );
                    final current =
                        preference.asData?.value ?? RankingDirection.desc;
                    return NuniSegmented<RankingDirection>(
                      segments: [
                        NuniSegment(
                          value: RankingDirection.desc,
                          label: l10n.sessionsCreateFreeDirectionHighest,
                        ),
                        NuniSegment(
                          value: RankingDirection.asc,
                          label: l10n.sessionsCreateFreeDirectionLowest,
                        ),
                      ],
                      selected: current,
                      onChanged: (direction) => ref
                          .read(libreRankingDirectionPrefProvider.notifier)
                          .set(direction),
                    );
                  },
                ),
              ],
            ],
          ),
          if (canTagChampionship) ...[
            const SizedBox(height: 16),
            NuniCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ChampionshipToggle(
                value: _isChampionship,
                onChanged: (value) => setState(() => _isChampionship = value),
              ),
            ),
          ],
        ],
      ),
      // The form's one action stays reachable without scrolling.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: NuniButton(
            label: l10n.sessionsCreateSubmit,
            onPressed: _creating ? null : _create,
          ),
        ),
      ),
    );
  }

  String _scoringModeLabel(ScoringMode mode, AppLocalizations l10n) =>
      switch (mode) {
        ScoringMode.strokePlay => l10n.sessionsScoringStrokePlay,
        ScoringMode.matchPlay => l10n.sessionsScoringMatchPlay,
        ScoringMode.redistribution => l10n.sessionsScoringRedistribution,
        ScoringMode.free => l10n.sessionsScoringFree,
      };
}

class _ScoringModeChip extends StatelessWidget {
  const _ScoringModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.onInfo,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NuniChip(label: label, selected: selected, onTap: onTap),
        IconButton(
          icon: Icon(
            PhosphorIcons.info,
            size: 18,
            color: context.nuni.primaryInk,
          ),
          visualDensity: VisualDensity.compact,
          onPressed: onInfo,
        ),
      ],
    );
  }
}
