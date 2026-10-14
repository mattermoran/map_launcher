import 'package:map_launcher/src/maps/osmand.dart';
import 'package:map_launcher/src/maps/petal.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:test/test.dart';

void main() {
  final coords = LocationCoords(52.520, 13.405, title: 'Berlin');

  group('OsmAnd', () {
    const osmand = OsmAnd();

    test('type is osmand', () {
      expect(osmand.id, equals('osmand'));
    });

    test('markerUrl returns null (scheme only)', () {
      expect(osmand.markerUrl(coords), isNull);
    });

    test('markerSchemeUrl iOS uses osmandmaps://', () {
      final url = osmand.markerSchemeUrl(coords, platform: .ios);
      expect(url, contains('osmandmaps://'));
      expect(url, contains('lat='));
      expect(url, contains('lon='));
    });

    test('markerSchemeUrl iOS includes title when label present', () {
      final url = osmand.markerSchemeUrl(coords, platform: .ios);
      expect(url, contains('title=Berlin'));
    });

    test('markerSchemeUrl iOS includes zoom', () {
      final url = osmand.markerSchemeUrl(coords, zoom: 15, platform: .ios);
      expect(url, contains('z=15'));
    });

    test('markerSchemeUrl Android uses osmand.net', () {
      final url = osmand.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('osmand.net/go'));
    });

    for (final app in [osmand, const OsmAndPlus()]) {
      for (final platform in MapPlatform.values) {
        test('${app.id} $platform serializes route inputs and modes', () {
          final profiles = ['car', 'pedestrian', 'public_transport', 'bicycle'];
          for (final mode in TravelMode.values) {
            final uri = Uri.parse(
              app.directionsSchemeUrl(
                destination: coords,
                origin: LocationCoords(-33.8688, 151.2093),
                waypoints: [LocationCoords(1, 2), LocationCoords(3, 4)],
                travelMode: mode,
                platform: platform,
              )!,
            );
            expect(uri.scheme, 'https');
            expect(uri.host, 'osmand.net');
            expect(uri.path, '/map/navigate');
            expect(uri.queryParameters, {
              'start': '-33.8688,151.2093',
              'end': coords.latlng,
              'via': '1.0,2.0;3.0,4.0',
              'profile': profiles[mode.index],
            });
          }
          expect(app.supportsWaypoints, isTrue);
          final uri = Uri.parse(
            app.directionsSchemeUrl(
              destination: coords,
              waypoints: [],
              platform: platform,
            )!,
          );
          expect(uri.queryParameters, {'end': coords.latlng});
        });
      }
    }
  });

  group('OsmAndPlus', () {
    const plus = OsmAndPlus();

    test('type is osmandplus', () {
      expect(plus.id, equals('osmandplus'));
    });

    test('inherits OsmAnd functionality', () {
      // Should produce same URLs as OsmAnd
      final url = plus.markerSchemeUrl(coords, platform: .ios);
      expect(url, contains('osmandmaps://'));
    });
  });

  group('PetalMaps', () {
    const petal = PetalMaps();

    test('type is petal', () {
      expect(petal.id, equals('petal'));
    });

    test('markerUrl returns null (scheme only)', () {
      expect(petal.markerUrl(coords), isNull);
    });

    test('markerSchemeUrl uses petalmaps://poidetail', () {
      final url = petal.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('petalmaps://poidetail'));
      expect(url, contains('marker='));
    });

    test('markerSchemeUrl includes zoom', () {
      final url = petal.markerSchemeUrl(coords, zoom: 15, platform: .android);
      expect(url, contains('z=15'));
    });

    test('directionsSchemeUrl uses petalmaps://route', () {
      final url = petal.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, contains('petalmaps://route'));
      expect(url, contains('daddr='));
    });

    test('directionsSchemeUrl includes origin', () {
      final url = petal.directionsSchemeUrl(
        destination: coords,
        origin: LocationCoords(52.50, 13.40),
        platform: .android,
      );
      expect(url, contains('saddr='));
    });

    test('directionsSchemeUrl includes travel mode', () {
      final url = petal.directionsSchemeUrl(
        destination: coords,
        travelMode: .walking,
        platform: .android,
      );
      expect(url, contains('type=walk'));
    });

    test('directionsSchemeUrl uses the documented bicycle type', () {
      final url = petal.directionsSchemeUrl(
        destination: coords,
        travelMode: .bicycling,
        platform: .android,
      );
      expect(Uri.parse(url!).queryParameters['type'], 'bicycle');
    });

    test('direction labels round-trip through query encoding once', () {
      const label = 'Café & Tea/入口? #1';
      final url = petal.directionsSchemeUrl(
        destination: LocationCoords(52.52, 13.405, title: label),
        origin: LocationCoords(52.5, 13.4, title: label),
        platform: .android,
      );
      final query = Uri.parse(url!).queryParameters;
      expect(query['daddr'], '52.52,13.405($label)');
      expect(query['saddr'], '52.5,13.4($label)');
    });
  });
}
