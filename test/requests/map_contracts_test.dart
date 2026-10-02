import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:map_launcher/map_launcher_platform_interface.dart';

class _InstalledPlatform extends MapLauncherPlatform {
  @override
  MapPlatform? get platform => MapPlatform.android;

  @override
  Future<Set<String>> getInstalledMaps(List<MapApp> maps) async => {
    'sygicTruck',
  };
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
          await expectLater(
            request.show(map: .sygicTruck),
            throwsUnsupportedError,
          );
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
