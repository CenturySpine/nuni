import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../../../core/errors/app_error_message.dart';
import '../../../core/geocoding/reverse_geocoding_client.dart';
import '../../../core/location/location_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../core/weather/weather_client.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_chip.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_form_section.dart';
import '../../../shared/nuni_list_card.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_segmented.dart';
import '../../associations/data/association_rights.dart';
import '../../associations/data/associations_repository.dart';
import '../../associations/ui/association_logo.dart';
import '../../history/data/history_repository.dart';
import '../../history/domain/schedule_validation.dart';
import '../../planning/data/events_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../spots/data/spots_repository.dart';
import '../../spots/domain/spot.dart';
import '../../spots/ui/spot_picker.dart';
import '../../spots/ui/spot_place_field.dart';
import '../../stats/data/stats_repository.dart';
import '../../stats/domain/eligible_session.dart';
import '../data/libre_ranking_direction_pref.dart';
import '../data/sessions_repository.dart';
import '../domain/ranking_direction.dart';
import '../domain/scoring_mode.dart';
import '../domain/session.dart';
import '../domain/session_kind.dart';
import '../domain/session_member.dart';
import '../domain/session_tag.dart';
import 'championship_toggle.dart';
import 'scoring_mode_label.dart';
import 'session_kind_label.dart';
import 'session_nature.dart';
import 'session_nature_rules.dart';
import 'scoring_mode_info_sheet.dart';

/// The session form (plan 31): `/session/new` creates a session,
/// `/session/:id/edit` edits one with the same screen, filled in.
///
/// Creation (plan 07): parameters only -- team composition happens
/// afterwards, in the waiting room. `/session/new?event=:id` (plan 23, Q164)
/// is the same form reached from "Start the session" on today's event: the
/// spot starts as the event's, and its "present" members join the waiting
/// room. The natures come first (plan 29, Q187): "Course" ticked by default,
/// the tags beside it; without "Course", no scorecard and the place may be a
/// free one (Q195). A session already held is entered afterwards with its
/// past date and times (Q206).
///
/// Editing: the name, place, date and times are the organizer's (Q207,
/// Q209); the association's staff changes the tags, report and
/// championship only. The scorecard never changes (Q193, Q208), and the
/// tags follow the rules of plan 29 (Q197), explained where they apply.
class SessionCreatePage extends ConsumerStatefulWidget {
  const SessionCreatePage({super.key, this.eventId, this.sessionId});

  final String? eventId;

  /// The session to edit; null to create one.
  final String? sessionId;

  @override
  ConsumerState<SessionCreatePage> createState() => _SessionCreatePageState();
}

class _SessionCreatePageState extends ConsumerState<SessionCreatePage> {
  SessionKind _kind = SessionKind.individual;
  ScoringMode _scoringMode = ScoringMode.strokePlay;
  bool _isChampionship = false;
  Spot? _spot;

  final _title = TextEditingController();
  final _report = TextEditingController();

  /// "Course" (plan 29): a scorecard; the tags beside it.
  bool _course = true;
  final _tags = <SessionTag>{};

  /// A free place instead of a spot (plan 29, Q195), without "Course" only.
  bool _freePlace = false;
  final _placeName = TextEditingController();
  SpotPlace? _place;

  /// Set once the place was touched in edit mode: only then is it sent.
  bool _placeChanged = false;

  /// Set once "Save" was tapped without a spot (or free place), to say
  /// it's missing.
  bool _spotMissing = false;

  /// A session already held (Q206): its date and times are typed in. Always
  /// on when editing a session that has a start.
  bool _afterwards = false;
  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  String? _scheduleError;

  Position? _position;
  bool _saving = false;

  /// Edit mode: the session as loaded, and what the caller may change.
  Session? _original;
  bool _isOwner = true;
  bool _isStaff = false;
  Object? _loadError;

  bool get _editing => widget.sessionId != null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = DateTime(now.year, now.month, now.day);
    _startTime = TimeOfDay.fromDateTime(now.subtract(const Duration(hours: 2)));
    _endTime = TimeOfDay.fromDateTime(now);
    unawaited(_detectLocation());
    if (_editing) {
      unawaited(_load());
    } else {
      unawaited(_prefillFromEvent());
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _report.dispose();
    _placeName.dispose();
    super.dispose();
  }

