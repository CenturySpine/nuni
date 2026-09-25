import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/geocoding/place_geocoding_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_location_picker.dart';
import '../../associations/data/associations_repository.dart';
import '../../associations/domain/association.dart';
import '../data/spots_repository.dart';
import '../domain/spot.dart';

/// The session form's spot field (plan 28): the chosen spot, required, and a
/// "+" that adds a missing one to the association's spots on the spot (Q180).
class SpotPickerField extends ConsumerWidget {
  const SpotPickerField({
    super.key,
    required this.associationId,
    required this.value,
    required this.onChanged,
    this.lat,
    this.lng,
  });

  final String associationId;
  final Spot? value;
  final ValueChanged<Spot> onChanged;

  /// The creator's position, when known: nearest spots first, and the point
  /// of a spot added with "+".
  final double? lat;
  final double? lng;

  Future<void> _pick(BuildContext context) async {
    final spot = await showModalBottomSheet<Spot>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) =>
          _SpotPickerSheet(associationId: associationId, lat: lat, lng: lng),
    );
    if (spot != null) onChanged(spot);
  }

  Future<void> _add(BuildContext context) async {
    final spot = await showQuickSpotSheet(
      context,
      associationId: associationId,
      lat: lat,
      lng: lng,
    );
    if (spot != null) onChanged(spot);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final spot = value;
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(NuniRadius.control),
            onTap: () => _pick(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.spotsFieldLabel,
                prefixIcon: Icon(
                  PhosphorIcons.mapPin,
                  color: context.nuni.primaryInk,
                ),
                suffixIcon: const Icon(PhosphorIcons.caretRight, size: 18),
              ),
              child: Text(
                spot?.name ?? l10n.spotsFieldChoose,
                style: spot == null
                    ? TextStyle(color: scheme.onSurfaceVariant)
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: l10n.spotsQuickAdd,
          icon: const Icon(PhosphorIcons.plus),
          onPressed: () => _add(context),
        ),
      ],
    );
  }
}

/// The association's spots, nearest first, filtered as one types; a name
/// that matches none offers to add it.
class _SpotPickerSheet extends ConsumerStatefulWidget {
  const _SpotPickerSheet({required this.associationId, this.lat, this.lng});

  final String associationId;
  final double? lat;
  final double? lng;

  @override
  ConsumerState<_SpotPickerSheet> createState() => _SpotPickerSheetState();
}

class _SpotPickerSheetState extends ConsumerState<_SpotPickerSheet> {
  String _query = '';

  Future<void> _add() async {
    final spot = await showQuickSpotSheet(
      context,
      associationId: widget.associationId,
      initialName: _query.trim(),
      lat: widget.lat,
      lng: widget.lng,
    );
    if (spot != null && mounted) Navigator.of(context).pop(spot);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spots =
        ref.watch(associationSpotsProvider(widget.associationId)).value ??
        const <Spot>[];
    final key = spotNameKey(_query);
    final shown = sortSpots(
      [
        for (final spot in spots)
          if (spotNameKey(spot.name).contains(key)) spot,
      ],
      lat: widget.lat,
      lng: widget.lng,
    );
    final exact = spotNamed(spots, _query) != null;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.spotsSearchHint,
                  prefixIcon: const Icon(
                    PhosphorIcons.magnifyingGlass,
                    size: 20,
                  ),
                ),
                onChanged: (text) => setState(() => _query = text),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final spot in shown)
                    ListTile(
                      leading: const Icon(PhosphorIcons.mapPin),
                      title: Text(spot.name),
                      subtitle: _distance(spot, l10n) == null
                          ? null
                          : Text(_distance(spot, l10n)!),
                      onTap: () => Navigator.of(context).pop(spot),
                    ),
                  if (shown.isEmpty && _query.trim().isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.spotsNoneYet),
                    ),
                  if (!exact)
                    ListTile(
                      leading: Icon(
                        PhosphorIcons.plus,
                        color: context.nuni.primaryInk,
                      ),
                      title: Text(
                        _query.trim().isEmpty
                            ? l10n.spotsQuickAdd
                            : l10n.spotsQuickAddNamed(_query.trim()),
                      ),
                      onTap: _add,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _distance(Spot spot, AppLocalizations l10n) {
    final lat = widget.lat;
    final lng = widget.lng;
    if (lat == null || lng == null || !spot.hasLocation) return spot.address;
    final km = distanceKm(lat, lng, spot.locationLat!, spot.locationLng!);
    final distance = km < 1
        ? l10n.spotsDistanceM((km * 1000).round())
        : l10n.spotsDistanceKm(
            NumberFormat(
              '0.0',
              Localizations.localeOf(context).toString(),
            ).format(km),
          );
    return spot.address == null ? distance : '$distance · ${spot.address}';
  }
}

