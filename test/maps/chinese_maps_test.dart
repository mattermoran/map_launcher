import 'package:map_launcher/src/maps/baidu.dart';
import 'package:map_launcher/src/maps/amap.dart';
import 'package:map_launcher/src/maps/tencent.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:test/test.dart';

void main() {
  final coords = LocationCoords(39.908, 116.397, title: 'Beijing');

  group('BaiduMaps', () {
    const baidu = BaiduMaps();

    for (final platform in [MapPlatform.android, MapPlatform.ios]) {
      test('marker required fields on $platform', () {
        for (final title in [null, '', '   ', '入口 & + #%']) {
          final point = LocationCoords(39.908, 116.397, title: title);
          final uri = Uri.parse(
            baidu.markerSchemeUrl(point, platform: platform)!,
          );
          expect(uri.toString().split('?').first, 'baidumap://map/marker');
          expect(
            uri.queryParameters['title'],
            title?.trim().isNotEmpty == true ? title : point.latlng,
          );
          // Caller content and launch defaults are applied during preparation.
          expect(uri.queryParameters['content'], isNull);
          expect(
            uri.queryParameters['traffic'],
            platform == MapPlatform.android ? 'on' : null,
          );
        }
      });

      test('default versus explicit origin on $platform', () {
        final current = baidu.directionsSchemeUrl(
          destination: coords,
          platform: platform,
        );
        expect(Uri.parse(current!).queryParameters['origin'], isNull);
        final explicit = Uri.parse(
          baidu.directionsSchemeUrl(
            destination: coords,
            origin: LocationCoords(39.9, 116.4, title: 'Start & 入口'),
            platform: platform,
          )!,
        ).queryParameters;
        expect(explicit['origin'], 'latlng:39.9,116.4|name:Start & 入口');
        expect(explicit['coord_type'], 'gcj02');
      });
    }

    test('type is baidu', () {
      expect(baidu.id, equals('baidu'));
    });

    test('markerUrl returns null (scheme only)', () {
      expect(baidu.markerUrl(coords), isNull);
    });

    test('markerSchemeUrl uses baidumap:// marker', () {
      final url = baidu.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('baidumap://map/marker'));
      expect(url, contains('location='));
      expect(url, contains('coord_type=gcj02'));
      expect(url, isNot(contains('src=')));
      expect(
        const BaiduMaps(
          source: 'example.caller',
        ).markerSchemeUrl(coords, platform: .android),
        contains('src=andr.example.caller'),
      );
    });

    test('markerSchemeUrl includes zoom', () {
      final url = baidu.markerSchemeUrl(coords, zoom: 15, platform: .android);
      expect(url, contains('zoom=15'));
    });

    test('directionsSchemeUrl uses baidumap:// direction', () {
      final url = baidu.directionsSchemeUrl(
        destination: coords,
        origin: LocationCoords(39.9, 116.4),
        platform: .android,
      );
      expect(url, contains('baidumap://map/direction'));
      expect(url, contains('destination='));
      expect(url, contains('mode=driving'));
    });

    test('directionsSchemeUrl maps travel modes', () {
      final walking = baidu.directionsSchemeUrl(
        destination: coords,
        origin: LocationCoords(39.9, 116.4),
        travelMode: .walking,
        platform: .android,
      );
      expect(walking, contains('mode=walking'));

      final transit = baidu.directionsSchemeUrl(
        destination: coords,
        origin: LocationCoords(39.9, 116.4),
        travelMode: .transit,
        platform: .android,
      );
      expect(transit, contains('mode=transit'));

      final cycling = baidu.directionsSchemeUrl(
        destination: coords,
        origin: LocationCoords(39.9, 116.4),
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

    test('direction labels round-trip while preserving structure', () {
      const label = 'Café & Tea/入口? #1';
      final url = baidu.directionsSchemeUrl(
        destination: LocationCoords(39.908, 116.397, title: label),
        origin: LocationCoords(39.9, 116.4, title: label),
        platform: .android,
      );
      final query = Uri.parse(url!).queryParameters;
      expect(query['destination'], 'latlng:39.908,116.397|name:$label');
      expect(query['origin'], 'latlng:39.9,116.4|name:$label');
    });
  });

  group('Amap', () {
    const amap = Amap();

    test('type is amap', () {
      expect(amap.id, equals('amap'));
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

    for (final platform in [MapPlatform.android, MapPlatform.ios]) {
      test('documented route endpoint and coordinate datum on $platform', () {
        for (final origin in [
          null,
          LocationCoords(39.9, 116.4, title: 'Start'),
        ]) {
          final uri = Uri.parse(
            amap.directionsSchemeUrl(
              destination: coords,
              origin: origin,
              platform: platform,
            )!,
          );
          expect(
            uri.toString().split('?').first,
            platform == MapPlatform.ios
                ? 'iosamap://path'
                : 'amapuri://route/plan/',
          );
          expect(uri.queryParameters['dev'], '0');
          expect(uri.queryParameters['dlat'], '39.908');
          expect(uri.queryParameters['dlon'], '116.397');
          expect(uri.queryParameters['slat'], origin == null ? null : '39.9');
          expect(uri.queryParameters['slon'], origin == null ? null : '116.4');
          expect(uri.queryParameters['t'], '0');
        }
      });
    }

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
    const tencent = TencentMaps();

    for (final platform in [MapPlatform.android, MapPlatform.ios]) {
      test('required current or explicit fromcoord on $platform', () {
        for (final origin in [
          null,
          LocationCoords(39.9, 116.4, title: 'Start & 入口'),
        ]) {
          final uri = Uri.parse(
            tencent.directionsSchemeUrl(
              destination: coords,
              origin: origin,
              platform: platform,
            )!,
          );
          expect(uri.toString().split('?').first, 'qqmap://map/routeplan');
          expect(
            uri.queryParameters['fromcoord'],
            origin?.latlng ?? 'CurrentLocation',
          );
          expect(uri.queryParameters['from'], origin?.title);
          expect(uri.queryParameters['tocoord'], coords.latlng);
          // Credentials belong to the caller, not the provider builder.
          expect(uri.queryParameters.containsKey('referer'), isFalse);
        }
      });
    }

    test('type is tencent', () {
      expect(tencent.id, equals('tencent'));
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
