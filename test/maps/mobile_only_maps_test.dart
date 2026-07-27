import 'package:map_launcher/src/maps/yandex_navi.dart';
import 'package:map_launcher/src/maps/moovit.dart';
import 'package:map_launcher/src/maps/neshan.dart';
import 'package:map_launcher/src/maps/copilot.dart';
import 'package:map_launcher/src/maps/sygic_truck.dart';
import 'package:map_launcher/src/maps/mapswithme.dart';
import 'package:map_launcher/src/maps/google_go.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:test/test.dart';

void main() {
  final coords = LocationCoords(37.759, -122.510, title: 'Beach');

  group('YandexNavi', () {
    const navi = YandexNavi();

    test('type is yandexNavi', () {
      expect(navi.id, equals('yandexNavi'));
    });

    test('markerSchemeUrl uses yandexnavi://show_point_on_map', () {
      final url = navi.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('yandexnavi://show_point_on_map'));
      expect(url, contains('lat='));
      expect(url, contains('lon='));
    });

    test('markerSchemeUrl includes desc when label present', () {
      final url = navi.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('desc=Beach'));
    });

    test('directionsSchemeUrl uses build_route_on_map', () {
      final url = navi.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, contains('yandexnavi://build_route_on_map'));
      expect(url, contains('lat_to='));
      expect(url, contains('lon_to='));
    });

    test('directionsSchemeUrl includes waypoints', () {
      final url = navi.directionsSchemeUrl(
        destination: coords,
        waypoints: [LocationCoords(37.77, -122.45)],
        platform: .android,
      );
      expect(url, contains('lat_via_0='));
      expect(url, contains('lon_via_0='));
    });
  });

  group('Moovit', () {
    const moovit = Moovit();

    test('type is moovit', () {
      expect(moovit.id, equals('moovit'));
    });

    test('markerSchemeUrl uses moovit://nearby', () {
      final url = moovit.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('moovit://nearby'));
      expect(url, contains('lat='));
      expect(url, contains('lon='));
    });

    test('directionsSchemeUrl uses moovit://directions', () {
      final url = moovit.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, contains('moovit://directions'));
      expect(url, contains('dest_lat='));
      expect(url, contains('dest_lon='));
    });

    test('directionsSchemeUrl includes label as dest_name', () {
      final url = moovit.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, contains('dest_name=Beach'));
    });

    test('directionsSchemeUrl includes origin', () {
      final url = moovit.directionsSchemeUrl(
        destination: coords,
        origin: LocationCoords(37.785, -122.409, title: 'Start'),
        platform: .android,
      );
      expect(url, contains('orig_lat='));
      expect(url, contains('orig_lon='));
      expect(url, contains('orig_name=Start'));
    });
  });

  group('Neshan', () {
    const neshan = Neshan();

    test('type is neshan', () {
      expect(neshan.id, equals('neshan'));
    });

    test('markerSchemeUrl iOS uses neshan://', () {
      final url = neshan.markerSchemeUrl(coords, platform: .ios);
      expect(url, contains('neshan://'));
      expect(url, contains('destination='));
    });

    test('markerSchemeUrl Android uses nshn.ir', () {
      final url = neshan.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('nshn.ir'));
    });

    test('directionsSchemeUrl includes origin', () {
      final url = neshan.directionsSchemeUrl(
        destination: coords,
        origin: LocationCoords(37.785, -122.409),
        platform: .android,
      );
      expect(url, contains('origin='));
      expect(url, contains('destination='));
    });
  });

  group('CoPilot', () {
    const copilot = CoPilot();

    test('type is copilot', () {
      expect(copilot.id, equals('copilot'));
    });

    test('markerSchemeUrl uses copilot://mydestination VIEW', () {
      final url = copilot.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('copilot://mydestination'));
      expect(url, contains('action=VIEW'));
    });

    test('directionsSchemeUrl uses copilot://mydestination GOTO', () {
      final url = copilot.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, contains('copilot://mydestination'));
      expect(url, contains('action=GOTO'));
    });
  });

  group('SygicTruck', () {
    const sygic = SygicTruck();

    test('type is sygicTruck', () {
      expect(sygic.id, equals('sygicTruck'));
    });

    test('markerSchemeUrl uses pipe-separated format with show', () {
      final url = sygic.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('com.sygic.aura://coordinate'));
      expect(url, contains('show'));
    });

    test('directionsSchemeUrl uses pipe-separated format with drive', () {
      final url = sygic.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, contains('com.sygic.aura://coordinate'));
      expect(url, contains('drive'));
    });
  });

  group('MapsMe', () {
    const mapsme = MapsMe();

    test('type is mapswithme', () {
      expect(mapsme.id, equals('mapswithme'));
    });

    test('markerSchemeUrl uses mapsme://map', () {
      final url = mapsme.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('mapsme://map'));
      expect(url, contains('v=1'));
    });

    test('markerSchemeUrl includes name when label present', () {
      final url = mapsme.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('n=Beach'));
    });

    test('directionsSchemeUrl uses mapsme://route', () {
      final url = mapsme.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, contains('mapsme://route'));
      expect(url, contains('v=1'));
    });
  });

  group('GoogleMapsGo', () {
    const go = GoogleMapsGo();

    test('type is googleGo', () {
      expect(go.id, equals('googleGo'));
    });

    test('markerSchemeUrl uses geo: scheme', () {
      final url = go.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('geo:0,0'));
      expect(url, contains('q='));
    });

    test('markerSchemeUrl includes label in parentheses', () {
      final url = go.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('Beach'));
    });

    test('directionsSchemeUrl uses google.navigation:', () {
      final url = go.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, contains('google.navigation:'));
    });
  });
}
