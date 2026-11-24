import 'package:map_launcher/src/maps/organic_maps.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:test/test.dart';

void main() {
  const om = OrganicMaps();
  final coords = LocationCoords(37.759, -122.510, title: 'Beach');

  test('type is organicMaps', () {
    expect(om.id, equals('organicMaps'));
  });

  test('markerSchemeUrl uses om://map with name and zoom', () {
    final uri = Uri.parse(
      om.markerSchemeUrl(coords, zoom: 15, platform: .ios)!,
    );
    expect(uri.scheme, 'om');
    expect(uri.host, 'map');
    expect(uri.queryParameters, {
      'v': '1',
      'll': '37.759,-122.51',
      'n': 'Beach',
      'z': '15',
    });
  });

  test('no web URLs and no v2 links', () {
    expect(om.markerUrl(coords), isNull);
    expect(om.directionsUrl(destination: coords), isNull);
    final route = om.directionsSchemeUrl(
      origin: LocationCoords(3, 4),
      destination: coords,
      platform: .ios,
    )!;
    expect(route, isNot(contains('v2')));
  });

  test('labels round-trip through the percent-only receiver decoder', () {
    final origin = LocationCoords(3, 4, title: 'Central Station');
    final destination = LocationCoords(1, 2, title: 'A+B & café/港');
    final route = om.directionsSchemeUrl(
      origin: origin,
      destination: destination,
      platform: .android,
    )!;
    final marker = om.markerSchemeUrl(destination, platform: .ios)!;
    // The legacy receiver (shared with MAPS.ME) decodes %HH, not '+'.
    for (final url in [route, marker]) {
      expect(url, isNot(contains('+')));
      final fields = {
        for (final field in Uri.parse(url).query.split('&'))
          field.split('=').first: Uri.decodeComponent(
            field.substring(field.indexOf('=') + 1),
          ),
      };
      if (url == route) {
        expect(fields['saddr'], 'Central Station');
        expect(fields['daddr'], 'A+B & café/港');
      } else {
        expect(fields['n'], 'A+B & café/港');
      }
    }
  });

  for (final platform in MapPlatform.values) {
    test('$platform routes require origin and ordered keys', () {
      expect(
        om.directionsSchemeUrl(destination: coords, platform: platform),
        isNull,
      );
      for (final mode in TravelMode.values) {
        final uri = Uri.parse(
          om.directionsSchemeUrl(
            origin: LocationCoords(-33.8688, 151.2093, title: 'Start'),
            destination: LocationCoords(1, 2),
            travelMode: mode,
            platform: platform,
          )!,
        );
        expect(uri.scheme, 'om');
        expect(uri.host, 'route');
        expect(uri.queryParameters.keys.toList(), [
          'sll',
          'saddr',
          'dll',
          'daddr',
          'type',
        ]);
        expect(uri.queryParameters, {
          'sll': '-33.8688,151.2093',
          'saddr': 'Start',
          'dll': '1.0,2.0',
          'daddr': '',
          'type': ['vehicle', 'pedestrian', 'transit', 'bicycle'][mode.index],
        });
      }
      final uri = Uri.parse(
        om.directionsSchemeUrl(
          origin: LocationCoords(3, 4),
          destination: LocationCoords(1, 2),
          platform: platform,
        )!,
      );
      expect(uri.queryParameters['type'], 'vehicle');
    });
  }
}
