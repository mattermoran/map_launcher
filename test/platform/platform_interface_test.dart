import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher_method_channel.dart';
import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Capture the initial instance before any test modifies it.
  final initialInstance = MapLauncherPlatform.instance;

  group('MapLauncherPlatform', () {
    test('default instance is MethodChannelMapLauncher', () {
      expect(initialInstance, isA<MethodChannelMapLauncher>());
    });

    test('cannot be implemented with "implements"', () {
      // PlatformInterface.verifyToken should throw when using `implements`
      // without MockPlatformInterfaceMixin.
      expect(() {
        MapLauncherPlatform.instance = _ImplementsMapLauncherPlatform();
      }, throwsA(anything));
    });

    test('can be extended', () {
      MapLauncherPlatform.instance = _ExtendsMapLauncherPlatform();
      expect(MapLauncherPlatform.instance, isA<_ExtendsMapLauncherPlatform>());
    });

    test('can be mocked with MockPlatformInterfaceMixin', () {
      final mock = MockMapLauncherPlatform();
      MapLauncherPlatform.instance = mock;
      expect(MapLauncherPlatform.instance, isA<MockMapLauncherPlatform>());
    });

    test('launch throws UnimplementedError by default', () {
      final platform = _ExtendsMapLauncherPlatform();
      expect(
        () => platform.launch('https://example.com'),
        throwsUnimplementedError,
      );
    });

    test('getInstalledMaps throws UnimplementedError by default', () {
      final platform = _ExtendsMapLauncherPlatform();
      expect(() => platform.getInstalledMaps(), throwsUnimplementedError);
    });

    test('platform returns null by default', () {
      final platform = _ExtendsMapLauncherPlatform();
      expect(platform.platform, isNull);
    });
  });
}

/// A class that incorrectly tries to implement MapLauncherPlatform
/// via `implements` (without the mock mixin). This should be rejected
/// by PlatformInterface.verifyToken.
class _ImplementsMapLauncherPlatform extends Fake
    implements MapLauncherPlatform {}

/// A class that correctly extends MapLauncherPlatform.
class _ExtendsMapLauncherPlatform extends MapLauncherPlatform {}

/// A mock that can be used as a platform substitute in tests.
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
