import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:map_launcher/map_launcher_platform_interface.dart';

class _DeferredPlatform extends MapLauncherPlatform {
  final detection = Completer<Set<String>>();
  String? launchedUrl;

  @override
  Future<Set<String>> getInstalledMaps(List<MapApp> maps) => detection.future;

  @override
  Future<void> launch(String url, {String? androidPackageName}) async {
    launchedUrl = url;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'requests snapshot constructor collections and expose read-only values',
    () {
      final extra = {'key': 'original'};
      final stop = LocationCoords(3, 4);
      final waypoints = [stop];
      final marker = MapLauncher.marker(LocationCoords(1, 2), extra: extra);
      final directions = MapLauncher.directions(
        LocationCoords(1, 2),
        waypoints: waypoints,
        extra: extra,
      );
      extra['key'] = 'changed';
      waypoints.clear();
      expect(marker.extra, {'key': 'original'});
      expect(directions.extra, {'key': 'original'});
      expect(directions.waypoints, [stop]);
      expect(() => marker.extra!.clear(), throwsUnsupportedError);
      expect(() => directions.extra!.clear(), throwsUnsupportedError);
      expect(() => directions.waypoints!.clear(), throwsUnsupportedError);
    },
  );

  for (final directions in [false, true]) {
    test(
      'show snapshots extras before discovery (directions: $directions)',
      () async {
        final original = MapLauncherPlatform.instance;
        final platform = _DeferredPlatform();
        MapLauncherPlatform.instance = platform;
        addTearDown(() => MapLauncherPlatform.instance = original);
        final extra = {'key': 'original'};
        final location = LocationCoords(1, 2);
        final pending = directions
            ? MapLauncher.directions(location).show(extra: extra)
            : MapLauncher.marker(location).show(extra: extra);
        extra['key'] = 'changed';
        platform.detection.complete({});
        await pending;
        expect(
          Uri.parse(platform.launchedUrl!).queryParameters['key'],
          'original',
        );
      },
    );
  }
}