/// The "+" of the session form (plan 28, Q180, Q181): a name, and the
/// creator's position as the point -- or, without one, a point placed on
/// the map. The address is looked up for it. Returns the spot created.
Future<Spot?> showQuickSpotSheet(
  BuildContext context, {
  required String associationId,
  String initialName = '',
  double? lat,
  double? lng,
}) => showModalBottomSheet<Spot>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => _QuickSpotSheet(
    associationId: associationId,
    initialName: initialName,
    position: lat == null || lng == null ? null : LatLng(lat, lng),
  ),
);

class _QuickSpotSheet extends ConsumerStatefulWidget {
  const _QuickSpotSheet({
    required this.associationId,
    required this.initialName,
    this.position,
  });

  final String associationId;
  final String initialName;
  final LatLng? position;

  @override
  ConsumerState<_QuickSpotSheet> createState() => _QuickSpotSheetState();
}

class _QuickSpotSheetState extends ConsumerState<_QuickSpotSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName);
  late LatLng? _point = widget.position;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    final point = _point;
    if (point == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.spotsErrorLocationRequired)));
      return;
    }
    // A name already taken is that spot, chosen rather than duplicated (Q183).
    final spots =
        ref.read(associationSpotsProvider(widget.associationId)).value ??
        const <Spot>[];
    final existing = spotNamed(spots, _name.text);
    if (existing != null) {
      Navigator.of(context).pop(existing);
      return;
    }
    setState(() => _busy = true);
    try {
      final place = await ref
          .read(placeGeocodingClientProvider)
          .reverse(
            lat: point.latitude,
            lng: point.longitude,
            languageCode: Localizations.localeOf(context).languageCode,
          );
      final spot = await ref
          .read(spotsRepositoryProvider)
          .create(
            widget.associationId,
            SpotDraft(
              name: _name.text,
              address: place?.address,
              city: place?.city,
              lat: point.latitude,
              lng: point.longitude,
            ),
          );
      ref.invalidate(associationSpotsProvider(widget.associationId));
      if (mounted) Navigator.of(context).pop(spot);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(describeSpotError(error, l10n))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final association = ref
        .watch(associationByIdProvider(widget.associationId))
        .value;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.spotsQuickTitle, style: textTheme.titleLarge),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _name,
                  autofocus: true,
                  maxLength: spotNameMaxLength,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: l10n.spotsNameLabel),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? l10n.spotsNameRequired
                      : null,
                ),
                const SizedBox(height: 8),
                if (widget.position != null)
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.crosshair,
                        size: 18,
                        color: context.nuni.primaryInk,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.spotsQuickAtPosition,
                          style: textTheme.bodySmall,
                        ),
                      ),
                    ],
                  )
                else ...[
                  // Position unknown (refused, unavailable): the point is
                  // placed by hand (Q181).
                  Text(l10n.spotsQuickPlacePoint, style: textTheme.bodySmall),
                  const SizedBox(height: 8),
                  NuniLocationPicker(
                    // Rebuilt when the association arrives, to open on its city.
                    key: ValueKey(association?.id),
                    value: _point,
                    initialCenter: association == null
                        ? null
                        : LatLng(
                            association.locationLat,
                            association.locationLng,
                          ),
                    height: 220,
                    zoom: 16,
                    centerZoom: 13,
                    onChanged: (point) => setState(() => _point = point),
                  ),
                ],
                const SizedBox(height: 16),
                NuniButton(
                  label: l10n.spotsQuickCreate,
                  onPressed: _busy ? null : _create,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
