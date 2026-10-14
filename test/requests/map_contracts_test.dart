import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:map_launcher/map_launcher_platform_interface.dart';

class _InstalledPlatform extends MapLauncherPlatform {
  _InstalledPlatform([this.platform = MapPlatform.android]);

  final launches = <String>[];

  @override
  final MapPlatform? platform;

  @override
  Future<Set<String>> getInstalledMaps(List<MapApp> maps) async =>
      maps.map((m) => m.id).toSet();

  @override
  Future<void> launch(String url, {String? androidPackageName}) async =>
      launches.add(url);
}

class _CustomApple extends AppleMaps {
  const _CustomApple();

  @override
  String get id => 'customApple';
}

class _CustomOrigin extends _CustomApple {
  const _CustomOrigin();

  @override
  String directionsSearchOriginKey(String url) => 'start';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final noEligibleMap = throwsA(
    isA<MapLaunchException>()
        .having((e) => e.reason, 'reason', MapLaunchFailure.noEligibleMap)
        .having(
          (e) => e.issues.single.cause,
          'configuration cause',
          isA<MapConfigurationError>(),
        ),
  );

  test(
    'coordinate origins are never silently dropped by request launch or discovery',
    () async {
      final original = MapLauncherPlatform.instance;
      final platform = _InstalledPlatform();
      MapLauncherPlatform.instance = platform;
      addTearDown(() => MapLauncherPlatform.instance = original);
      final request = MapLauncher.directions(
        LocationCoords(48.85, 2.29),
        from: LocationCoords(51.5, -0.12),
      );
      for (final map in <MapApp>[
        .waze,
        .googleGo,
        .mappls,
        .tomtomgo,
        .tomtomgofleet,
        .copilot,
        .flitsmeister,
        .sygicTruck,
        .magicEarth,
      ]) {
        expect(request.getUrl(map: map), isNull, reason: map.id);
        expect(request.getUniversalUrl(map: map), isNull, reason: map.id);
        expect(
          request.getSchemeUrl(map: map, platform: .ios),
          isNull,
          reason: map.id,
        );
        expect(await request.getSupportedMaps([map]), isEmpty, reason: map.id);
        await expectLater(request.show(map: map), noEligibleMap);
      }
      expect(platform.launches, isEmpty);
      expect(request.getUrl(map: .google), contains('origin=51.5%2C-0.12'));
    },
  );

  test(
    'disabled markers cannot launch navigation through direct requests',
    () async {
      final original = MapLauncherPlatform.instance;
      final platform = _InstalledPlatform(.ios);
      MapLauncherPlatform.instance = platform;
      addTearDown(() => MapLauncherPlatform.instance = original);
      final request = MapLauncher.marker(LocationCoords(48.85, 2.29));
      for (final map in <MapApp>[
        .airnavPro,
        .citymapper,
        .moovit,
        .sygicTruck,
        .tomtomgo,
      ]) {
        expect(request.getUrl(map: map), isNull, reason: map.id);
        expect(request.getSchemeUrl(map: map), isNull, reason: map.id);
        expect(await request.getSupportedMaps([map]), isEmpty, reason: map.id);
        await expectLater(request.show(map: map), noEligibleMap);
      }
      expect(platform.launches, isEmpty);
    },
  );

  test(
    'optional caller configuration is forwarded after extras are merged',
    () async {
      final original = MapLauncherPlatform.instance;
      final platform = _InstalledPlatform(.ios);
      MapLauncherPlatform.instance = platform;
      addTearDown(() => MapLauncherPlatform.instance = original);
      final point = LocationCoords(37.566, 126.978);
      for (final entry in <MapApp, Map<String, String>>{
        MapApp.naver: NaverExtra(appName: 'com.example.caller'),
        MapApp.tencent: TencentExtra(referer: 'test-key'),
        MapApp.baidu: BaiduExtra(src: 'ios.example.caller'),
      }.entries) {
        final request = MapLauncher.marker(point);
        final before = platform.launches.length;
        await request.show(map: entry.key);
        expect(platform.launches.length, before + 1);
        expect(
          Uri.parse(platform.launches.last).queryParameters,
          isNot(contains(entry.value.keys.single)),
        );
        await request.show(map: entry.key, extra: entry.value);
        expect(
          Uri.parse(platform.launches.last).queryParameters,
          containsPair(entry.value.keys.single, entry.value.values.single),
        );
      }
      await MapLauncher.marker(
        point,
      ).show(map: const NaverMap(appName: 'com.example.caller'));
      expect(
        Uri.parse(platform.launches.last).queryParameters['name'],
        '37.566,126.978',
      );
      await MapLauncher.marker(
        point,
      ).show(map: const BaiduMaps(source: 'example.caller'));
      expect(
        Uri.parse(platform.launches.last).queryParameters['src'],
        'ios.example.caller',
      );
    },
  );

