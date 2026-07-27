import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/map_launcher.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMapLauncherPlatform mockPlatform;

  setUp(() {
    mockPlatform = MockMapLauncherPlatform();
    MapLauncherPlatform.instance = mockPlatform;
  });

  group('MapLauncher.marker', () {
    test('returns a MarkerRequest', () {
      final req = MapLauncher.marker(LocationCoords(37.759, -122.510));
      expect(req, isNotNull);
    });

    test('.show() launches correct URL for Google Maps with coords', () async {
      await MapLauncher.marker(
        LocationCoords(37.759, -122.510, title: 'Ocean Beach'),
      ).show(map: .google);

      expect(mockPlatform.launchedUrl, isNotNull);
      expect(mockPlatform.launchedUrl, contains('google.com/maps'));
      expect(mockPlatform.launchedUrl, contains('37.759'));
      expect(mockPlatform.launchedUrl, contains('-122.51'));
    });

    test('.show() launches correct URL for Google Maps with search', () async {
      await MapLauncher.marker(
        LocationSearch('Coffee shops'),
      ).show(map: .google);

      expect(mockPlatform.launchedUrl, isNotNull);
      expect(mockPlatform.launchedUrl, contains('google.com/maps'));
      expect(mockPlatform.launchedUrl, contains('Coffee'));
    });

    test('.show() includes zoom parameter when provided', () async {
      await MapLauncher.marker(
        LocationCoords(37.759, -122.510),
        zoom: 15,
      ).show(map: .apple);

      expect(mockPlatform.launchedUrl, contains('z=15'));
    });

    test('.show() appends extra params to URL', () async {
      await MapLauncher.marker(
        LocationCoords(37.759, -122.510),
        extra: {'layer': 'traffic'},
      ).show(map: .google);

      expect(mockPlatform.launchedUrl, contains('layer=traffic'));
    });

    test('.getUrl() returns URL without launching', () {
      final url = MapLauncher.marker(
        LocationCoords(37.759, -122.510),
      ).getUrl(map: .google);

      expect(url, isNotNull);
      expect(url, contains('google.com'));
      expect(mockPlatform.launchedUrl, isNull);
    });

    test('.show() uses scheme URL on iOS if available', () async {
      mockPlatform.platformResponse = .ios;

      await MapLauncher.marker(
        LocationCoords(37.759, -122.510, title: 'Test'),
      ).show(map: .google);

      expect(mockPlatform.launchedUrl, isNotNull);
      // iOS has Google Maps scheme installed, so scheme URL is preferred
      expect(mockPlatform.launchedUrl, startsWith('comgooglemaps://'));
    });

    test(
      '.getSupportedMaps(MapApp.all) includes universal link maps',
      () async {
        final apps = await MapLauncher.marker(
          LocationCoords(37.759, -122.510),
        ).getSupportedMaps(MapApp.all);

        final appIds = apps.map((a) => a.map).toList();
        expect(appIds, contains(MapApp.google));
        expect(appIds, contains(MapApp.apple));
      },
    );

    test(
      '.getSupportedMaps(MapApp.all) marks installed apps correctly',
      () async {
        mockPlatform.installedIds = {'google'};

        final apps = await MapLauncher.marker(
          LocationCoords(37.759, -122.510),
        ).getSupportedMaps(MapApp.all);

        final googleApp = apps.firstWhere((a) => a.map == MapApp.google);
        expect(googleApp.isInstalled, isTrue);

        final appleApp = apps.firstWhere((a) => a.map == MapApp.apple);
        expect(appleApp.isInstalled, isFalse);
      },
    );

    test(
      '.getSupportedMaps(MapApp.all) includes installed native-only apps',
      () async {
        mockPlatform.installedIds = {'kakao', 'naver'};

        final apps = await MapLauncher.marker(
          LocationCoords(37.759, -122.510),
        ).getSupportedMaps(MapApp.all);

        final appIds = apps.map((a) => a.map).toList();
        expect(appIds, contains(MapApp.kakao));
        expect(appIds, contains(MapApp.naver));
      },
    );
  });

  group('MapLauncher.directions', () {
    test('returns a DirectionsRequest', () {
      final req = MapLauncher.directions(LocationCoords(37.759, -122.510));
      expect(req, isNotNull);
    });

    test('.show() launches correct URL for Google Maps directions', () async {
      await MapLauncher.directions(
        LocationCoords(37.759, -122.510, title: 'Beach'),
      ).show(map: .google);

      expect(mockPlatform.launchedUrl, isNotNull);
      expect(mockPlatform.launchedUrl, contains('google.com/maps'));
      expect(mockPlatform.launchedUrl, contains('37.759'));
    });

    test('.show() includes origin when provided', () async {
      await MapLauncher.directions(
        LocationCoords(37.759, -122.510),
        from: LocationCoords(37.785, -122.409, title: 'Start'),
      ).show(map: .google);

      expect(mockPlatform.launchedUrl, contains('37.785'));
      expect(mockPlatform.launchedUrl, contains('-122.409'));
    });

    test('.show() includes travel mode when provided', () async {
      await MapLauncher.directions(
        LocationCoords(37.759, -122.510),
        mode: .walking,
      ).show(map: .google);

      expect(mockPlatform.launchedUrl, contains('walking'));
    });

    test('.show() includes waypoints when provided', () async {
      await MapLauncher.directions(
        LocationCoords(37.759, -122.510),
        waypoints: [
          LocationCoords(37.770, -122.480),
          LocationCoords(37.765, -122.460),
        ],
      ).show(map: .google);

      expect(mockPlatform.launchedUrl, contains('37.77'));
      expect(mockPlatform.launchedUrl, contains('37.765'));
    });

    test('.show() works with Apple Maps', () async {
      await MapLauncher.directions(
        LocationCoords(37.759, -122.510),
      ).show(map: .apple);

      expect(mockPlatform.launchedUrl, contains('maps.apple.com'));
    });

    test('.show() works with Waze', () async {
      await MapLauncher.directions(
        LocationCoords(37.759, -122.510),
      ).show(map: .waze);

      expect(mockPlatform.launchedUrl, isNotNull);
      // Waze is scheme-only for directions. Always returns waze://
      expect(mockPlatform.launchedUrl, startsWith('waze://'));
    });
  });

  group('MapLauncher.getAvailableMaps(MapApp.all)', () {
    test('returns universal link maps even with no installed apps', () async {
      mockPlatform.installedIds = {};

      final maps = await MapLauncher.getAvailableMaps(MapApp.all);
      final mapApps = maps.map((m) => m.map).toList();

      // All Tier 1 universal link maps should be present
      expect(mapApps, contains(MapApp.google));
      expect(mapApps, contains(MapApp.apple));
      expect(mapApps, contains(MapApp.waze));
      expect(mapApps, contains(MapApp.yandexMaps));
      expect(mapApps, contains(MapApp.doubleGis));
    });

    test(
      'returns installed native-only apps alongside universal maps',
      () async {
        mockPlatform.installedIds = {'kakao', 'baidu'};

        final maps = await MapLauncher.getAvailableMaps(MapApp.all);
        final mapApps = maps.map((m) => m.map).toList();

        // Installed scheme-only apps should appear
        expect(mapApps, contains(MapApp.kakao));
        expect(mapApps, contains(MapApp.baidu));
        // Universal maps still present
        expect(mapApps, contains(MapApp.google));
      },
    );

    test(
      'marks isInstalled correctly for installed vs browser-only maps',
      () async {
        mockPlatform.installedIds = {'google'};

        final maps = await MapLauncher.getAvailableMaps(MapApp.all);

        final googleMap = maps.firstWhere((m) => m.map == MapApp.google);
        expect(googleMap.isInstalled, isTrue);

        final appleMap = maps.firstWhere((m) => m.map == MapApp.apple);
        expect(appleMap.isInstalled, isFalse);
      },
    );

    test('does NOT include scheme-only maps that are not installed', () async {
      // Kakao has no universal link and is not installed
      mockPlatform.installedIds = {};

      final maps = await MapLauncher.getAvailableMaps(MapApp.all);
      final mapApps = maps.map((m) => m.map).toList();

      expect(mapApps, isNot(contains(MapApp.kakao)));
      expect(mapApps, isNot(contains(MapApp.naver)));
      expect(mapApps, isNot(contains(MapApp.baidu)));
    });
  });

  group('MarkerRequest.getUniversalUrl() and getSchemeUrl()', () {
    test('getUniversalUrl() returns HTTPS URL for Google Maps', () {
      final req = MapLauncher.marker(LocationCoords(48.85, 2.29));
      final url = req.getUniversalUrl(map: .google);

      expect(url, isNotNull);
      expect(url, startsWith('https://'));
      expect(url, contains('google.com/maps'));
      expect(url, contains('48.85'));
    });

    test('getUniversalUrl() returns null for a map with no universal URL', () {
      // Citymapper has supportsMarkerCoords = false, markerUrl returns null
      final req = MapLauncher.marker(LocationCoords(48.85, 2.29));
      final url = req.getUniversalUrl(map: .citymapper);

      expect(url, isNull);
    });

    test(
      'getSchemeUrl() returns comgooglemaps:// scheme for Google on iOS',
      () {
        final req = MapLauncher.marker(LocationCoords(48.85, 2.29));
        final url = req.getSchemeUrl(map: .google, platform: .ios);

        expect(url, isNotNull);
        expect(url, startsWith('comgooglemaps://'));
        expect(url, contains('48.85'));
      },
    );

    test('getSchemeUrl() returns null for Google on Android (no scheme)', () {
      final req = MapLauncher.marker(LocationCoords(48.85, 2.29));
      final url = req.getSchemeUrl(map: .google, platform: .android);

      expect(url, isNull);
    });

    test(
      'getSchemeUrl() returns dgis:// for 2GIS regardless of iOS/Android flag',
      () {
        final req = MapLauncher.marker(LocationCoords(55.75, 37.62));

        final urlIOS = req.getSchemeUrl(map: .doubleGis, platform: .ios);
        final urlAndroid = req.getSchemeUrl(
          map: .doubleGis,
          platform: .android,
        );

        // 2GIS uses dgis:// on both platforms
        expect(urlIOS, isNotNull);
        expect(urlIOS, startsWith('dgis://'));
        expect(urlAndroid, isNotNull);
        expect(urlAndroid, startsWith('dgis://'));
      },
    );

    test('getSchemeUrl() returns scheme URL for search on supported maps', () {
      final req = MapLauncher.marker(LocationSearch('Coffee shops'));
      // Google supports scheme search on iOS
      final url = req.getSchemeUrl(map: .google, platform: .ios);
      expect(url, isNotNull);
      expect(url, contains('comgooglemaps://'));
      expect(url, contains('Coffee'));
    });

    test('getSchemeUrl() returns null for search on unsupported maps', () {
      final req = MapLauncher.marker(LocationSearch('Coffee shops'));
      // Waze has no markerSchemeSearchUrl
      final url = req.getSchemeUrl(map: .waze, platform: .ios);
      expect(url, isNull);
    });
  });

  group('MarkerRequest.getUrl() respects platform', () {
    test(
      'on mobile, returns scheme URL when available (e.g. 2GIS dgis://)',
      () {
        mockPlatform.platformResponse = .android;

        final url = MapLauncher.marker(
          LocationCoords(55.75, 37.62),
        ).getUrl(map: .doubleGis);

        expect(url, isNotNull);
        expect(url, startsWith('dgis://'));
      },
    );

    test('on web, returns universal HTTPS URL even when scheme exists', () {
      final webMockPlatform = MockMapLauncherPlatform();
      webMockPlatform.platformResponse = null;
      MapLauncherPlatform.instance = webMockPlatform;

      final url = MapLauncher.marker(
        LocationCoords(55.75, 37.62),
      ).getUrl(map: .doubleGis);

      expect(url, isNotNull);
      expect(url, startsWith('https://'));
      expect(url, contains('2gis.ru'));
    });

    test('on web, never returns a custom scheme URL for Google Maps', () {
      final webMockPlatform = MockMapLauncherPlatform();
      webMockPlatform.platformResponse = null; // simulate web
      MapLauncherPlatform.instance = webMockPlatform;

      final url = MapLauncher.marker(
        LocationCoords(48.85, 2.29),
      ).getUrl(map: .google);

      expect(url, isNotNull);
      expect(url, startsWith('https://'));
    });
  });

  group('DirectionsRequest.getSupportedMaps(MapApp.all) filtering', () {
    test('filters out maps that do not support search destinations', () async {
      // Google and Apple support directionsSearch; most others don't
      mockPlatform.installedIds = {'waze', 'kakao'};

      final maps = await MapLauncher.directions(
        LocationSearch('Eiffel Tower'),
      ).getSupportedMaps(MapApp.all);

      final mapApps = maps.map((m) => m.map).toList();

      // Google supports directionsSearch + has universal link
      expect(mapApps, contains(MapApp.google));
      // Apple supports directionsSearch + has universal link
      expect(mapApps, contains(MapApp.apple));
      // Waze does NOT support directionsSearch
      expect(mapApps, isNot(contains(MapApp.waze)));
      // Kakao does NOT support directionsSearch
      expect(mapApps, isNot(contains(MapApp.kakao)));
    });

    test(
      'filters out maps that do not support waypoints when waypoints given',
      () async {
        // Only Google has supportsWaypoints = true
        mockPlatform.installedIds = {};

        final maps = await MapLauncher.directions(
          LocationCoords(48.85, 2.29),
          waypoints: [LocationCoords(48.86, 2.34)],
        ).getSupportedMaps(MapApp.all);

        final mapApps = maps.map((m) => m.map).toList();

        // Google supports waypoints + has universal link
        expect(mapApps, contains(MapApp.google));
        // Apple does NOT support waypoints, should be filtered out
        expect(mapApps, isNot(contains(MapApp.apple)));
        // Waze does NOT support waypoints
        expect(mapApps, isNot(contains(MapApp.waze)));
      },
    );

    test(
      'returns all coord-capable maps when no mode, waypoints, or search used',
      () async {
        mockPlatform.installedIds = {};

        final mapsFiltered = await MapLauncher.directions(
          LocationCoords(48.85, 2.29),
          waypoints: [LocationCoords(48.86, 2.34)],
        ).getSupportedMaps(MapApp.all);

        final mapsUnfiltered = await MapLauncher.directions(
          LocationCoords(48.85, 2.29),
        ).getSupportedMaps(MapApp.all);

        // Without waypoints, more maps should be available
        expect(mapsUnfiltered.length, greaterThan(mapsFiltered.length));
      },
    );
  });
}

/// Mock platform implementation for testing MapLauncher.
class MockMapLauncherPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements MapLauncherPlatform {
  String? launchedUrl;
  Set<String> installedIds = {};
  MapPlatform? platformResponse = .android;

  @override
  Future<void> launch(String url, {String? androidPackageName}) async {
    launchedUrl = url;
  }

  @override
  Future<Set<String>> getInstalledMaps(List<MapApp> maps) async {
    return installedIds;
  }

  @override
  MapPlatform? get platform => platformResponse;
}
