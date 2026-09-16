import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// BigDataCloud "reverse-geocode-client" (Q11): free, no API key, designed
/// for a direct call from the browser (open CORS). Every failure (timeout,
/// network, unexpected shape) collapses to `null` -- the city field just
/// stays editable and empty, same fallback style as [LocationService].
class ReverseGeocodingClient {
  ReverseGeocodingClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<String?> cityFor({
    required double lat,
    required double lng,
    required String languageCode,
  }) async {
    try {
      final uri = Uri.https(
        'api.bigdatacloud.net',
        '/data/reverse-geocode-client',
        {
          'latitude': '$lat',
          'longitude': '$lng',
          'localityLanguage': languageCode,
        },
      );
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 3));
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, Object?>;
      final city = (json['city'] as String?)?.trim();
      if (city != null && city.isNotEmpty) return city;
      final locality = (json['locality'] as String?)?.trim();
      return (locality != null && locality.isNotEmpty) ? locality : null;
    } catch (_) {
      return null;
    }
  }
}

final reverseGeocodingClientProvider = Provider<ReverseGeocodingClient>(
  (ref) => ReverseGeocodingClient(),
);
