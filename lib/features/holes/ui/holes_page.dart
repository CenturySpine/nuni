import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_chip.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_status_pill.dart';
import '../data/holes_repository.dart';
import '../domain/distance_format.dart';
import '../domain/hole.dart';
import 'hole_detail_sheet.dart';
import 'hole_photo_thumb.dart';

const _osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _osmUserAgent = 'org.centuryspine.nuni';
const _fallbackMapCenter = LatLng(48.8566, 2.3522);

enum _HolesMode { nearby, mine }

/// Holes tab body: directory and proximity search (plan 06). One mode
/// ("around me" within the chosen radius, or "all my holes") drives both the
/// list and map tabs -- same data, two views.
class HolesPage extends ConsumerStatefulWidget {
  const HolesPage({super.key});

  @override
  ConsumerState<HolesPage> createState() => _HolesPageState();
}

class _HolesPageState extends ConsumerState<HolesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  _HolesMode _mode = _HolesMode.nearby;
  // Live-updates the slider label while dragging; the committed radius (and
  // therefore the search) only changes on release, so dragging doesn't fire
  // an RPC call per pixel.
  int? _draggingRadiusM;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final positionAsync = ref.watch(myPositionProvider);
    final committedRadiusM =
        ref.watch(holesRadiusProvider).value ?? holesRadiusDefaultM;
    final displayRadiusM = _draggingRadiusM ?? committedRadiusM;
    final holesAsync = _mode == _HolesMode.nearby
        ? ref.watch(nearbyHolesProvider(committedRadiusM))
        : ref.watch(myHolesProvider);
    final locationFailed =
        _mode == _HolesMode.nearby &&
        positionAsync.hasValue &&
        positionAsync.value == null;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: NuniCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      NuniChip(
                        label: l10n.holesModeNearby,
                        selected: _mode == _HolesMode.nearby,
                        onTap: () => setState(() => _mode = _HolesMode.nearby),
                      ),
                      const SizedBox(width: 8),
                      NuniChip(
                        label: l10n.holesModeMine,
                        selected: _mode == _HolesMode.mine,
                        onTap: () => setState(() => _mode = _HolesMode.mine),
                      ),
                    ],
                  ),
                  if (_mode == _HolesMode.nearby) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.crosshair,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.holesRadiusLabel(
                            formatDistanceM(displayRadiusM.toDouble()),
                          ),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                    Slider(
                      value: displayRadiusM.toDouble(),
                      min: holesRadiusMinM.toDouble(),
                      max: holesRadiusMaxM.toDouble(),
                      divisions:
                          (holesRadiusMaxM - holesRadiusMinM) ~/
                          holesRadiusStepM,
                      label: formatDistanceM(displayRadiusM.toDouble()),
                      onChanged: (value) =>
                          setState(() => _draggingRadiusM = value.round()),
                      onChangeEnd: (value) {
                        setState(() => _draggingRadiusM = null);
                        ref
                            .read(holesRadiusProvider.notifier)
                            .set(value.round());
                      },
                    ),
                  ],
                  if (locationFailed) ...[
                    const SizedBox(height: 4),
                    NuniErrorBanner(
                      message: l10n.holesLocationUnavailable,
                      onRetry: () => ref.invalidate(myPositionProvider),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // Segmented-style tabs: muted track, white thumb (theme).
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.nuni.border,
                borderRadius: BorderRadius.circular(NuniRadius.control),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    height: 40,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(PhosphorIcons.list, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.holesListTab),
                      ],
                    ),
                  ),
                  Tab(
                    height: 40,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(PhosphorIcons.mapTrifold, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.holesMapTab),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: holesAsync.when(
              loading: () => const NuniLoading(),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: NuniErrorBanner(
                  message: describeError(error, l10n),
                  onRetry: () => ref.invalidate(
                    _mode == _HolesMode.nearby
                        ? nearbyHolesProvider(committedRadiusM)
                        : myHolesProvider,
                  ),
                ),
              ),
              data: (holes) => TabBarView(
                controller: _tabController,
                children: [
                  _HolesListView(
                    holes: holes,
                    emptyMessage: _mode == _HolesMode.nearby
                        ? l10n.holesNoneNearby(
                            formatDistanceM(committedRadiusM.toDouble()),
                          )
                        : l10n.holesNoneMine,
                  ),
                  _HolesMapView(holes: holes, myPosition: positionAsync.value),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/holes/new'),
        child: const Icon(PhosphorIcons.plus),
      ),
    );
  }
}

class _HolesListView extends ConsumerWidget {
  const _HolesListView({required this.holes, required this.emptyMessage});

  final List<Hole> holes;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Read lazily: a list without photos never needs the storage client.
    String? url(String? path) =>
        path == null ? null : ref.read(holesRepositoryProvider).photoUrl(path);
    if (holes.isEmpty) {
      return NuniEmptyState(icon: PhosphorIcons.mapPin, message: emptyMessage);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: holes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final hole = holes[index];
        return NuniCard(
          onTap: () => showHoleDetailSheet(context, hole.id),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Start and target photos, placeholders when missing (PO,
              // 2026-09-23).
              HolePhotoThumb(
                url: url(hole.photoStartPath),
                size: 48,
                iconSize: 18,
              ),
              const SizedBox(width: 6),
              HolePhotoThumb(
                url: url(hole.photoEndPath),
                size: 48,
                iconSize: 18,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hole.name,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        NuniStatusPill(
                          label: l10n.holesPar(hole.par),
                          tone: NuniTone.fairway,
                        ),
                        if (!hole.hasPosition)
                          NuniStatusPill(
                            label: l10n.holesPositionToSet,
                            tone: NuniTone.highlight,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (hole.distance != null) ...[
                const SizedBox(width: 8),
                NuniStatusPill(
                  label: l10n.holesAway(formatDistanceM(hole.distance!)),
                  icon: PhosphorIcons.navigationArrow,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _HolesMapView extends StatelessWidget {
  const _HolesMapView({required this.holes, required this.myPosition});

  final List<Hole> holes;
  final Position? myPosition;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Holes imported from LsgScores without a position yet (plan 13) only
    // show in the list, never on the map.
    final placed = [
      for (final hole in holes)
        if (hole.hasPosition) hole,
    ];
    final center = myPosition != null
        ? LatLng(myPosition!.latitude, myPosition!.longitude)
        : placed.isNotEmpty
        ? LatLng(placed.first.startLat!, placed.first.startLng!)
        : _fallbackMapCenter;

    return FlutterMap(
      options: MapOptions(initialCenter: center, initialZoom: 14),
      children: [
        TileLayer(
          urlTemplate: _osmTileUrl,
          userAgentPackageName: _osmUserAgent,
        ),
        MarkerLayer(
          markers: [
            if (myPosition != null)
              Marker(
                point: LatLng(myPosition!.latitude, myPosition!.longitude),
                width: 20,
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.onPrimary, width: 3),
                  ),
                ),
              ),
            for (final hole in placed)
              Marker(
                point: LatLng(hole.startLat!, hole.startLng!),
                width: 40,
                height: 40,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () => showHoleDetailSheet(context, hole.id),
                  child: Icon(
                    PhosphorIcons.mapPinFill,
                    color: scheme.secondary,
                    size: 36,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