  /// Edit mode: fills the form with the session as it is.
  Future<void> _load() async {
    try {
      final repo = ref.read(sessionsRepositoryProvider);
      final session = await repo.fetchSession(widget.sessionId!);
      final role = await repo.myRole(session.id);
      final associationId = session.associationId;
      final isStaff =
          associationId != null &&
          await ref.read(canManageAssociationProvider(associationId).future);
      Spot? spot;
      if (session.spotId != null && associationId != null) {
        final spots = await ref.read(
          associationSpotsProvider(associationId).future,
        );
        spot = spots.where((s) => s.id == session.spotId).firstOrNull;
      }
      if (!mounted) return;
      setState(() {
        _original = session;
        _isOwner = role == MemberRole.owner;
        _isStaff = isStaff;
        _title.text = session.title ?? '';
        _report.text = session.comment ?? '';
        _course = session.hasScoring;
        _kind = session.kind ?? SessionKind.individual;
        _scoringMode = session.scoringMode ?? ScoringMode.strokePlay;
        _tags
          ..clear()
          ..addAll(session.tags);
        _isChampionship = session.isChampionship;
        _spot = spot;
        _freePlace = !session.hasScoring && session.spotId == null;
        if (_freePlace) {
          _placeName.text = session.zone ?? '';
          if (session.locationLat != null && session.locationLng != null) {
            _place = (
              lat: session.locationLat!,
              lng: session.locationLng!,
              address: null,
              city: session.city,
            );
          }
        }
        final startedAt = session.startedAt?.toLocal();
        if (startedAt != null) {
          final endedAt = (session.endedAt ?? DateTime.now()).toLocal();
          _afterwards = true;
          _date = DateTime(startedAt.year, startedAt.month, startedAt.day);
          _startTime = TimeOfDay.fromDateTime(startedAt);
          _endTime = TimeOfDay.fromDateTime(
            endedAt.isAfter(startedAt) ? endedAt : startedAt,
          );
        }
      });
    } catch (error) {
      if (mounted) setState(() => _loadError = error);
    }
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

  bool get _useFreePlace => !_course && _freePlace;

  /// What the caller may change in edit mode (Q209); everything when
  /// creating.
  bool get _canEditAll => !_editing || _isOwner;
  bool get _canEditTagsAndReport => !_editing || _isOwner || _isStaff;

  /// Whether the session as it would be saved is a game: only a game counts
  /// for the championship (plan 29).
  bool get _isGame => isGameSession(
    Session(
      id: '',
      code: '',
      ownerId: '',
      status: SessionStatus.draft,
      scoringMode: _course ? _scoringMode : null,
      tags: _tags.toList(),
      createdAt: DateTime(0),
    ),
  );

  /// Why [tag] can't change (plan 29, Q197), or null when it can.
  String? _tagLock(AppLocalizations l10n, SessionTag tag) {
    if (!_canEditTagsAndReport) return l10n.sessionsFormOwnerOnly;
    final original = _original;
    if (original == null) return null;
    return sessionTagLock(l10n, original, tag, isStaff: _isStaff);
  }

  /// The end time is typed in for a session already held; a session being
  /// played gets its end from "End the session".
  bool get _showEnd {
    final original = _original;
    return original == null ||
        original.status == SessionStatus.completed ||
        original.endedAt != null ||
        original.startedAt == null;
  }

  DateTime _at(TimeOfDay time) =>
      DateTime(_date.year, _date.month, _date.day, time.hour, time.minute);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime({required bool start}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? _startTime : _endTime,
    );
    if (picked == null) return;
    setState(() => start ? _startTime = picked : _endTime = picked);
  }

  String _scheduleErrorMessage(AppLocalizations l10n, ScheduleError error) =>
      switch (error) {
        ScheduleError.startInFuture => l10n.historyEditStartInFuture,
        ScheduleError.endInFuture => l10n.historyEditEndInFuture,
        ScheduleError.endBeforeStart => l10n.historyEditEndBeforeStart,
      };

