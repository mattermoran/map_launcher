import 'dart:io';

import 'package:map_launcher/src/models.dart';
import 'package:map_launcher/src/utils.dart';

/// Returns a url that is used by [showMarker]
String getMapMarkerUrl({
  required MapType mapType,
  required Coords coords,
  String? title,
  String? description,
  int? zoom,
  Map<String, String>? extraParams,
}) {
  final zoomLevel = zoom ?? 16;
  switch (mapType) {
    case MapType.google:
      return Utils.buildUrl(
        url: Platform.isIOS ? 'comgooglemaps://' : 'geo:0,0',
        queryParams: {
          'q':
              '${coords.latitude},${coords.longitude}${title != null && title.isNotEmpty ? '($title)' : ''}',
          'zoom': '$zoomLevel',
          ...(extraParams ?? {}),
        },
      );

    case MapType.googleGo:
      return Utils.buildUrl(
        url: 'http://maps.google.com/maps',
        queryParams: {
          'q':
              '${coords.latitude},${coords.longitude}${title != null && title.isNotEmpty ? '($title)' : ''}',
          'zoom': '$zoomLevel',
          ...(extraParams ?? {}),
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
          'zoom': '$zoomLevel',
          'dev': '0',
          ...(extraParams ?? {}),
        },
      );

    case MapType.baidu:
      return Utils.buildUrl(
        url: 'baidumap://map/marker',
        queryParams: {
          'location': '${coords.latitude},${coords.longitude}',
          'title': title ?? 'Title',
          'content': description ??
              'Description', // baidu fails if no description provided
          'traffic': 'on',
          'src': 'com.map_launcher',
          'coord_type': 'gcj02',
          'zoom': '$zoomLevel',
          ...(extraParams ?? {}),
        },
      );

    case MapType.apple:
      return Utils.buildUrl(
        url: 'http://maps.apple.com/maps',
        queryParams: {
          'saddr': '${coords.latitude},${coords.longitude}',
          ...(extraParams ?? {}),
        },
      );

    case MapType.waze:
      return Utils.buildUrl(
        url: 'waze://',
        queryParams: {
          'll': '${coords.latitude},${coords.longitude}',
          'z': '$zoomLevel',
          ...(extraParams ?? {}),
        },
      );

    case MapType.yandexNavi:
      return Utils.buildUrl(
        url: 'yandexnavi://show_point_on_map',
        queryParams: {
          'lat': '${coords.latitude}',
          'lon': '${coords.longitude}',
          'zoom': '$zoomLevel',
          'no-balloon': '0',
          'desc': '$title',
          ...(extraParams ?? {}),
        },
      );

    case MapType.yandexMaps:
      return Utils.buildUrl(
        url: 'yandexmaps://maps.yandex.ru/',
        queryParams: {
          'pt': '${coords.longitude},${coords.latitude}',
          'z': '$zoomLevel',
          'l': 'map',
          ...(extraParams ?? {}),
        },
      );

    case MapType.citymapper:
      return Utils.buildUrl(
        url: 'citymapper://directions',
        queryParams: {
          'endcoord': '${coords.latitude},${coords.longitude}',
          'endname': '$title',
          ...(extraParams ?? {}),
        },
      );

    case MapType.mapswithme:
      return Utils.buildUrl(
        url: 'mapsme://map',
        queryParams: {
          'v': '1',
          'll': '${coords.latitude},${coords.longitude}',
          'n': title,
          ...(extraParams ?? {}),
        },
      );

    case MapType.osmand:
    case MapType.osmandplus:
      if (Platform.isIOS) {
        return Utils.buildUrl(
          url: 'osmandmaps://',
          queryParams: {
            'lat': '${coords.latitude}',
            'lon': '${coords.longitude}',
            'z': '$zoomLevel',
            'title': title,
            ...(extraParams ?? {}),
          },
        );
      }
      return Utils.buildUrl(
        url: 'http://osmand.net/go',
        queryParams: {
          'lat': '${coords.latitude}',
          'lon': '${coords.longitude}',
          'z': '$zoomLevel',
          ...(extraParams ?? {}),
        },
      );

    case MapType.doubleGis:
      if (Platform.isIOS) {
        return Utils.buildUrl(
          url: 'dgis://2gis.ru/geo/${coords.longitude},${coords.latitude}',
          queryParams: {
            ...(extraParams ?? {}),
          },
        );
      }

      // android app does not seem to support marker by coordinates
      // so falling back to directions
      return Utils.buildUrl(
        url:
            'dgis://2gis.ru/routeSearch/rsType/car/to/${coords.longitude},${coords.latitude}',
        queryParams: {
          ...(extraParams ?? {}),
        },
      );

    case MapType.tencent:
      return Utils.buildUrl(
        url: 'qqmap://map/marker',
        queryParams: {
          'marker':
              'coord:${coords.latitude},${coords.longitude}${title != null ? ';title:$title' : ''}',
          ...(extraParams ?? {}),
        },
      );

    case MapType.here:
      return Utils.buildUrl(
        url:
            'https://share.here.com/l/${coords.latitude},${coords.longitude},$title',
        queryParams: {
          'z': '$zoomLevel',
          ...(extraParams ?? {}),
        },
      );

    case MapType.petal:
      return Utils.buildUrl(
        url: 'petalmaps://poidetail',
        queryParams: {
          'marker': '${coords.latitude},${coords.longitude}',
          'z': '$zoomLevel',
          ...(extraParams ?? {}),
        },
      );

    case MapType.tomtomgo:
      if (Platform.isIOS) {
        // currently uses the navigate endpoint on iOS, even when just showing a marker
        return Utils.buildUrl(
          url: 'tomtomgo://x-callback-url/navigate',
          queryParams: {
            'destination': '${coords.latitude},${coords.longitude}',
            ...(extraParams ?? {}),
          },
        );
      }
      return Utils.buildUrl(
        url: 'geo:${coords.latitude},${coords.longitude}',
        queryParams: {
          'q':
              '${coords.latitude},${coords.longitude}${title != null && title.isNotEmpty ? '($title)' : ''}',
          ...(extraParams ?? {}),
        },
      );

    case MapType.copilot:
      // Documentation:
      // https://developer.trimblemaps.com/copilot-navigation/v10-19/feature-guide/advanced-features/url-launch/
      return Utils.buildUrl(
        url: 'copilot://mydestination',
        queryParams: {
          'type': 'LOCATION',
          'action': 'VIEW',
          'marker': '${coords.latitude},${coords.longitude}',
          'name': title ?? '',
          ...(extraParams ?? {}),
        },
      );

    case MapType.tomtomgofleet:
      return Utils.buildUrl(
        url: 'geo:${coords.latitude},${coords.longitude}',
        queryParams: {
          'q':
              '${coords.latitude},${coords.longitude}${title != null && title.isNotEmpty ? '($title)' : ''}',
          ...(extraParams ?? {}),
        },
      );

    case MapType.sygicTruck:
      // Documentation:
      // https://www.sygic.com/developers/professional-navigation-sdk/introduction
      return Utils.buildUrl(
        url:
            'com.sygic.aura://coordinate|${coords.longitude}|${coords.latitude}|show',
        queryParams: {
          ...(extraParams ?? {}),
        },
      );

    case MapType.flitsmeister:
      if (Platform.isIOS) {
        return Utils.buildUrl(
          url: 'flitsmeister://',
          queryParams: {
            'geo': '${coords.latitude},${coords.longitude}',
            ...(extraParams ?? {}),
          },
        );
      }
      return Utils.buildUrl(
        url: 'geo:${coords.latitude},${coords.longitude}',
        queryParams: {
          'q': '${coords.latitude},${coords.longitude}',
          ...(extraParams ?? {}),
        },
      );

    case MapType.truckmeister:
      if (Platform.isIOS) {
        return Utils.buildUrl(
          url: 'truckmeister://',
          queryParams: {
            'geo': '${coords.latitude},${coords.longitude}',
            ...(extraParams ?? {}),
          },
        );
      }
      return Utils.buildUrl(
        url: 'geo:${coords.latitude},${coords.longitude}',
        queryParams: {
          'q': '${coords.latitude},${coords.longitude}',
          ...(extraParams ?? {}),
        },
      );

    case MapType.naver:
      return Utils.buildUrl(
        url: 'nmap://place',
        queryParams: {
          'lat': '${coords.latitude}',
          'lng': '${coords.longitude}',
          'zoom': '$zoomLevel',
          'name': title,
          ...(extraParams ?? {}),
        },
      );

    case MapType.kakao:
      return Utils.buildUrl(
        url: 'kakaomap://look',
        queryParams: {
          'p': '${coords.latitude},${coords.longitude}',
          ...(extraParams ?? {}),
        },
      );

    case MapType.tmap:
      return Utils.buildUrl(
        url: 'tmap://viewmap',
        queryParams: {
          'name': '$title',
          'x': '${coords.longitude}',
          'y': '${coords.latitude}',
          ...(extraParams ?? {}),
        },
      );

    case MapType.mapyCz:
      return Utils.buildUrl(
        url: 'https://mapy.cz/zakladni',
        queryParams: {
          'id': '${coords.longitude},${coords.latitude}',
          'z': '$zoomLevel',
          'source': 'coor',
        },
      );

    case MapType.mappls:
      return Utils.buildUrl(
        url:
            'https://www.mappls.com/location/${coords.latitude},${coords.longitude}',
        queryParams: {},
      );
  }
}