  test('Google universal extras select the matching action on iOS', () async {
    final original = MapLauncherPlatform.instance;
    final platform = _InstalledPlatform(.ios);
    MapLauncherPlatform.instance = platform;
    addTearDown(() => MapLauncherPlatform.instance = original);
    final point = LocationCoords(48.85, 2.29);
    await MapLauncher.marker(point).show(
      map: .google,
      extra: GoogleExtra(queryPlaceId: 'place-id'),
    );
    expect(
      platform.launches.last,
      startsWith('https://www.google.com/maps/search/'),
    );
    expect(
      Uri.parse(platform.launches.last).queryParameters['query_place_id'],
      'place-id',
    );
    await MapLauncher.directions(
      LocationSearch('Café & Park'),
      from: LocationSearch('Station'),
    ).show(
      map: .google,
      extra: GoogleExtra(navigate: true, originPlaceId: 'origin-id'),
    );
    final route = Uri.parse(platform.launches.last);
    expect(route.path, '/maps/dir/');
    expect(route.queryParameters['origin'], 'Station');
    expect(route.queryParameters['destination'], 'Café & Park');
    expect(route.queryParameters['dir_action'], 'navigate');
    expect(route.queryParameters['origin_place_id'], 'origin-id');
    final before = platform.launches.length;
    await expectLater(
      MapLauncher.directions(point).show(
        map: .google,
        extra: GoogleExtra(originPlaceId: 'missing-origin'),
      ),
      noEligibleMap,
    );
    await expectLater(
      MapLauncher.marker(
        point,
      ).show(map: .google, extra: GoogleExtra(navigate: true)),
      noEligibleMap,
    );
    expect(platform.launches.length, before);
    await MapLauncher.marker(point).show(map: .google);
    expect(platform.launches.last, startsWith('comgooglemaps://'));
  });

  test(
    'Sygic Truck exposes only driving, including installed discovery',
    () async {
      final original = MapLauncherPlatform.instance;
      MapLauncherPlatform.instance = _InstalledPlatform();
      addTearDown(() => MapLauncherPlatform.instance = original);
      for (final mode in TravelMode.values) {
        final request = MapLauncher.directions(
          LocationCoords(48.85, 2.29),
          mode: mode,
        );
        final url = request.getSchemeUrl(map: .sygicTruck, platform: .android);
        final maps = await request.getSupportedMaps([MapApp.sygicTruck]);
        if (mode == TravelMode.driving) {
          expect(url, 'com.sygic.aura://coordinate|2.29|48.85|drive');
          expect(maps, hasLength(1));
        } else {
          expect(url, isNull, reason: mode.name);
          expect(maps, isEmpty, reason: mode.name);
          await expectLater(request.show(map: .sygicTruck), noEligibleMap);
        }
      }
    },
  );

  test('custom Apple identity inherits the provider text-origin parameter', () {
    const origin = 'Louvre & Café';
    final request = MapLauncher.directions(
      LocationCoords(48.85, 2.29),
      from: LocationSearch(origin),
    );
    final query = Uri.parse(
      request.getUniversalUrl(map: const _CustomApple())!,
    ).queryParameters;
    expect(query['saddr'], origin);
    expect(query, isNot(contains('origin')));
    final custom = Uri.parse(
      request.getUniversalUrl(map: const _CustomOrigin())!,
    ).queryParameters;
    expect(custom['start'], origin);
    expect(custom, isNot(contains('saddr')));
  });
}
