import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/geocoding/reverse_geocoding_client.dart';
import '../../../core/location/location_service.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../core/weather/weather.dart';
import '../../../core/weather/weather_client.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_chip.dart';
import '../../../shared/nuni_form_section.dart';
import '../data/libre_ranking_direction_pref.dart';
import '../data/sessions_repository.dart';
import '../domain/ranking_direction.dart';
import '../domain/scoring_mode.dart';
import '../domain/session_kind.dart';
import 'scoring_mode_info_sheet.dart';

/// `/session/new` (plan 07): parameters only -- team composition happens
/// afterwards, in the waiting room (`SessionRoomPage`).
class SessionCreatePage extends ConsumerStatefulWidget {
  const SessionCreatePage({super.key});

  @override
  ConsumerState<SessionCreatePage> createState() => _SessionCreatePageState();
}

class _SessionCreatePageState extends ConsumerState<SessionCreatePage> {
  final _cityController = TextEditingController();
  final _zoneController = TextEditingController();
  Timer? _zoneDebounce;
  String _debouncedCity = '';

  SessionKind _kind = SessionKind.individual;
  ScoringMode _scoringMode = ScoringMode.strokePlay;

  Position? _position;
  Weather? _weather;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _cityController.addListener(_onCityChanged);
    unawaited(_detectLocation());
  }

  @override
  void dispose() {
    _zoneDebounce?.cancel();
    _cityController.removeListener(_onCityChanged);
    _cityController.dispose();
    _zoneController.dispose();
    super.dispose();
  }

  void _onCityChanged() {
    _zoneDebounce?.cancel();
    _zoneDebounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _debouncedCity = _cityController.text.trim());
    });
  }

  Future<void> _detectLocation() async {
    final position = await ref
        .read(locationServiceProvider)
        .getCurrentPosition();
    if (!mounted || position == null) return;
    setState(() => _position = position);

    final languageCode = Localizations.localeOf(context).languageCode;
    final city = await ref
        .read(reverseGeocodingClientProvider)
        .cityFor(
          lat: position.latitude,
          lng: position.longitude,
          languageCode: languageCode,
        );
    if (mounted && city != null && _cityController.text.isEmpty) {
      _cityController.text = city;
      _onCityChanged();
    }

    final weather = await ref
        .read(weatherClientProvider)
        .fetch(lat: position.latitude, lng: position.longitude);
    if (mounted) setState(() => _weather = weather);
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
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

      final city = _cityController.text.trim();
      final zone = _zoneController.text.trim();
      final repo = ref.read(sessionsRepositoryProvider);
      final session = await repo.create(
        kind: _kind,
        scoringMode: _scoringMode,
        rankingDirection: rankingDirection,
        city: city.isEmpty ? null : city,
        zone: zone.isEmpty ? null : zone,
        lat: _position?.latitude,
        lng: _position?.longitude,
      );

      final weather = _weather;
      if (weather != null) {
        await repo.attachWeather(session.id, weather);
      }

      // Home's "Mes sessions en cours" list is a plain Future provider kept
      // alive by the bottom-nav IndexedStack (never disposed by navigating
      // away), so it won't pick up the new session on its own.
      ref.invalidate(myOngoingSessionsProvider);
      if (mounted) context.go('/session/${session.id}');
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
    final zoneSuggestions = ref.watch(zoneSuggestionsProvider(_debouncedCity));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionsCreateTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          NuniFormSection(
            title: l10n.sessionsCreateSectionLocation,
            children: [
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: l10n.sessionsCreateCityLabel,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _zoneController,
                decoration: InputDecoration(
                  labelText: l10n.sessionsCreateZoneLabel,
                ),
              ),
              zoneSuggestions.when(
                data: (zones) => zones.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final zone in zones)
                              NuniChip(
                                label: zone,
                                onTap: () =>
                                    setState(() => _zoneController.text = zone),
                              ),
                          ],
                        ),
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          NuniFormSection(
            title: l10n.sessionsCreateSectionType,
            children: [
              Row(
                children: [
                  NuniChip(
                    label: l10n.sessionsCreateKindIndividual,
                    selected: _kind == SessionKind.individual,
                    onTap: () => setState(() => _kind = SessionKind.individual),
                  ),
                  const SizedBox(width: 8),
                  NuniChip(
                    label: l10n.sessionsCreateKindTeam,
                    selected: _kind == SessionKind.team,
                    onTap: () => setState(() => _kind = SessionKind.team),
                  ),
                ],
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
                    return Row(
                      children: [
                        NuniChip(
                          label: l10n.sessionsCreateFreeDirectionHighest,
                          selected: current == RankingDirection.desc,
                          onTap: () => ref
                              .read(libreRankingDirectionPrefProvider.notifier)
                              .set(RankingDirection.desc),
                        ),
                        const SizedBox(width: 8),
                        NuniChip(
                          label: l10n.sessionsCreateFreeDirectionLowest,
                          selected: current == RankingDirection.asc,
                          onTap: () => ref
                              .read(libreRankingDirectionPrefProvider.notifier)
                              .set(RankingDirection.asc),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          NuniButton(
            label: l10n.sessionsCreateSubmit,
            onPressed: _creating ? null : _create,
          ),
        ],
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
          icon: const Icon(PhosphorIcons.info, size: 18),
          visualDensity: VisualDensity.compact,
          onPressed: onInfo,
        ),
      ],
    );
  }
}
