import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nuni/core/geocoding/place_geocoding_client.dart';

Map<String, Object?> _feature(
  Map<String, Object?> properties,
  double lng,
  double lat,
) => {
  'type': 'Feature',
  'properties': properties,
  'geometry': {
    'type': 'Point',
    'coordinates': [lng, lat],
  },
};

http.Response _json(List<Map<String, Object?>> features) => http.Response.bytes(
  utf8.encode(jsonEncode({'type': 'FeatureCollection', 'features': features})),
  200,
);

void main() {
  test(
    'search: named places with their address, near the given point',
    () async {
      late Uri asked;
      final client = PlaceGeocodingClient(
        httpClient: MockClient((request) async {
          asked = request.url;
          return _json([
            _feature(
              {
                'name': 'Lyon-Tech La Doua',
                'street': 'Quai Charles de Gaulle',
                'city': 'Lyon',
                'postcode': '69006',
              },
              4.87,
              45.78,
            ),
            _feature({'country': 'France'}, 2, 46),
          ]);
        }),
      );

      final places = await client.search(
        'la doua',
        languageCode: 'fr',
        nearLat: 45.76,
        nearLng: 4.83,
      );

      expect(asked.path, '/api/');
      expect(asked.queryParameters['lang'], 'fr');
      expect(asked.queryParameters['lat'], '45.76');
      expect(places, hasLength(1));
      expect(
        places.single.address,
        'Lyon-Tech La Doua, Quai Charles de Gaulle, 69006 Lyon',
      );
      expect(places.single.city, 'Lyon');
      expect((places.single.lat, places.single.lng), (45.78, 4.87));
    },
  );

  test('search: nothing asked under three letters', () async {
    var called = false;
    final client = PlaceGeocodingClient(
      httpClient: MockClient((request) async {
        called = true;
        return _json(const []);
      }),
    );
    expect(await client.search('pa', languageCode: 'en'), isEmpty);
    expect(called, isFalse);
  });

  test('reverse: the street address, not the nearest named place, at the '
      'point placed', () async {
    final client = PlaceGeocodingClient(
      httpClient: MockClient(
        (request) async => _json([
          _feature(
            {
              'name': 'Bibliothèque Universitaire',
              'housenumber': '33',
              'street': 'Avenue Jean Capelle',
              'city': 'Villeurbanne',
              'postcode': '69100',
            },
            4.8766,
            45.7826,
          ),
        ]),
      ),
    );

    final place = await client.reverse(
      lat: 45.7825,
      lng: 4.8765,
      languageCode: 'en',
    );

    expect(place?.address, '33 Avenue Jean Capelle, 69100 Villeurbanne');
    expect((place?.lat, place?.lng), (45.7825, 4.8765));
  });

  test('every failure reads as nothing found', () async {
    final client = PlaceGeocodingClient(
      httpClient: MockClient((request) async => http.Response('oops', 500)),
    );
    expect(await client.search('parc', languageCode: 'fr'), isEmpty);
    expect(await client.reverse(lat: 1, lng: 2, languageCode: 'fr'), isNull);
  });
}
