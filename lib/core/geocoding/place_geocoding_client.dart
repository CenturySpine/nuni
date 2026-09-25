import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// A place found by [PlaceGeocodingClient]: the address shown and stored,
/// its city, its point.
class GeocodedPlace {
  const GeocodedPlace({
    required this.address,
    required this.lat,
    required this.lng,
    this.city,
  });

  final String address;
  final String? city;
  final double lat;
  final double lng;
}

/// Photon (komoot, Q178): OpenStreetMap geocoding, free, no API key, open
/// CORS, and -- unlike Nominatim -- fine with a search as one types. Both
/// directions of a spot's place (plan 28, Q179): an address typed becomes a
/// point, a point placed becomes an address. Every failure (timeout,
/// network, unexpected shape) collapses to "nothing found", same fallback
/// style as [ReverseGeocodingClient].
class PlaceGeocodingClient {
  PlaceGeocodingClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const _host = 'photon.komoot.io';

  /// Up to five places matching [query], the ones near [nearLat]/[nearLng]
  /// first when given.
  Future<List<GeocodedPlace>> search(
    String query, {
    required String languageCode,
    double? nearLat,
    double? nearLng,
  }) async {
    final text = query.trim();
    if (text.length < 3) return const [];
    final features = await _get('/api/', {
      'q': text,
      'limit': '5',
      ..._language(languageCode),
      if (nearLat != null && nearLng != null) ...{
        'lat': '$nearLat',
        'lon': '$nearLng',
      },
    });
    return [for (final feature in features) ?_place(feature, withName: true)];
  }

  /// The address nearest to a point, or null. The street address only: the
  /// nearest named place (a library, a shop) would mislead.
  Future<GeocodedPlace?> reverse({
    required double lat,
    required double lng,
    required String languageCode,
  }) async {
    final features = await _get('/reverse', {
      'lat': '$lat',
      'lon': '$lng',
      ..._language(languageCode),
    });
    if (features.isEmpty) return null;
    final place = _place(features.first, withName: false);
    // The point stays the one placed, not the address's.
    return place == null
        ? null
        : GeocodedPlace(
            address: place.address,
            city: place.city,
            lat: lat,
            lng: lng,
          );
  }

  /// Photon speaks French and English, the app's two languages.
  Map<String, String> _language(String code) =>
      code == 'fr' || code == 'en' ? {'lang': code} : const {};

  Future<List<Map<String, Object?>>> _get(
    String path,
    Map<String, String> query,
  ) async {
    try {
      final response = await _httpClient
          .get(Uri.https(_host, path, query))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return const [];
      final json =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, Object?>;
      return [
        for (final feature in json['features'] as List? ?? const [])
          if (feature is Map<String, Object?>) feature,
      ];
    } catch (_) {
      return const [];
    }
  }

  GeocodedPlace? _place(
    Map<String, Object?> feature, {
    required bool withName,
  }) {
    final properties = feature['properties'];
    final geometry = feature['geometry'];
    if (properties is! Map || geometry is! Map) return null;
    final coordinates = geometry['coordinates'];
    if (coordinates is! List || coordinates.length < 2) return null;
    final lng = (coordinates[0] as num?)?.toDouble();
    final lat = (coordinates[1] as num?)?.toDouble();
    if (lat == null || lng == null) return null;

    String? text(String key) {
      final value = (properties[key] as String?)?.trim();
      return value == null || value.isEmpty ? null : value;
    }

    final name = text('name');
    final street = text('street');
    final number = text('housenumber');
    final city = text('city') ?? text('locality') ?? text('county');
    final postcode = text('postcode');
    final parts = [
      if (name != null && (withName || street == null) && name != street) name,
      if (street != null) number == null ? street : '$number $street',
      if (postcode != null || city != null)
        [postcode, city].whereType<String>().join(' '),
    ];
    if (parts.isEmpty) return null;
    return GeocodedPlace(
      address: parts.join(', '),
      city: city,
      lat: lat,
      lng: lng,
    );
  }
}

final placeGeocodingClientProvider = Provider<PlaceGeocodingClient>(
  (ref) => PlaceGeocodingClient(),
);
