import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_grouped_list.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_map_attribution.dart';
import '../../../shared/nuni_status_pill.dart';
import '../../associations/data/association_rights.dart';
import '../data/spots_repository.dart';
import '../domain/spot.dart';

/// `/associations/:id/spots` (plan 28): the association's spots, on a map
/// and in a list. Anyone reads it (PO, 2026-09-25, extending Q180); its staff
/// add, edit and delete spots.
class SpotsPage extends ConsumerWidget {
  const SpotsPage({super.key, required this.associationId});

  final String associationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final canManage =
        ref.watch(canManageAssociationProvider(associationId)).value ?? false;
    final spots = ref.watch(associationSpotsProvider(associationId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.spotsTitle)),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () =>
                  context.push('/associations/$associationId/spots/new'),
              icon: const Icon(PhosphorIcons.plus),
              label: Text(l10n.spotsAdd),
            )
          : null,
      body: spots.when(
        data: (spots) => spots.isEmpty
            ? NuniEmptyState(
                icon: PhosphorIcons.mapPin,
                message: canManage ? l10n.spotsEmptyManager : l10n.spotsEmpty,
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(associationSpotsProvider(associationId).future),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    if (spots.any((s) => s.hasLocation)) ...[
                      _SpotsMap(spots: spots),
                      const SizedBox(height: 16),
                    ],
                    NuniGroupedList(
                      children: [
                        for (final spot in spots)
                          _SpotTile(
                            spot: spot,
                            canManage: canManage,
                            onTap: canManage
                                ? () => context.push(
                                    '/associations/$associationId/spots/${spot.id}',
                                  )
                                : null,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
        loading: () => const NuniLoading(),
        error: (error, _) =>
            NuniErrorBanner(message: describeError(error, l10n)),
      ),
    );
  }
}

class _SpotTile extends StatelessWidget {
  const _SpotTile({required this.spot, required this.canManage, this.onTap});

  final Spot spot;
  final bool canManage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(PhosphorIcons.mapPin, color: context.nuni.primaryInk),
      title: Text(spot.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (spot.variableLocation)
            Text(l10n.spotsVariableLabel)
          else if (spot.address != null)
            Text(spot.address!),
          if (spot.description != null)
            Text(
              spot.description!,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          // Only the staff can complete it: nothing to say to the others.
          if (canManage && spot.isIncomplete)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: NuniStatusPill(
                label: l10n.spotsIncomplete,
                tone: NuniTone.sunshine,
                icon: PhosphorIcons.warningCircle,
              ),
            ),
        ],
      ),
      trailing: onTap == null
          ? null
          : const Icon(PhosphorIcons.pencilSimple, size: 18),
      onTap: onTap,
    );
  }
}

/// Every placed spot on one map, framed to show them all.
class _SpotsMap extends StatelessWidget {
  const _SpotsMap({required this.spots});

  final List<Spot> spots;

  @override
  Widget build(BuildContext context) {
    final placed = [
      for (final spot in spots)
        if (spot.hasLocation) spot,
    ];
    final points = [
      for (final spot in placed) LatLng(spot.locationLat!, spot.locationLng!),
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(NuniRadius.card),
      child: SizedBox(
        height: 260,
        child: FlutterMap(
          // The framing is only read when built: rebuilt when a point moves.
          key: ValueKey(Object.hashAll(points)),
          options: points.length == 1
              ? MapOptions(initialCenter: points.single, initialZoom: 15)
              : MapOptions(
                  initialCameraFit: CameraFit.coordinates(
                    coordinates: points,
                    padding: const EdgeInsets.all(40),
                    maxZoom: 16,
                  ),
                ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'org.centuryspine.nuni',
            ),
            MarkerLayer(
              markers: [
                for (final spot in placed)
                  Marker(
                    point: LatLng(spot.locationLat!, spot.locationLng!),
                    width: 40,
                    height: 40,
                    alignment: Alignment.topCenter,
                    child: Tooltip(
                      message: spot.name,
                      child: Icon(
                        PhosphorIcons.mapPinFill,
                        color: context.nuni.primaryInk,
                        size: 36,
                      ),
                    ),
                  ),
              ],
            ),
            const NuniMapAttribution(),
          ],
        ),
      ),
    );
  }
}
