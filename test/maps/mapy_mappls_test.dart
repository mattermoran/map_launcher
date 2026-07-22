import 'package:map_launcher/src/maps/mapy_cz.dart';
import 'package:map_launcher/src/maps/mappls.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:test/test.dart';

void main() {
  group('MapyCz', () {
    const mapy = MapyCzBuilder();

    test('type is MapType.mapyCz', () {
      expect(mapy.mapType, equals(MapType.mapyCz));
    });

    test('markerUrl generates mapy.cz URL with lnglat', () {
      final url = mapy.markerUrl(LocationCoords(50.075, 14.437));
      expect(url, contains('mapy.cz'));
      expect(url, contains('source=coor'));
    });

    test('markerUrl includes zoom', () {
      final url = mapy.markerUrl(LocationCoords(50.075, 14.437), zoom: 12);
      expect(url, contains('z=12'));
    });

    test('directionsUrl generates directions URL', () {
      final url = mapy.directionsUrl(
        destination: LocationCoords(50.075, 14.437),
      );
      expect(url, contains('mapy.cz'));
      expect(url, contains('source=rout'));
    });
  });

  group('Mappls', () {
    const mappls = MapplsBuilder();

    test('type is MapType.mappls', () {
      expect(mappls.mapType, equals(MapType.mappls));
    });

    test('markerUrl generates mappls.com URL', () {
      final url = mappls.markerUrl(
        LocationCoords(28.613, 77.209, title: 'New Delhi'),
      );
      expect(url, contains('mappls.com/location'));
      expect(url, contains('28.613'));
    });

    test('directionsUrl includes travel mode', () {
      final url = mappls.directionsUrl(
        destination: LocationCoords(28.613, 77.209),
        travelMode: .walking,
      );
      expect(url, contains('mappls.com/navigation'));
      expect(url, contains('mode=walking'));
    });
  });
}
