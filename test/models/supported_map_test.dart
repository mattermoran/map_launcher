import 'package:test/test.dart';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/models/supported_map.dart';

void main() {
  test(
    'availability metadata delegates provider details without a request',
    () {
      const google = AvailableMap(map: MapApp.google, isInstalled: false);
      expect(google.name, MapApp.google.name);
      expect(google.iconBytes, MapApp.google.iconBytes);
      expect(google.isInstalled, isFalse);
      expect(google.hasUniversalLink, isTrue);
      expect(google.appStoreUrl, contains(MapApp.google.appStoreId!));
      expect(google.playStoreUrl, contains(MapApp.google.playStoreId!));
      const native = AvailableMap(map: MapApp.flitsmeister, isInstalled: true);
      expect(native.isInstalled, isTrue);
      expect(native.hasUniversalLink, isFalse);
      expect(native.appStoreUrl, isNull);
      expect(
        const AvailableMap(map: MapApp.apple, isInstalled: false).playStoreUrl,
        isNull,
      );
    },
  );

  test('availability has value equality by provider and installation', () {
    const first = AvailableMap(map: MapApp.google, isInstalled: true);
    const same = AvailableMap(map: MapApp.google, isInstalled: true);
    expect(first, same);
    expect(first.hashCode, same.hashCode);
    expect(
      first,
      isNot(const AvailableMap(map: MapApp.google, isInstalled: false)),
    );
    expect(
      first,
      isNot(const AvailableMap(map: MapApp.apple, isInstalled: true)),
    );
  });

  test(
    'prepared entries retain distinct launch callbacks, not metadata equality',
    () async {
      final calls = <String>[];
      final first = SupportedMap.launchable(
        map: MapApp.google,
        isInstalled: true,
        launcher: () async {
          calls.add('first request');
        },
      );
      final second = SupportedMap.launchable(
        map: MapApp.google,
        isInstalled: true,
        launcher: () async {
          calls.add('second request');
        },
      );
      expect(first, isNot(second));
      const metadata = AvailableMap(map: MapApp.google, isInstalled: true);
      expect(first == metadata, isFalse);
      expect(metadata == first, isFalse);
      await second.show();
      await first.show();
      expect(calls, ['second request', 'first request']);
    },
  );
}
