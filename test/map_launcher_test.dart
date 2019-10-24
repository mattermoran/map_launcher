import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher.dart';

void main() {
  const MethodChannel channel = MethodChannel('map_launcher');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await MapLauncher.platformVersion, '42');
  });
}
