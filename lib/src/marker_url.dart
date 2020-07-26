import 'dart:io';
import 'package:flutter/material.dart';
import 'package:map_launcher/src/models.dart';
import 'package:map_launcher/src/utils.dart';

String getMapMarkerUrl({
  @required MapType mapType,
  @required Coords coords,
  String title,
  String description,
}) {
  switch (mapType) {
    case MapType.google:
      return Utils.buildUrl(
        url: Platform.isIOS ? 'comgooglemaps://' : 'geo:0,0',
        queryParams: {
          'q': '${coords.latitude},${coords.longitude}($title)',
        },
      );

    case MapType.amap:
      return Utils.buildUrl(
        url: '${Platform.isIOS ? 'ios' : 'android'}amap://viewMap',
        queryParams: {
          'sourceApplication': 'map_launcher',
          'poiname': '$title',
          'lat': '${coords.latitude}',
          'lon': '${coords.longitude}',
          'zoom': '18',
          'dev': '0',
        },
      );

    case MapType.baidu:
      return Utils.buildUrl(
        url: 'baidumap://map/marker',
        queryParams: {
          'location': '${coords.latitude},${coords.longitude}',
          'title': title,
          'content': description,
          'traffic': 'on',
          'src': 'com.map_launcher',
          'coord_type': 'gcj02',
          'zoom': '18',
        },
      );

    case MapType.apple:
      return Utils.buildUrl(
        url: 'http://maps.apple.com/maps',
        queryParams: {
          'saddr': '${coords.latitude},${coords.longitude}',
        },
      );

    case MapType.waze:
      return Utils.buildUrl(
        url: 'waze://',
        queryParams: {
          'll': '${coords.latitude},${coords.longitude}',
          'z': '10',
        },
      );

    case MapType.yandexNavi:
      return Utils.buildUrl(
        url: 'yandexnavi://show_point_on_map',
        queryParams: {
          'lat': '${coords.latitude}',
          'lon': '${coords.longitude}',
          'zoom': '16',
          'no-balloon': '0',
          'desc': '$title',
        },
      );

    case MapType.yandexMaps:
      return Utils.buildUrl(
        url: 'yandexmaps://maps.yandex.ru/',
        queryParams: {
          'pt': '${coords.longitude},${coords.latitude}',
          'z': '16',
          'l': 'map',
        },
      );

    case MapType.citymapper:
      return Utils.buildUrl(
        url: 'citymapper://directions',
        queryParams: {
          'endcoord': '${coords.latitude},${coords.longitude}',
          'endname': '$title',
        },
      );

    case MapType.mapswithme:
      return Utils.buildUrl(
        url: 'mapsme://map',
        queryParams: {
          'v': '1',
          'll': '${coords.latitude},${coords.longitude}',
          'n': title
        },
      );

    case MapType.osmand:
      if (Platform.isIOS) {
        return Utils.buildUrl(
          url: 'osmandmaps://',
          queryParams: {
            'lat': '${coords.latitude}',
            'lon': '${coords.longitude}',
            'title': title,
          },
        );
      }
      return Utils.buildUrl(
        url: 'http://osmand.net/go',
        queryParams: {
          'lat': '${coords.latitude}',
          'lon': '${coords.longitude}',
          'z': '16',
        },
      );

    default:
      return null;
  }
}
