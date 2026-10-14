@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/map_launcher_web.dart';
import 'package:web/web.dart' as web;

@JS('window.open')
external JSFunction get _open;

@JS('window.open')
external set _open(JSFunction value);

void main() {
  late JSFunction originalOpen;
  late MapLauncherPlatform originalPlatform;

  setUp(() {
    originalOpen = _open;
    originalPlatform = MapLauncherPlatform.instance;
    MapLauncherWeb.registerWith();
  });

  tearDown(() {
    _open = originalOpen;
    MapLauncherPlatform.instance = originalPlatform;
  });

  test('opens the requested URL in a new tab', () async {
    final calls = <(String, String)>[];
    _open = ((JSString url, JSString target) {
      calls.add((url.toDart, target.toDart));
      return web.window;
    }).toJS;

    final request = MapLauncher.marker(LocationSearch('Coffee & cake'));
    final pending = request.show();
    // The popup must be requested synchronously within the user's gesture.
    expect(calls, [(request.getUniversalUrl(map: .google)!, '_blank')]);
    await pending;
  });

  test('blocked popup becomes a launch exception without retrying', () async {
    var calls = 0;
    _open = (() {
      calls++;
      return null;
    }).toJS;

    await expectLater(
      MapLauncher.marker(LocationCoords(59.33, 18.07)).show(),
      throwsA(
        isA<MapLaunchException>()
            .having((e) => e.reason, 'reason', MapLaunchFailure.blocked)
            .having((e) => e.cause.toString(), 'cause', contains('blocked')),
      ),
    );
    expect(calls, 1);
  });
}
