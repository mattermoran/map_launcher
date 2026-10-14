import 'package:flutter/foundation.dart';
import 'package:map_launcher/map_launcher.dart';

abstract final class DemoData {
  // This showcase opts into every provider. A consumer app should choose only
  // its own providers and match its Android/iOS query declarations to that list.
  static final maps = <MapApp>[
    .apple,
    .google,
    .waze,
    .yandexMaps,
    .doubleGis,
    .here,
    .mapyCz,
    .mappls,
    .googleGo,
    .amap,
    const BaiduMaps(source: 'fluttered.map_launcher_example'),
    .yandexNavi,
    .citymapper,
    .mapswithme,
    .osmand,
    .osmandplus,
    .tencent,
    .petal,
    .tomtomgo,
    .tomtomgofleet,
    .copilot,
    .sygicTruck,
    .flitsmeister,
    NaverMap(
      appName: defaultTargetPlatform == TargetPlatform.iOS
          ? 'dev.fluttered.mapLauncherExample'
          : 'dev.fluttered.map_launcher_example',
    ),
    .kakao,
    .tmap,
    .moovit,
    .neshan,
    .airnavPro,
    .magicEarth,
  ];

  static final destination = LocationCoords(
    48.8584,
    2.2945,
    title: 'Eiffel Tower',
  );
  static final origin = LocationCoords(48.8606, 2.3376, title: 'Louvre Museum');
}
