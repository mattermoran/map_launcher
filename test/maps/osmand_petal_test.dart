import 'package:map_launcher/src/maps/osmand.dart';
import 'package:map_launcher/src/maps/petal.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:test/test.dart';

void main() {
  final coords = LocationCoords(52.520, 13.405, title: 'Berlin');

  group('OsmAnd', () {
    const osmand = OsmAndBuilder();

    test('type is MapType.osmand', () {
      expect(osmand.mapType, equals(MapType.osmand));
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

    test('directionsSchemeUrl iOS uses osmandmaps://navigate', () {
      final url = osmand.directionsSchemeUrl(
        destination: coords,
        platform: .ios,
      );
      expect(url, contains('osmandmaps://navigate'));
    });

    test('directionsSchemeUrl Android uses osmand.net', () {
      final url = osmand.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, contains('osmand.net/go'));
    });
  });

  group('OsmAndPlus', () {
    const plus = OsmAndPlusBuilder();

    test('type is MapType.osmandplus', () {
      expect(plus.mapType, equals(MapType.osmandplus));
    });

    test('inherits OsmAnd functionality', () {
      // Should produce same URLs as OsmAnd
      final url = plus.markerSchemeUrl(coords, platform: .ios);
      expect(url, contains('osmandmaps://'));
    });
  });

  group('PetalMaps', () {
    const petal = PetalMapsBuilder();

    test('type is MapType.petal', () {
      expect(petal.mapType, equals(MapType.petal));
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
  });
}
