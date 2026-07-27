import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:map_launcher/map_launcher_method_channel.dart';
import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A consumer-defined map, written the way the README documents it:
/// plain subclass, no plugin internals, URLs built by hand.
class AcmeMaps extends MapApp {
  const AcmeMaps();

  @override
  String get id => 'acmeMaps';

  @override
  String get name => 'Acme Maps';

  @override
  bool get hasUniversalLink => true;

  @override
  String? get playStoreId => 'com.acme.maps';

  @override
  String? get appStoreId => '123456789';

  @override
  String? get iosScheme => 'acmemaps://';

  @override
  Uint8List get iconBytes => Uint8List.fromList([1, 2, 3]);

  @override
  String? markerUrl(LocationCoords coords, {int? zoom}) =>
      'https://maps.acme.com/?ll=${coords.latlng}';

  @override
  String? markerSchemeUrl(
    LocationCoords coords, {
    int? zoom,
    required MapPlatform platform,
  }) => 'acmemaps://marker?ll=${coords.latlng}';

  @override
  String? directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  }) => 'https://maps.acme.com/dir?to=${destination.latlng}';
}

/// A minimal custom map: no universal link, no marker-search support.
class NavOnlyMap extends MapApp {
  const NavOnlyMap();

  @override
  String get id => 'navOnly';

  @override
  String get name => 'Nav Only';

  @override
  String? get playStoreId => 'com.example.navonly';

  @override
  Uint8List get iconBytes => Uint8List.fromList([4, 5, 6]);

  @override
  bool get supportsMarkerCoords => false;

  @override
  String? markerUrl(LocationCoords coords, {int? zoom}) => null;

  @override
  String? directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  }) => null;

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => 'navonly://route?to=${destination.latlng}';
}

class _MockPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements MapLauncherPlatform {
  String? launchedUrl;
  String? launchedPackageName;
  List<MapApp>? probedMaps;
  Set<String> installedIds = {};
  MapPlatform? platformResponse = .android;

  @override
  Future<void> launch(String url, {String? androidPackageName}) async {
    launchedUrl = url;
    launchedPackageName = androidPackageName;
  }

  @override
  Future<Set<String>> getInstalledMaps(List<MapApp> maps) async {
    probedMaps = maps;
    return installedIds;
  }

  @override
  MapPlatform? get platform => platformResponse;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockPlatform mock;

  setUp(() {
    mock = _MockPlatform();
    MapLauncherPlatform.instance = mock;
  });

  group('custom MapApp', () {
    const acme = AcmeMaps();
    final coords = LocationCoords(48.85, 2.29, title: 'Eiffel Tower');

    test('derives store URLs from ids like built-in maps', () {
      expect(
        acme.playStoreUrl,
        'https://play.google.com/store/apps/details?id=com.acme.maps',
      );
      expect(acme.appStoreUrl, 'https://apps.apple.com/app/id123456789');
    });

    test(
      'show() launches the scheme URL on mobile with package pinning',
      () async {
        await MapLauncher.marker(coords).show(map: acme);

        expect(mock.launchedUrl, 'acmemaps://marker?ll=48.85,2.29');
        expect(mock.launchedPackageName, 'com.acme.maps');
      },
    );

    test('show() uses the universal URL on web/desktop', () async {
      mock.platformResponse = null;

      await MapLauncher.marker(coords).show(map: acme);

      expect(mock.launchedUrl, 'https://maps.acme.com/?ll=48.85,2.29');
    });

    test('is probed alongside built-in maps in discovery', () async {
      await MapLauncher.marker(coords).getSupportedMaps([.google, acme]);

      expect(mock.probedMaps, containsAll([MapApp.google, acme]));
    });

    test('appears installed and launchable from getSupportedMaps', () async {
      mock.installedIds = {'acmeMaps'};

      final maps = await MapLauncher.marker(
        coords,
      ).getSupportedMaps([.google, acme]);

      final entry = maps.singleWhere((m) => m.map == acme);
      expect(entry.isInstalled, isTrue);
      expect(entry.name, 'Acme Maps');
      expect(entry.iconBytes, isNotEmpty);

      await entry.show();
      expect(mock.launchedUrl, 'acmemaps://marker?ll=48.85,2.29');
    });

    test(
      'included as browser fallback when not installed (universal link)',
      () async {
        final maps = await MapLauncher.marker(coords).getSupportedMaps([acme]);

        final entry = maps.singleWhere((m) => m.map == acme);
        expect(entry.isInstalled, isFalse);
        expect(entry.opensInBrowser, isTrue);
      },
    );

    test('excluded when not installed and no universal link', () async {
      final maps = await MapLauncher.directions(
        coords,
      ).getSupportedMaps([const NavOnlyMap()]);

      expect(maps, isEmpty);
    });

    test('capability flags filter requests like built-in maps', () async {
      mock.installedIds = {'navOnly'};
      const navOnly = NavOnlyMap();

      final markerMaps = await MapLauncher.marker(
        coords,
      ).getSupportedMaps([navOnly]);
      expect(markerMaps, isEmpty);

      final directionMaps = await MapLauncher.directions(
        coords,
      ).getSupportedMaps([navOnly]);
      expect(directionMaps.map((m) => m.map), [navOnly]);
    });

    test('works with MapLauncher.getAvailableMaps', () async {
      mock.installedIds = {'navOnly'};

      final maps = await MapLauncher.getAvailableMaps([
        acme,
        const NavOnlyMap(),
      ]);

      expect(maps.map((m) => m.map.id), ['acmeMaps', 'navOnly']);
    });
  });

  group('custom MapApp over the method channel', () {
    const channel = MethodChannel('map_launcher');
    final log = <MethodCall>[];
    final launcher = MethodChannelMapLauncher();

    setUp(() {
      log.clear();
      MethodChannelMapLauncher.warnedUndeclaredIds.clear();
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            log.add(methodCall);
            return {
              'installed': <String>[],
              'undeclared': ['acmeMaps'],
            };
          });
    });

    test('probe payload includes the custom scheme on iOS', () async {
      await launcher.getInstalledMaps([.google, const AcmeMaps()]);

      expect(log.single.arguments, {
        'google': 'comgooglemaps://',
        'acmeMaps': 'acmemaps://',
      });
    });

    test('undeclared warning names the custom map and its scheme', () async {
      final warnings = <String>[];
      final original = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        warnings.add(message ?? '');
      };
      addTearDown(() => debugPrint = original);

      await launcher.getInstalledMaps([const AcmeMaps()]);

      expect(warnings, hasLength(1));
      expect(warnings.first, contains("MapApp.acmeMaps → add 'acmemaps'"));
    });
  });
}
