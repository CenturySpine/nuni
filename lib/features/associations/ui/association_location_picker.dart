import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../shared/nuni_map_attribution.dart';

/// Centre of France: where the map opens when neither a position nor a
/// previous point is known.
const _franceCenter = LatLng(46.6, 2.4);

/// Places an association's city on a map (plan 18, Q83): a tap sets the
/// point. Opens on [value] if set, else on [initialCenter] (the user's
/// position), else on France.
class AssociationLocationPicker extends StatelessWidget {
  const AssociationLocationPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.initialCenter,
  });

  final LatLng? value;
  final ValueChanged<LatLng> onChanged;
  final LatLng? initialCenter;

  @override
  Widget build(BuildContext context) {
    final center = value ?? initialCenter;
    return ClipRRect(
      borderRadius: BorderRadius.circular(NuniRadius.control),
      child: SizedBox(
        height: 260,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center ?? _franceCenter,
            initialZoom: center == null ? 5 : 11,
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
