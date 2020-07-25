import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum MapType {
  apple,
  google,
  amap,
  baidu,
  waze,
  yandexNavi,
  yandexMaps,
  citymapper,
  mapswithme,
  osmand
}

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
  ImageProvider icon;

  AvailableMap({this.mapName, this.mapType, this.icon});

  static AvailableMap fromJson(json) {
    return AvailableMap(
      mapName: json['mapName'],
      mapType: _enumFromString(MapType.values, json['mapType']),
      icon: _SvgImage(
        'assets/icons/${json['mapType']}.svg',
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

  Future<void> showDirections({
    @required Coords destination,
    Coords origin,
  }) {
    return MapLauncher.launchDirections(
      mapType: mapType,
      destination: destination,
      origin: origin,
    );
  }

  @override
  String toString() {
    return 'AvailableMap { mapName: $mapName, mapType: ${_enumToString(mapType)} }';
  }
}

class _SvgImage extends AssetBundleImageProvider {
  const _SvgImage(
    this.assetName, {
    this.scale = 1.0,
    this.bundle,
    this.package,
  })  : assert(assetName != null),
        assert(scale != null);

  final String assetName;
  String get keyName =>
      package == null ? assetName : 'packages/$package/$assetName';
  final double scale;
  final AssetBundle bundle;
  final String package;

  @override
  Future<AssetBundleImageKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AssetBundleImageKey>(AssetBundleImageKey(
      bundle: bundle ?? configuration.bundle ?? rootBundle,
      name: keyName,
      scale: scale,
    ));
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is _SvgImage &&
        other.keyName == keyName &&
        other.scale == scale &&
        other.bundle == bundle;
  }

  @override
  int get hashCode => hashValues(keyName, scale, bundle);

  @override
  ImageStreamCompleter load(AssetBundleImageKey key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
    );
  }

  Future<Codec> _loadAsync(
      AssetBundleImageKey key, DecoderCallback decode) async {
    Size size = Size(256, 256);

    final Uint8List bytes = await key.bundle
        .loadString(key.name)
        .then((String rawSvg) => svg.fromSvgString(rawSvg, rawSvg))
        .then((DrawableRoot svg) {
          final ratio = svg.viewport.viewBox.aspectRatio;
          size = (ratio > 1)
              ? Size(size.width, size.width / ratio)
              : Size(size.height * ratio, size.height);
          return svg.toPicture(size: size, clipToViewBox: false);
        })
        .then((Picture picture) {
          return picture.toImage(size.width.toInt(), size.height.toInt());
        })
        .then((image) => image.toByteData(format: ImageByteFormat.png))
        .then((ByteData byteData) => byteData.buffer.asUint8List());

    return decode(
      bytes,
      cacheHeight: size.height.toInt(),
      cacheWidth: size.width.toInt(),
    );
  }
}

String _getMapMarkerUrl({
  @required MapType mapType,
  @required Coords coords,
  String title,
  String description,
}) {
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
    case MapType.mapswithme:
      return "mapsme://map?v=1&ll=${coords.latitude},${coords.longitude}&n=$title";
    case MapType.osmand:
      if (Platform.isIOS) {
        return 'osmandmaps://navigate?lat=${coords.latitude}&lon=${coords.longitude}&title=$title';
      }
      return 'osmand.navigation:q=${coords.latitude},${coords.longitude}';
    default:
      return null;
  }
}

String _getMapDirectionsUrl({
  @required MapType mapType,
  @required Coords destination,
  Coords origin,
  String title,
  String description,
}) {
  switch (mapType) {
    case MapType.google:
      if (Platform.isIOS) {
        final originParam = origin == null
            ? ''
            : 'saddr=${origin.latitude},${origin.longitude}';

        return 'comgooglemaps://?$originParam&daddr=${destination.latitude},${destination.longitude}&directionsmode=driving';
      }
      final originParam = origin == null
          ? ''
          : 'origin=${origin.latitude},${origin.longitude}&';

      return 'https://www.google.com/maps/dir/?api=1&$originParam&destination=${destination.latitude},${destination.longitude}&travelmode=driving';
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
  }) async {
    final url = _getMapMarkerUrl(
      mapType: mapType,
      coords: coords,
      title: title,
      description: description,
    );

    final Map<String, String> args = {
      'mapType': _enumToString(mapType),
      'url': Uri.encodeFull(url),
      'title': title,
      'description': description,
      'latitude': coords.latitude.toString(),
      'longitude': coords.longitude.toString(),
    };
    return _channel.invokeMethod('launchMap', args);
  }

  static Future<dynamic> launchDirections({
    @required MapType mapType,
    @required Coords destination,
    Coords origin,
  }) async {
    final url = _getMapDirectionsUrl(
      mapType: mapType,
      destination: destination,
      origin: origin,
    );

    final Map<String, String> args = {
      'mapType': _enumToString(mapType),
      'url': Uri.encodeFull(url),
      'title': 'title',
      'description': 'description',
      'latitude': 'coords.latitude.toString()',
      'longitude': 'coords.longitude.toString()',
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
