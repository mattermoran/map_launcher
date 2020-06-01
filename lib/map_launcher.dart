import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum MapType { apple, google, amap, baidu, waze, yandexNavi, yandexMaps, citymapper }

String _enumToString(o) => o.toString().split('.').last;

T _enumFromString<T>(Iterable<T> values, String value) {
  return values.firstWhere((type) => type.toString().split('.').last == value,
      orElse: () => null);
}

class Coords {
  final double latitude;
  final double longitude;

  Coords(this.latitude, this.longitude);
}

class AvailableMap {
  String mapName;
  MapType mapType;
  AssetImage icon;

  AvailableMap({this.mapName, this.mapType, this.icon});

  static AvailableMap fromJson(json) {
    return AvailableMap(
      mapName: json['mapName'],
      mapType: _enumFromString(MapType.values, json['mapType']),
      icon: AssetImage(
        'assets/icons/${json['mapType']}.png',
        package: 'map_launcher',
      ),
    );
  }

  Future<void> showMarker({
    @required Coords coords,
    @required String title,
    @required String description,
  }) {
    return MapLauncher.launchMap(
      mapType: mapType,
      coords: coords,
      title: title,
      description: description,
    );
  }

  @override
  String toString() {
    return 'AvailableMap { mapName: $mapName, mapType: ${_enumToString(mapType)} }';
  }
}

String _getMapUrl(
  MapType mapType,
  Coords coords, [
  String title,
  String description,
]) {
  switch (mapType) {
    case MapType.google:
      if (Platform.isIOS) {
        return 'comgooglemaps://?q=${coords.latitude},${coords.longitude}($title)';
      }
      return 'geo:0,0?q=${coords.latitude},${coords.longitude}($title)';
    case MapType.amap:
      return '${Platform.isIOS ? 'ios' : 'android'}amap://viewMap?sourceApplication=map_launcher&poiname=$title&lat=${coords.latitude}&lon=${coords.longitude}&zoom=18&dev=0';
    case MapType.baidu:
      return 'baidumap://map/marker?location=${coords.latitude},${coords.longitude}&title=$title&content=$description&traffic=on&src=com.map_launcher&coord_type=gcj02&zoom=18';
    case MapType.apple:
      return 'http://maps.apple.com/maps?saddr=${coords.latitude},${coords.longitude}';
    case MapType.waze:
      return 'waze://?ll=${coords.latitude},${coords.longitude}&zoom=10';
    case MapType.yandexNavi:
      return 'yandexnavi://show_point_on_map?lat=${coords.latitude}&lon=${coords.longitude}&zoom=16&no-balloon=0&desc=$title';
    case MapType.yandexMaps:
      return 'yandexmaps://maps.yandex.ru/?pt=${coords.longitude},${coords.latitude}&z=16&l=map';
    case MapType.citymapper:
      return 'citymapper://directions?endcoord=${coords.latitude},${coords.longitude}&endname=$title';
    default:
      return null;
  }
}

class MapLauncher {
  static const MethodChannel _channel = const MethodChannel('map_launcher');

  static Future<List<AvailableMap>> get installedMaps async {
    final maps = await _channel.invokeMethod('getInstalledMaps');
    return List<AvailableMap>.from(
      maps.map((map) => AvailableMap.fromJson(map)),
    );
  }

  static Future<dynamic> launchMap({
    @required MapType mapType,
    @required Coords coords,
    @required String title,
    @required String description,
    String address,
  }) async {
    final url = _getMapUrl(mapType, coords, title, description);

    final Map<String, String> args = {
      'mapType': _enumToString(mapType),
      'url': Uri.encodeFull(url),
      'title': title,
      'description': description,
      'address': address,
      'latitude': coords.latitude.toString(),
      'longitude': coords.longitude.toString(),
    };
    return _channel.invokeMethod('launchMap', args);
  }

  static Future<bool> isMapAvailable(MapType mapType) async {
    return _channel.invokeMethod(
      'isMapAvailable',
      {'mapType': _enumToString(mapType)},
    );
  }
}
