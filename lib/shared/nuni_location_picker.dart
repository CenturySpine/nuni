import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/phosphor_icons.dart';
import 'nuni_map_attribution.dart';

/// Centre of France: where the map opens when neither a position nor a
/// previous point is known.
const _franceCenter = LatLng(46.6, 2.4);

/// Places one point on an OpenStreetMap map: an association's city (plan 18,
/// Q83) or an event's precise spot (plan 23). A tap sets the point. Opens on
/// [value] if set, else on [initialCenter] (the user's position), else on
/// France. The view follows [value] only when built: give the widget a new
/// key to recentre it on a point set from outside.
class NuniLocationPicker extends StatelessWidget {
  const NuniLocationPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.initialCenter,
    this.height = 260,
    this.zoom = 11,
    this.centerZoom = 11,
  });

  final LatLng? value;
  final ValueChanged<LatLng> onChanged;
  final LatLng? initialCenter;
  final double height;

  /// Zoom when opening on a known point.
  final double zoom;

  /// Zoom when opening on [initialCenter] (no point yet).
  final double centerZoom;

  @override
  Widget build(BuildContext context) {
    final center = value ?? initialCenter;
    return ClipRRect(
      borderRadius: BorderRadius.circular(NuniRadius.control),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center ?? _franceCenter,
            initialZoom: value != null
                ? zoom
                : initialCenter != null
                ? centerZoom
                : 5,
            onTap: (tapPosition, point) => onChanged(point),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'org.centuryspine.nuni',
            ),
            if (value != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: value!,
                    width: 40,
                    height: 40,
                    alignment: Alignment.topCenter,
                    child: Icon(
                      PhosphorIcons.mapPinFill,
                      color: context.nuni.primaryInk,
                      size: 36,
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