  /// Checks the form; false (with the reason shown) when it can't be saved.
  bool _validate(AppLocalizations l10n) {
    if (!_course && _tags.isEmpty) return false;
    final placeMissing = _useFreePlace
        ? (_place == null || _placeName.text.trim().isEmpty)
        : _spot == null;
    if ((!_editing || _placeChanged) && placeMissing) {
      setState(() => _spotMissing = true);
      return false;
    }
    if (_afterwards && _canEditAll) {
      final error = validateSchedule(
        startedAt: _at(_startTime),
        endedAt: _showEnd ? _at(_endTime) : DateTime.now(),
        now: DateTime.now(),
      );
      setState(
        () => _scheduleError = error == null
            ? null
            : _scheduleErrorMessage(l10n, error),
      );
      if (error != null) return false;
    }
    return true;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_validate(l10n)) return;
    setState(() => _saving = true);
    try {
      if (_editing) {
        await _update();
      } else {
        await _create();
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(switch (error.message) {
              // No approved association (plan 18, Q81): normally caught
              // earlier by the screen, but it may have changed meanwhile.
              'association_required' => l10n.sessionsCreateNeedsAssociation,
              // Plan 23, Q164: no longer the event's day, or in charge of it.
              'event_not_startable' => l10n.planningErrorNotStartable,
              // Plan 28: the spot was deleted, or belongs elsewhere.
              'spot_required' ||
              'spot_not_in_association' => l10n.spotsFieldRequired,
              'invalid_schedule' => l10n.historyEditEndBeforeStart,
              _ => sessionNatureErrorMessage(error, l10n),
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
      if (mounted) setState(() => _saving = false);
    }
  }

  /// The session's point and city for the place chosen: where its creator
  /// stands on a spot (the spot's own point otherwise, set by the base);
  /// the event's for a spot with a variable location (Q186), whose city is
  /// found from it; the free place's own.
  Future<({double? lat, double? lng, String? city})> _point() async {
    if (_useFreePlace) {
      return (lat: _place!.lat, lng: _place!.lng, city: _place!.city);
    }
    final languageCode = Localizations.localeOf(context).languageCode;
    var lat = _editing ? null : _position?.latitude;
    var lng = _editing ? null : _position?.longitude;
    String? city;
    if (_spot!.variableLocation) {
      final event = widget.eventId == null
          ? null
          : ref.read(eventByIdProvider(widget.eventId!)).value;
      if (event != null && event.hasLocation) {
        lat = event.locationLat;
        lng = event.locationLng;
      }
      lat ??= _original?.locationLat ?? _position?.latitude;
      lng ??= _original?.locationLng ?? _position?.longitude;
      if (lat != null && lng != null) {
        city = await ref
            .read(reverseGeocodingClientProvider)
            .cityFor(lat: lat, lng: lng, languageCode: languageCode);
      }
    }
    return (lat: lat, lng: lng, city: city);
  }

  String? get _titleValue {
    final title = _title.text.trim();
    return title.isEmpty ? null : title;
  }

  String? get _reportValue {
    final report = _report.text.trim();
    return report.isEmpty ? null : report;
  }

  Future<void> _create() async {
    final implied = _scoringMode.impliedRankingDirection;
    final RankingDirection rankingDirection =
        implied ?? await ref.read(libreRankingDirectionPrefProvider.future);
    final point = await _point();

    final repo = ref.read(sessionsRepositoryProvider);
    final session = await repo.create(
      kind: _course ? _kind : null,
      scoringMode: _course ? _scoringMode : null,
      rankingDirection: _course ? rankingDirection : null,
      tags: _tags,
      spotId: _useFreePlace ? null : _spot!.id,
      zone: _useFreePlace ? _placeName.text.trim() : null,
      city: point.city,
      lat: point.lat,
      lng: point.lng,
      eventId: widget.eventId,
      title: _titleValue,
      comment: _reportValue,
      startedAt: _afterwards ? _at(_startTime) : null,
      endedAt: _afterwards ? _at(_endTime) : null,
    );
    if (widget.eventId != null) {
      ref.invalidate(eventSessionsProvider(widget.eventId!));
    }
    // A session already held: its weather from the archives (Q206).
    if (_afterwards) unawaited(_captureArchiveWeather(session));

    var tagged = session;
    if (_isChampionship && _isGame) {
      tagged = await repo.setChampionship(
        sessionId: session.id,
        isChampionship: true,
      );
      await _confirmChampionship(tagged);
    }

    // Home's "Mes sessions en cours" list is a plain Future provider kept
    // alive by the bottom-nav IndexedStack, so it won't pick up the new
    // session on its own.
    ref.invalidate(myOngoingSessionsProvider);
    if (mounted) context.go('/session/${tagged.id}');
  }

  Future<void> _update() async {
    final original = _original!;
    final repo = ref.read(sessionsRepositoryProvider);
    final tagsChanged =
        _tags.length != original.tags.length ||
        !_tags.containsAll(original.tags);
    final newStart = _afterwards && _canEditAll ? _at(_startTime) : null;
    final newEnd = _afterwards && _canEditAll && _showEnd
        ? _at(_endTime)
        : null;
    final startChanged =
        newStart != null &&
        (original.startedAt == null ||
            !_sameMinute(original.startedAt!.toLocal(), newStart));
    final placeChanged = _canEditAll && _placeChanged;
    final point = placeChanged
        ? await _point()
        : (lat: null, lng: null, city: null);

    var saved = await repo.updateSession(
      sessionId: original.id,
      setTitle: _canEditAll,
      title: _titleValue,
      setComment: _canEditTagsAndReport,
      comment: _reportValue,
      tags: tagsChanged ? _tags : null,
      placeChanged: placeChanged,
      spotId: _useFreePlace ? null : _spot?.id,
      zone: _useFreePlace ? _placeName.text.trim() : null,
      city: point.city,
      lat: point.lat,
      lng: point.lng,
      startedAt: newStart,
      endedAt: newEnd,
    );
    // New day or new place: the weather of then and there (plan 10's rule).
    if ((startChanged || placeChanged) && saved.startedAt != null) {
      await _captureArchiveWeather(saved);
    }

    final championship = _isChampionship && _isGame;
    if (_canTagChampionship(saved) && championship != original.isChampionship) {
      saved = await repo.setChampionship(
        sessionId: original.id,
        isChampionship: championship,
      );
      if (championship) await _confirmChampionship(saved);
    }

    ref
      ..invalidate(sessionRoomProvider(original.id))
      ..invalidate(historyDetailProvider(original.id))
      ..invalidate(historyEntriesProvider)
      ..invalidate(myOngoingSessionsProvider)
      ..invalidate(myRecentSessionsProvider);
    // The natures and dates decide what counts where (plan 29).
    final myPlayerId = ref.read(myPlayerProvider).value?.id;
    if (myPlayerId != null) ref.invalidate(playerHistoryProvider(myPlayerId));
    if (mounted) context.pop(true);
  }

  static bool _sameMinute(DateTime a, DateTime b) =>
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day &&
      a.hour == b.hour &&
      a.minute == b.minute;

  bool _canTagChampionship(Session session) {
    final associationId = session.associationId;
    return associationId != null &&
        (ref.read(canManageAssociationProvider(associationId)).value ?? false);
  }

  /// Best-effort and silent, like every weather capture of the app.
  Future<void> _captureArchiveWeather(Session session) async {
    final lat = session.locationLat;
    final lng = session.locationLng;
    final startedAt = session.startedAt;
    if (lat == null || lng == null || startedAt == null) return;
    final weather = await ref
        .read(weatherClientProvider)
        .fetchArchive(lat: lat, lng: lng, date: startedAt.toLocal());
    if (weather != null) {
      await ref
          .read(sessionsRepositoryProvider)
          .attachWeather(session.id, weather);
    }
  }

  Future<void> _confirmChampionship(Session tagged) async {
    if (!mounted) return;
    final associationLabel = tagged.associationId == null
        ? null
        : (await ref.read(
            associationByIdProvider(tagged.associationId!).future,
          ))?.label;
    if (mounted) {
      await showChampionshipTagConfirmation(
        context,
        associationLabel: associationLabel,
        season: tagged.championshipSeason ?? '',
      );
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
    final pageTitle = _editing
        ? l10n.historyEditTitle
        : l10n.sessionsCreateTitle;

    if (_editing && _original == null) {
      return Scaffold(
        appBar: AppBar(title: Text(pageTitle)),
        body: _loadError == null
            ? const NuniLoading()
            : Padding(
                padding: const EdgeInsets.all(16),
                child: NuniErrorBanner(
                  message: describeError(_loadError!, l10n),
                  onRetry: () {
                    setState(() => _loadError = null);
                    unawaited(_load());
                  },
                ),
              ),
      );
    }

    final player = ref.watch(myPlayerProvider).value;
    final associationId = _original?.associationId ?? player?.associationId;
    final event = widget.eventId == null
        ? null
        : ref.watch(eventByIdProvider(widget.eventId!)).value;
    final association = associationId == null
        ? null
        : ref.watch(associationByIdProvider(associationId)).value;
    // Only the local staff or a super_admin tags the championship (plan 26,
    // decision 11): the toggle isn't offered to anyone else.
    final canTagChampionship =
        associationId != null &&
        (ref.watch(canManageAssociationProvider(associationId)).value ?? false);

    // Only an approved association's member creates sessions (plan 18, Q81).
    if (!_editing && player != null && player.associationId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(pageTitle)),
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

    final hint = Theme.of(context).textTheme.bodySmall;
    final errorStyle = hint?.copyWith(
      color: Theme.of(context).colorScheme.error,
    );
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),
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
          if (_editing && !_canEditAll) ...[
            Text(l10n.sessionsFormOwnerOnly, style: hint),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _title,
            enabled: _canEditAll,
            maxLength: 80,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.sessionsFormTitleLabel,
              hintText: l10n.sessionsFormTitleHint,
            ),
          ),
          const SizedBox(height: 16),
          NuniFormSection(
            title: l10n.sessionsCreateSectionNature,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  NuniChip(
                    label: l10n.sessionNatureCourse,
                    selected: _course,
                    // Frozen once created (Q193).
                    onTap: _editing
                        ? null
                        : () => setState(() => _course = !_course),
                  ),
                  for (final tag in SessionTag.values)
                    NuniChip(
                      label: sessionTagLabel(l10n, tag),
                      selected: _tags.contains(tag),
                      onTap: _tagLock(l10n, tag) != null
                          ? null
                          : () => setState(() {
                              if (!_tags.remove(tag)) _tags.add(tag);
                            }),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (!_course && _tags.isEmpty)
                Text(l10n.sessionsCreateNatureRequired, style: errorStyle)
              else
                Text(
                  _editing ? _natureLocks(l10n) : l10n.sessionsCreateNatureHint,
                  style: hint,
                ),
            ],
          ),
          const SizedBox(height: 24),
          NuniFormSection(
            title: l10n.sessionsCreateSectionLocation,
            children: [
              if (!_course) ...[
                NuniSegmented<bool>(
                  segments: [
                    NuniSegment(
                      value: false,
                      label: l10n.sessionsCreatePlaceSpot,
                      icon: PhosphorIcons.golf,
                    ),
                    NuniSegment(
                      value: true,
                      label: l10n.sessionsCreatePlaceFree,
                      icon: PhosphorIcons.mapPin,
                    ),
                  ],
                  selected: _freePlace,
                  onChanged: _canEditAll
                      ? (value) => setState(() {
                          _freePlace = value;
                          _placeChanged = true;
                          _spotMissing = false;
                        })
                      : null,
                ),
                const SizedBox(height: 12),
              ],
              if (_useFreePlace) ...[
                TextField(
                  controller: _placeName,
                  enabled: _canEditAll,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.sessionsCreatePlaceNameLabel,
                    hintText: l10n.sessionsCreatePlaceNameHint,
                  ),
                  onChanged: (_) => setState(() {
                    _placeChanged = true;
                    _spotMissing = false;
                  }),
                ),
                const SizedBox(height: 12),
                IgnorePointer(
                  ignoring: !_canEditAll,
                  child: SpotPlaceField(
                    value: _place,
                    initialCenter: _position != null
                        ? LatLng(_position!.latitude, _position!.longitude)
                        : association == null
                        ? null
                        : LatLng(
                            association.locationLat,
                            association.locationLng,
                          ),
                    onChanged: (place) => setState(() {
                      _place = place;
                      _placeChanged = true;
                      _spotMissing = false;
                    }),
                  ),
                ),
              ] else if (associationId != null)
                IgnorePointer(
                  ignoring: !_canEditAll,
                  child: SpotPickerField(
                    associationId: associationId,
                    value: _spot,
                    lat: _position?.latitude,
                    lng: _position?.longitude,
                    onChanged: (spot) => setState(() {
                      _spot = spot;
                      _placeChanged = true;
                      _spotMissing = false;
                    }),
                  ),
                ),
              if (_spotMissing)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 12),
                  child: Text(
                    _useFreePlace
                        ? l10n.sessionsCreatePlaceRequired
                        : l10n.spotsFieldRequired,
                    style: errorStyle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          NuniFormSection(
            title: l10n.sessionsFormSectionWhen,
            children: [
              // A session with a start always shows it; otherwise "now" (the
              // start) or a session already held (Q206).
              if (!(_editing && _original!.startedAt != null))
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.sessionsFormAfterwards),
                  subtitle: Text(
                    _afterwards
                        ? l10n.sessionsFormAfterwardsHint
                        : l10n.sessionsFormNow,
                  ),
                  value: _afterwards,
                  onChanged: _canEditAll
                      ? (value) => setState(() => _afterwards = value)
                      : null,
                ),
              if (_afterwards) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: _canEditAll,
                  leading: const Icon(PhosphorIcons.calendarBlank),
                  title: Text(l10n.historyEditDateLabel),
                  subtitle: Text(DateFormat.yMMMMd(locale).format(_date)),
                  onTap: _pickDate,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: _canEditAll,
                  leading: const Icon(PhosphorIcons.clock),
                  title: Text(l10n.historyEditStartTimeLabel),
                  subtitle: Text(_startTime.format(context)),
                  onTap: () => _pickTime(start: true),
                ),
                if (_showEnd)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled: _canEditAll,
                    leading: const Icon(PhosphorIcons.clock),
                    title: Text(l10n.historyEditEndTimeLabel),
                    subtitle: Text(_endTime.format(context)),
                    onTap: () => _pickTime(start: false),
                  ),
                if (_scheduleError != null)
                  Text(_scheduleError!, style: errorStyle),
              ],
            ],
          ),
          if (_course) ...[
            const SizedBox(height: 24),
            if (_editing)
              _FrozenScorecard(session: _original!)
            else
              ..._scorecardSections(context, l10n),
          ],
          const SizedBox(height: 24),
          NuniFormSection(
            title: l10n.sessionsReportTitle,
            children: [
              TextField(
                controller: _report,
                enabled: _canEditTagsAndReport,
                minLines: 3,
                maxLines: 10,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(hintText: l10n.sessionsReportHint),
              ),
            ],
          ),
          if (canTagChampionship) ...[
            const SizedBox(height: 16),
            NuniCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ChampionshipToggle(
                value: _isChampionship && _isGame,
                // Only a game counts (plan 29).
                onChanged: _isGame
                    ? (value) => setState(() => _isChampionship = value)
                    : null,
                subtitle: _isGame ? null : l10n.sessionsChampionshipGameOnly,
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
            label: _editing ? l10n.commonSave : l10n.sessionsCreateSubmit,
            onPressed: _saving || (!_course && _tags.isEmpty) ? null : _save,
          ),
        ),
      ),
    );
  }

  /// In edit mode, why some natures can't change (plan 29): the scorecard
  /// is set at creation, and each locked tag says why.
  String _natureLocks(AppLocalizations l10n) {
    final reasons = <String>{
      if (_course) l10n.sessionsNatureFrozen,
      for (final tag in SessionTag.values) ?_tagLock(l10n, tag),
      // Training with a scorecard moves the session in or out of the
      // statistics (plan 29).
      if (_course && _tagLock(l10n, SessionTag.training) == null)
        l10n.sessionsNatureSensitiveHint,
    };
    return reasons.isEmpty ? l10n.sessionsCreateNatureHint : reasons.join(' ');
  }

  List<Widget> _scorecardSections(
    BuildContext context,
    AppLocalizations l10n,
  ) => [
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
                label: scoringModeLabel(l10n, mode),
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
              final preference = ref.watch(libreRankingDirectionPrefProvider);
              final current = preference.asData?.value ?? RankingDirection.desc;
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
  ];
}

/// The scorecard of a session being edited: set at creation, never changed
/// (Q193, Q208), shown read-only with the reason.
class _FrozenScorecard extends StatelessWidget {
  const _FrozenScorecard({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mode = session.scoringMode!;
    var modeLine = scoringModeLabel(l10n, mode);
    if (mode == ScoringMode.free) {
      modeLine +=
          ' · ${session.rankingDirection == RankingDirection.desc ? l10n.sessionsCreateFreeDirectionHighest : l10n.sessionsCreateFreeDirectionLowest}';
    }
    return NuniFormSection(
      title: l10n.sessionsCreateSectionScoring,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          enabled: false,
          leading: Icon(
            session.kind == SessionKind.team
                ? PhosphorIcons.users
                : PhosphorIcons.golf,
          ),
          title: Text('${sessionKindLabel(l10n, session.kind!)} · $modeLine'),
          subtitle: Text(l10n.sessionsNatureFrozen),
        ),
      ],
    );
  }
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
