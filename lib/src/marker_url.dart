import 'dart:io';
import 'package:flutter/material.dart';
import 'package:map_launcher/src/models.dart';

String getMapMarkerUrl({
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
