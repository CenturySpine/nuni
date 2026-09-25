import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/geocoding/place_geocoding_client.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_location_picker.dart';

/// Where a spot is: its point, and the address found for it (null when
/// none was found there).
typedef SpotPlace = ({double lat, double lng, String? address, String? city});

/// A spot's place (plan 28): an address and a point, always in step (Q179).
/// Placing the point fills the address; typing searches addresses, and
/// choosing one moves the point. A typed text that isn't chosen is dropped:
/// the address shown is always the one of the point.
class SpotPlaceField extends ConsumerStatefulWidget {
  const SpotPlaceField({
    super.key,
    required this.value,
    required this.onChanged,
    this.initialCenter,
  });

  final SpotPlace? value;
  final ValueChanged<SpotPlace> onChanged;

  /// Where the map opens without a point: the user's position or the
  /// association's city.
  final LatLng? initialCenter;

  @override
  ConsumerState<SpotPlaceField> createState() => _SpotPlaceFieldState();
}

class _SpotPlaceFieldState extends ConsumerState<SpotPlaceField> {
  late final _query = TextEditingController(text: widget.value?.address);
  final _focus = FocusNode();

  /// The address of the point, as last chosen or found: what the field shows
  /// again when left without choosing.
  late String? _address = widget.value?.address;
  Timer? _debounce;
  List<GeocodedPlace> _results = const [];
  bool _searching = false;
  bool _locating = false;

  /// Bumped when the point moves from outside the map, to recentre it.
  int _mapVersion = 0;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      // Leaving the field without choosing: back to the point's address.
      if (!_focus.hasFocus) {
        _debounce?.cancel();
        _query.text = _address ?? '';
        setState(() => _results = const []);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  String get _language => Localizations.localeOf(context).languageCode;

  void _onTyped(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _searching = true);
      final near = widget.value == null
          ? widget.initialCenter
          : LatLng(widget.value!.lat, widget.value!.lng);
      final results = await ref
          .read(placeGeocodingClientProvider)
          .search(
            text,
            languageCode: _language,
            nearLat: near?.latitude,
            nearLng: near?.longitude,
          );
      if (!mounted) return;
      setState(() {
        _results = results;
        _searching = false;
      });
    });
  }

  void _choose(GeocodedPlace place) {
    _debounce?.cancel();
    _address = place.address;
    _query.text = place.address;
    setState(() {
      _results = const [];
      _mapVersion++;
    });
    widget.onChanged((
      lat: place.lat,
      lng: place.lng,
      address: place.address,
      city: place.city,
    ));
    _focus.unfocus();
  }

  Future<void> _placePoint(LatLng point) async {
    setState(() => _locating = true);
    final found = await ref
        .read(placeGeocodingClientProvider)
        .reverse(
          lat: point.latitude,
          lng: point.longitude,
          languageCode: _language,
        );
    if (!mounted) return;
    // No address found there (or the service unreachable): the address is
    // cleared rather than left pointing somewhere else.
    _address = found?.address;
    _query.text = found?.address ?? '';
    setState(() => _locating = false);
    widget.onChanged((
      lat: point.latitude,
      lng: point.longitude,
      address: found?.address,
      city: found?.city,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final value = widget.value;
    final busy = _searching || _locating;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _query,
          focusNode: _focus,
          onChanged: _onTyped,
          decoration: InputDecoration(
            labelText: l10n.spotsAddressLabel,
            helperText: value != null && value.address == null
                ? l10n.spotsAddressUnknown
                : l10n.spotsAddressHint,
            helperMaxLines: 2,
            prefixIcon: const Icon(PhosphorIcons.magnifyingGlass, size: 20),
            suffixIcon: busy
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
        ),
        if (_results.isNotEmpty)
          // Part of the field's tap region: touching a result doesn't count
          // as leaving the field, which would clear the results first.
          TextFieldTapRegion(
            child: Card(
              margin: const EdgeInsets.only(top: 4),
              child: Column(
                children: [
                  for (final place in _results)
                    ListTile(
                      dense: true,
                      leading: const Icon(PhosphorIcons.mapPin, size: 18),
                      title: Text(place.address),
                      onTap: () => _choose(place),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        NuniLocationPicker(
          key: ValueKey(_mapVersion),
          value: value == null ? null : LatLng(value.lat, value.lng),
          initialCenter: widget.initialCenter,
          zoom: 16,
          centerZoom: 13,
          onChanged: _placePoint,
        ),
      ],
    );
  }
}
