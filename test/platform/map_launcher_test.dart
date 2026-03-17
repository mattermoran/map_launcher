import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/map_launcher.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
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

    test('.getSupportedMaps() includes universal link maps', () async {
      final apps = await MapLauncher.marker(
        LocationCoords(37.759, -122.510),
      ).getSupportedMaps();

      final appIds = apps.map((a) => a.mapType).toList();
      expect(appIds, contains(MapType.google));
      expect(appIds, contains(MapType.apple));
    });

    test('.getSupportedMaps() marks installed apps correctly', () async {
      mockPlatform.installedMapsResponse = [MapType.google];

      final apps = await MapLauncher.marker(
        LocationCoords(37.759, -122.510),
      ).getSupportedMaps();

      final googleApp = apps.firstWhere((a) => a.mapType == .google);
      expect(googleApp.isInstalled, isTrue);

      final appleApp = apps.firstWhere((a) => a.mapType == .apple);
      expect(appleApp.isInstalled, isFalse);
    });

    test('.getSupportedMaps() includes installed native-only apps', () async {
      mockPlatform.installedMapsResponse = [MapType.kakao, MapType.naver];

      final apps = await MapLauncher.marker(
        LocationCoords(37.759, -122.510),
      ).getSupportedMaps();

      final appIds = apps.map((a) => a.mapType).toList();
      expect(appIds, contains(MapType.kakao));
      expect(appIds, contains(MapType.naver));
    });
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
      // Waze is scheme-only for directions — always returns waze://
      expect(mockPlatform.launchedUrl, startsWith('waze://'));
    });
  });

  group('MapLauncher.getAvailableMaps()', () {
    test('returns universal link maps even with no installed apps', () async {
      mockPlatform.installedMapsResponse = [];

      final maps = await MapLauncher.getAvailableMaps();
      final mapTypes = maps.map((m) => m.mapType).toList();

      // All Tier 1 universal link maps should be present
      expect(mapTypes, contains(MapType.google));
      expect(mapTypes, contains(MapType.apple));
      expect(mapTypes, contains(MapType.waze));
      expect(mapTypes, contains(MapType.yandexMaps));
      expect(mapTypes, contains(MapType.doubleGis));
    });

    test(
      'returns installed native-only apps alongside universal maps',
      () async {
        mockPlatform.installedMapsResponse = [MapType.kakao, MapType.baidu];

        final maps = await MapLauncher.getAvailableMaps();
        final mapTypes = maps.map((m) => m.mapType).toList();

        // Installed scheme-only apps should appear
        expect(mapTypes, contains(MapType.kakao));
        expect(mapTypes, contains(MapType.baidu));
        // Universal maps still present
        expect(mapTypes, contains(MapType.google));
      },
    );

    test(
      'marks isInstalled correctly for installed vs browser-only maps',
      () async {
        mockPlatform.installedMapsResponse = [MapType.google];

        final maps = await MapLauncher.getAvailableMaps();

        final googleMap = maps.firstWhere((m) => m.mapType == .google);
        expect(googleMap.isInstalled, isTrue);

        final appleMap = maps.firstWhere((m) => m.mapType == .apple);
        expect(appleMap.isInstalled, isFalse);
      },
    );

    test('does NOT include scheme-only maps that are not installed', () async {
      // Kakao has no universal link and is not installed
      mockPlatform.installedMapsResponse = [];

      final maps = await MapLauncher.getAvailableMaps();
      final mapTypes = maps.map((m) => m.mapType).toList();

      expect(mapTypes, isNot(contains(MapType.kakao)));
      expect(mapTypes, isNot(contains(MapType.naver)));
      expect(mapTypes, isNot(contains(MapType.baidu)));
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

  group('DirectionsRequest.getSupportedMaps() filtering', () {
    test('filters out maps that do not support search destinations', () async {
      // Google and Apple support directionsSearch; most others don't
      mockPlatform.installedMapsResponse = [MapType.waze, MapType.kakao];

      final maps = await MapLauncher.directions(
        LocationSearch('Eiffel Tower'),
      ).getSupportedMaps();

      final mapTypes = maps.map((m) => m.mapType).toList();

      // Google supports directionsSearch + has universal link
      expect(mapTypes, contains(MapType.google));
      // Apple supports directionsSearch + has universal link
      expect(mapTypes, contains(MapType.apple));
      // Waze does NOT support directionsSearch
      expect(mapTypes, isNot(contains(MapType.waze)));
      // Kakao does NOT support directionsSearch
      expect(mapTypes, isNot(contains(MapType.kakao)));
    });

    test(
      'filters out maps that do not support waypoints when waypoints given',
      () async {
        // Only Google has supportsWaypoints = true
        mockPlatform.installedMapsResponse = [];

        final maps = await MapLauncher.directions(
          LocationCoords(48.85, 2.29),
          waypoints: [LocationCoords(48.86, 2.34)],
        ).getSupportedMaps();

        final mapTypes = maps.map((m) => m.mapType).toList();

        // Google supports waypoints + has universal link
        expect(mapTypes, contains(MapType.google));
        // Apple does NOT support waypoints — should be filtered out
        expect(mapTypes, isNot(contains(MapType.apple)));
        // Waze does NOT support waypoints
        expect(mapTypes, isNot(contains(MapType.waze)));
      },
    );

    test(
      'returns all coord-capable maps when no mode, waypoints, or search used',
      () async {
        mockPlatform.installedMapsResponse = [];

        final mapsFiltered = await MapLauncher.directions(
          LocationCoords(48.85, 2.29),
          waypoints: [LocationCoords(48.86, 2.34)],
        ).getSupportedMaps();

        final mapsUnfiltered = await MapLauncher.directions(
          LocationCoords(48.85, 2.29),
        ).getSupportedMaps();

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
  List<MapType> installedMapsResponse = [];
  MapPlatform? platformResponse = .android;

  @override
  Future<void> launch(String url, {MapType? mapType}) async {
    launchedUrl = url;
  }

  @override
  Future<List<MapType>> getInstalledMaps() async {
    return installedMapsResponse;
  }

  @override
  MapPlatform? get platform => platformResponse;
}
