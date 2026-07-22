import 'package:map_launcher/src/maps/baidu.dart';
import 'package:map_launcher/src/maps/amap.dart';
import 'package:map_launcher/src/maps/tencent.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:test/test.dart';

void main() {
  final coords = LocationCoords(39.908, 116.397, title: 'Beijing');

  group('BaiduMaps', () {
    const baidu = BaiduMapsBuilder();

    test('type is MapType.baidu', () {
      expect(baidu.mapType, equals(MapType.baidu));
    });

    test('markerUrl returns null (scheme only)', () {
      expect(baidu.markerUrl(coords), isNull);
    });

    test('markerSchemeUrl uses baidumap:// marker', () {
      final url = baidu.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('baidumap://map/marker'));
      expect(url, contains('location='));
      expect(url, contains('coord_type=gcj02'));
      expect(url, contains('src=com.map_launcher'));
    });

    test('markerSchemeUrl includes zoom', () {
      final url = baidu.markerSchemeUrl(coords, zoom: 15, platform: .android);
      expect(url, contains('zoom=15'));
    });

    test('directionsSchemeUrl uses baidumap:// direction', () {
      final url = baidu.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, contains('baidumap://map/direction'));
      expect(url, contains('destination='));
      expect(url, contains('mode=driving'));
    });

    test('directionsSchemeUrl maps travel modes', () {
      final walking = baidu.directionsSchemeUrl(
        destination: coords,
        travelMode: .walking,
        platform: .android,
      );
      expect(walking, contains('mode=walking'));

      final transit = baidu.directionsSchemeUrl(
        destination: coords,
        travelMode: .transit,
        platform: .android,
      );
      expect(transit, contains('mode=transit'));

      final cycling = baidu.directionsSchemeUrl(
        destination: coords,
        travelMode: .bicycling,
        platform: .android,
      );
      expect(cycling, contains('mode=riding'));
    });

    test('directionsSchemeUrl includes origin', () {
      final url = baidu.directionsSchemeUrl(
        destination: coords,
        origin: LocationCoords(39.90, 116.40, title: 'Start'),
        platform: .android,
      );
      expect(url, contains('origin='));
    });
  });

  group('Amap', () {
    const amap = AmapBuilder();

    test('type is MapType.amap', () {
      expect(amap.mapType, equals(MapType.amap));
    });

    test('markerUrl returns null (scheme only)', () {
      expect(amap.markerUrl(coords), isNull);
    });

    test('markerSchemeUrl uses amap://viewMap', () {
      final url = amap.markerSchemeUrl(coords, platform: .ios);
      expect(url, contains('iosamap://viewMap'));
      expect(url, contains('sourceApplication=map_launcher'));
    });

    test('markerSchemeUrl uses android prefix on Android', () {
      final url = amap.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('androidamap://viewMap'));
    });

    test('directionsSchemeUrl uses route/plan', () {
      final url = amap.directionsSchemeUrl(destination: coords, platform: .ios);
      expect(url, contains('iosamap://route/plan'));
      expect(url, contains('dlat='));
      expect(url, contains('dlon='));
    });

    test('directionsSchemeUrl includes travel mode', () {
      final url = amap.directionsSchemeUrl(
        destination: coords,
        travelMode: .walking,
        platform: .android,
      );
      expect(url, contains('t=2'));
    });
  });

  group('TencentMaps', () {
    const tencent = TencentMapsBuilder();

    test('type is MapType.tencent', () {
      expect(tencent.mapType, equals(MapType.tencent));
    });

    test('markerUrl returns null (scheme only)', () {
      expect(tencent.markerUrl(coords), isNull);
    });

    test('markerSchemeUrl uses qqmap://map/marker', () {
      final url = tencent.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('qqmap://map/marker'));
      expect(url, contains('marker='));
    });

    test('markerSchemeUrl includes title in marker param', () {
      final url = tencent.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('Beijing'));
    });

    test('directionsSchemeUrl uses qqmap://map/routeplan', () {
      final url = tencent.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, contains('qqmap://map/routeplan'));
      expect(url, contains('tocoord='));
    });

    test('directionsSchemeUrl includes travel mode', () {
      final url = tencent.directionsSchemeUrl(
        destination: coords,
        travelMode: .walking,
        platform: .android,
      );
      expect(url, contains('type=walk'));
    });
  });
}
