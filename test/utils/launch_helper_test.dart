import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/models/supported_map.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/utils/launch_helper.dart';

class FakePlatform extends MapLauncherPlatform {
  FakePlatform({this.platformOverride});
  final MapPlatform? platformOverride;

  @override
  MapPlatform? get platform => platformOverride;

  @override
  Future<void> launch(String url, {String? androidPackageName}) async {}

  @override
  Future<Set<String>> getInstalledMaps(List<MapApp> maps) async => {};
}

void main() {
  group('appendQueryParams', () {
    test('returns url unchanged when extraParams is null', () {
      expect(
        appendQueryParams('https://maps.google.com/path', null),
        'https://maps.google.com/path',
      );
    });

    test('returns url unchanged when extraParams is empty', () {
      expect(
        appendQueryParams('https://maps.google.com/path', {}),
        'https://maps.google.com/path',
      );
    });

    test('appends params to HTTP URL without existing query', () {
      final result = appendQueryParams('https://maps.google.com/path', {
        'z': '5',
      });
      expect(result, contains('?z=5'));
    });

    test('appends params to HTTP URL with existing query', () {
      final result = appendQueryParams('https://x.com?a=1', {'b': '2'});
      expect(result, contains('a=1'));
      expect(result, contains('b=2'));
    });

    test('appends params to scheme URL', () {
      final result = appendQueryParams('waze://?ll=1,2', {'z': '5'});
      expect(result, 'waze://?ll=1,2&z=5');
    });

    test('appends params to scheme URL without query', () {
      final result = appendQueryParams('comgooglemaps://', {'q': 'test'});
      expect(result, 'comgooglemaps://?q=test');
    });

    test('appends params to geo: URL', () {
      final result = appendQueryParams('geo:1,2', {'q': '1,2'});
      expect(result, contains('?q='));
    });

    test('handles URLs with fragments', () {
      final result = appendQueryParams('https://x.com#frag', {'a': '1'});
      expect(result, contains('?a=1#frag'));
    });

    test('handles URLs with query AND fragment', () {
      final result = appendQueryParams('https://x.com?a=1#frag', {'b': '2'});
      expect(result, endsWith('&b=2#frag'));
      expect(result, startsWith('https://x.com?a=1'));
    });

    test('properly encodes special characters in values', () {
      final result = appendQueryParams('https://x.com', {
        'q': 'hello world & friends',
      });
      expect(result, 'https://x.com?q=hello+world+%26+friends');
    });
  });

  group('resolveBestMap', () {
    setUp(() {
      MapLauncherPlatform.instance = FakePlatform();
    });

    test('returns null when getSupportedMaps returns empty list', () async {
      final result = await resolveBestMap(() async => []);
      expect(result, isNull);
    });

    test('returns Apple Maps when on iOS and Apple is in list', () async {
      MapLauncherPlatform.instance = FakePlatform(
        platformOverride: MapPlatform.ios,
      );
      final apps = [
        const SupportedMap(map: .google, isInstalled: true),
        const SupportedMap(map: .apple, isInstalled: true),
      ];
      final result = await resolveBestMap(() async => apps);
      expect(result, MapApp.apple);
    });

    test('returns Google Maps when NOT on iOS and Google is in list', () async {
      MapLauncherPlatform.instance = FakePlatform(
        platformOverride: MapPlatform.android,
      );
      final apps = [
        const SupportedMap(map: .apple, isInstalled: true),
        const SupportedMap(map: .google, isInstalled: true),
      ];
      final result = await resolveBestMap(() async => apps);
      expect(result, MapApp.google);
    });

    test('returns first installed app when default is not in list', () async {
      MapLauncherPlatform.instance = FakePlatform(
        platformOverride: MapPlatform.android,
      );
      final apps = [
        const SupportedMap(map: .waze, isInstalled: false),
        const SupportedMap(map: .yandexMaps, isInstalled: true),
        const SupportedMap(map: .here, isInstalled: true),
      ];
      final result = await resolveBestMap(() async => apps);
      expect(result, MapApp.yandexMaps);
    });

    test('returns first app when no installed apps match', () async {
      MapLauncherPlatform.instance = FakePlatform(
        platformOverride: MapPlatform.android,
      );
      final apps = [
        const SupportedMap(map: .waze, isInstalled: false),
        const SupportedMap(map: .yandexMaps, isInstalled: false),
      ];
      final result = await resolveBestMap(() async => apps);
      expect(result, MapApp.waze);
    });

    test('prefers default over other installed apps', () async {
      MapLauncherPlatform.instance = FakePlatform(
        platformOverride: MapPlatform.android,
      );
      final apps = [
        const SupportedMap(map: .waze, isInstalled: true),
        const SupportedMap(map: .google, isInstalled: true),
        const SupportedMap(map: .yandexMaps, isInstalled: true),
      ];
      final result = await resolveBestMap(() async => apps);
      expect(result, MapApp.google);
    });
  });
}
