import 'dart:io';

import 'package:map_launcher/src/models.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Returns a url that is used by [showMarker]
String getMapMarkerUrl({
  required MapType mapType,
  required Coords coords,
  String? title,
  String? description,
  int zoom = 16,
  Map<String, String>? extraParams,
}) {
  switch (mapType) {
    case MapType.google:
      return buildUrl(
        url: Platform.isIOS ? 'comgooglemaps://' : 'geo:0,0',
        queryParams: {
          'q':
              '${coords.latitude},${coords.longitude}${title != null && title.isNotEmpty ? '($title)' : ''}',
          'zoom': zoom.toString(),
          ...?extraParams,
        },
      );

    case MapType.googleGo:
      return buildUrl(
        url: 'http://maps.google.com/maps',
        queryParams: {
          'q':
              '${coords.latitude},${coords.longitude}${title != null && title.isNotEmpty ? '($title)' : ''}',
          'zoom': zoom.toString(),
          ...?extraParams,
        },
      );

    case MapType.amap:
      return buildUrl(
        url: '${Platform.isIOS ? 'ios' : 'android'}amap://viewMap',
        queryParams: {
          'sourceApplication': 'map_launcher',
          'poiname': ?title,
          'lat': coords.latitude.toString(),
          'lon': coords.longitude.toString(),
          'zoom': zoom.toString(),
          'dev': '0',
          ...?extraParams,
        },
      );

    case MapType.baidu:
      return buildUrl(
        url: 'baidumap://map/marker',
        queryParams: {
          'location': '${coords.latitude},${coords.longitude}',
          'title': title != null && title.isNotEmpty ? title : 'Pin',
          'content':
              description ??
              'Description', // baidu fails if no description provided
          'traffic': 'on',
          'src': 'com.map_launcher',
          'coord_type': 'gcj02',
          'zoom': zoom.toString(),
          ...?extraParams,
        },
      );

    case MapType.apple:
      return buildUrl(
        url: 'http://maps.apple.com/maps',
        queryParams: {
          'saddr': '${coords.latitude},${coords.longitude}',
          ...?extraParams,
        },
      );

    case MapType.waze:
      return buildUrl(
        url: 'waze://',
        queryParams: {
          'll': '${coords.latitude},${coords.longitude}',
          'z': zoom.toString(),
          ...?extraParams,
        },
      );

    case MapType.yandexNavi:
      return buildUrl(
        url: 'yandexnavi://show_point_on_map',
        queryParams: {
          'lat': coords.latitude.toString(),
          'lon': coords.longitude.toString(),
          'zoom': zoom.toString(),
          'no-balloon': '0',
          'desc': ?title,
          ...?extraParams,
        },
      );

    case MapType.yandexMaps:
      return buildUrl(
        url: 'yandexmaps://maps.yandex.ru/',
        queryParams: {
          'pt': '${coords.longitude},${coords.latitude}',
          'z': zoom.toString(),
          'l': 'map',
          ...?extraParams,
        },
      );

    case MapType.citymapper:
      return buildUrl(
        url: 'citymapper://directions',
        queryParams: {
          'endcoord': '${coords.latitude},${coords.longitude}',
          'endname': ?title,
          ...?extraParams,
        },
      );

    case MapType.mapswithme:
      return buildUrl(
        url: 'mapsme://map',
        queryParams: {
          'v': '1',
          'll': '${coords.latitude},${coords.longitude}',
          'n': ?title,
          ...?extraParams,
        },
      );

    case MapType.osmand:
    case MapType.osmandplus:
      if (Platform.isIOS) {
        return buildUrl(
          url: 'osmandmaps://',
          queryParams: {
            'lat': coords.latitude.toString(),
            'lon': coords.longitude.toString(),
            'z': zoom.toString(),
            'title': ?title,
            ...?extraParams,
          },
        );
      }
      return buildUrl(
        url: 'http://osmand.net/go',
        queryParams: {
          'lat': coords.latitude.toString(),
          'lon': coords.longitude.toString(),
          'z': zoom.toString(),
          ...?extraParams,
        },
      );

    case MapType.doubleGis:
      if (Platform.isIOS) {
        return buildUrl(
          url: 'dgis://2gis.ru/geo/${coords.longitude},${coords.latitude}',
          queryParams: {...?extraParams},
        );
      }

      // android app does not seem to support marker by coordinates
      // so falling back to directions
      return buildUrl(
        url:
            'dgis://2gis.ru/routeSearch/rsType/car/to/${coords.longitude},${coords.latitude}',
        queryParams: {...?extraParams},
      );

    case MapType.tencent:
      return buildUrl(
        url: 'qqmap://map/marker',
        queryParams: {
          'marker':
              'coord:${coords.latitude},${coords.longitude}${title != null && title.isNotEmpty ? ';title:$title' : ''}',
          ...?extraParams,
        },
      );

    case MapType.here:
      final safeTitle = title == null ? '' : ',${Uri.encodeComponent(title)}';
      return buildUrl(
        url:
            'https://share.here.com/l/${coords.latitude},${coords.longitude}$safeTitle',
        queryParams: {'z': zoom.toString(), ...?extraParams},
      );

    case MapType.petal:
      return buildUrl(
        url: 'petalmaps://poidetail',
        queryParams: {
          'marker': '${coords.latitude},${coords.longitude}',
          'z': zoom.toString(),
          ...?extraParams,
        },
      );

    case MapType.tomtomgo:
      if (Platform.isIOS) {
        // currently uses the navigate endpoint on iOS, even when just showing a marker
        return buildUrl(
          url: 'tomtomgo://x-callback-url/navigate',
          queryParams: {
            'destination': '${coords.latitude},${coords.longitude}',
            ...?extraParams,
          },
        );
      }
      final safeTitle = title != null && title.isNotEmpty
          ? '(${Uri.encodeComponent(title)})'
          : '';
      return buildUrl(
        url: 'geo:${coords.latitude},${coords.longitude}',
        queryParams: {
          'q': '${coords.latitude},${coords.longitude}$safeTitle',
          ...?extraParams,
        },
      );

    case MapType.copilot:
      // Documentation:
      // https://developer.trimblemaps.com/copilot-navigation/v10-19/feature-guide/advanced-features/url-launch/
      return buildUrl(
        url: 'copilot://mydestination',
        queryParams: {
          'type': 'LOCATION',
          'action': 'VIEW',
          'marker': '${coords.latitude},${coords.longitude}',
          'name': ?title,
          ...?extraParams,
        },
      );

    case MapType.tomtomgofleet:
      return buildUrl(
        url: 'geo:${coords.latitude},${coords.longitude}',
        queryParams: {
          'q':
              '${coords.latitude},${coords.longitude}${title != null && title.isNotEmpty ? '($title)' : ''}',
          ...?extraParams,
        },
      );

    case MapType.sygicTruck:
      // Documentation:
      // https://www.sygic.com/developers/professional-navigation-sdk/introduction
      return buildUrl(
        url:
            'com.sygic.aura://coordinate|${coords.longitude}|${coords.latitude}|show',
        queryParams: {...?extraParams},
      );

    case MapType.flitsmeister:
      if (Platform.isIOS) {
        return buildUrl(
          url: 'flitsmeister://',
          queryParams: {
            'geo': '${coords.latitude},${coords.longitude}',
            ...?extraParams,
          },
        );
      }
      return buildUrl(
        url: 'geo:${coords.latitude},${coords.longitude}',
        queryParams: {
          'q': '${coords.latitude},${coords.longitude}',
          ...?extraParams,
        },
      );

    case MapType.truckmeister:
      if (Platform.isIOS) {
        return buildUrl(
          url: 'truckmeister://',
          queryParams: {
            'geo': '${coords.latitude},${coords.longitude}',
            ...?extraParams,
          },
        );
      }
      return buildUrl(
        url: 'geo:${coords.latitude},${coords.longitude}',
        queryParams: {
          'q': '${coords.latitude},${coords.longitude}',
          ...?extraParams,
        },
      );

    case MapType.naver:
      return buildUrl(
        url: 'nmap://place',
        queryParams: {
          'lat': coords.latitude.toString(),
          'lng': coords.longitude.toString(),
          'zoom': zoom.toString(),
          'name': ?title,
          ...?extraParams,
        },
      );

    case MapType.kakao:
      return buildUrl(
        url: 'kakaomap://look',
        queryParams: {
          'p': '${coords.latitude},${coords.longitude}',
          ...?extraParams,
        },
      );

    case MapType.tmap:
      return buildUrl(
        url: 'tmap://viewmap',
        queryParams: {
          'name': ?title,
          'x': coords.longitude.toString(),
          'y': coords.latitude.toString(),
          ...?extraParams,
        },
      );

    case MapType.mapyCz:
      return buildUrl(
        url: 'https://mapy.cz/zakladni',
        queryParams: {
          'id': '${coords.longitude},${coords.latitude}',
          'z': zoom.toString(),
          'source': 'coor',
          ...?extraParams,
        },
      );

    case MapType.mappls:
      return buildUrl(
        url:
            'https://www.mappls.com/location/${coords.latitude},${coords.longitude}',
        queryParams: {...?extraParams},
      );
  }
}
