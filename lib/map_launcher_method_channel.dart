import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/map_type.dart';

import 'map_launcher_platform_interface.dart';

/// Method channel implementation for Android and iOS.
///
/// Handles URL launching via native intents and app detection
/// via package manager / canOpenURL.
class MethodChannelMapLauncher extends MapLauncherPlatform {
  /// The method channel used for platform communication.
  @visibleForTesting
  final methodChannel = const MethodChannel('map_launcher');

  @override
  Future<void> launch(String url, {MapType? mapType}) async {
    await methodChannel.invokeMethod('launch', {
      'url': url,
      if (mapType?.playStoreId != null) 'packageName': mapType!.playStoreId,
    });
  }

  @override
  Future<List<MapType>> getInstalledMaps() async {
    final result = await methodChannel.invokeMethod('getInstalledMaps');
    if (result == null) return [];
    final maps = result as List;
    return maps
        .map((map) {
          final typeName = (map as Map)['mapType'] as String;
          try {
            return MapType.values.byName(typeName);
          } catch (_) {
            return null;
          }
        })
        .whereType<MapType>()
        .toList();
  }

  @override
  MapPlatform? get platform {
    if (kIsWeb) return null;
    if (Platform.isIOS) return .ios;
    if (Platform.isAndroid) return .android;
    return null; // desktop
  }
}
