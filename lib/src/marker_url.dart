import 'dart:io';
import 'package:map_launcher/src/models.dart';
import 'package:map_launcher/src/utils.dart';

/// Returns a url that is used by [showMarker]
String getMapMarkerUrl(MapMarkerParams params) {
  switch (params.mapType) {
    case MapType.google:
      return Utils.buildUrl(
        url: Platform.isIOS ? 'comgooglemaps://' : 'geo:0,0',
        queryParams: {
          'q':
              '${params.coords.latitude},${params.coords.longitude}${params.title.isNotEmpty ? '(${params.title})' : ''}',
          'zoom': '${params.zoom}',
          ...params.extraParams,
        },
      );

    case MapType.googleGo:
      return Utils.buildUrl(
        url: 'http://maps.google.com/maps',
        queryParams: {
          'q':
              '${params.coords.latitude},${params.coords.longitude}${params.title.isNotEmpty ? '(${params.title})' : ''}',
          'zoom': '${params.zoom}',
          ...params.extraParams,
        },
      );

    case MapType.amap:
      return Utils.buildUrl(
        url: '${Platform.isIOS ? 'ios' : 'android'}amap://viewMap',
        queryParams: {
          'sourceApplication': 'map_launcher',
          'poiname': params.title,
          'lat': '${params.coords.latitude}',
          'lon': '${params.coords.longitude}',
          'zoom': '${params.zoom}',
          'dev': '0',
          ...params.extraParams,
        },
      );

    case MapType.baidu:
      return Utils.buildUrl(
        url: 'baidumap://map/marker',
        queryParams: {
          'location': '${params.coords.latitude},${params.coords.longitude}',
          'title': params.title,
          'content': params.description ??
              'Description', // baidu fails if no description provided
          'traffic': 'on',
          'src': 'com.map_launcher',
          'coord_type': 'gcj02',
          'zoom': '${params.zoom}',
          ...params.extraParams,
        },
      );

    case MapType.apple:
      return Utils.buildUrl(
        url: 'http://maps.apple.com/maps',
        queryParams: {
          'saddr': '${params.coords.latitude},${params.coords.longitude}',
          ...params.extraParams,
        },
      );

    case MapType.waze:
      return Utils.buildUrl(
        url: 'waze://',
        queryParams: {
          'll': '${params.coords.latitude},${params.coords.longitude}',
          'z': '${params.zoom}',
          ...params.extraParams,
        },
      );

    case MapType.yandexNavi:
      return Utils.buildUrl(
        url: 'yandexnavi://show_point_on_map',
        queryParams: {
          'lat': '${params.coords.latitude}',
          'lon': '${params.coords.longitude}',
          'zoom': '${params.zoom}',
          'no-balloon': '0',
          'desc': params.title,
          ...params.extraParams,
        },
      );

    case MapType.yandexMaps:
      return Utils.buildUrl(
        url: 'yandexmaps://maps.yandex.ru/',
        queryParams: {
          'pt': '${params.coords.longitude},${params.coords.latitude}',
          'z': '${params.zoom}',
          'l': 'map',
          ...params.extraParams,
        },
      );

    case MapType.citymapper:
      return Utils.buildUrl(
        url: 'citymapper://directions',
        queryParams: {
          'endcoord': '${params.coords.latitude},${params.coords.longitude}',
          'endname': params.title,
          ...params.extraParams,
        },
      );

    case MapType.mapswithme:
      return Utils.buildUrl(
        url: 'mapsme://map',
        queryParams: {
          'v': '1',
          'll': '${params.coords.latitude},${params.coords.longitude}',
          'n': params.title,
          ...params.extraParams,
        },
      );

    case MapType.osmand:
    case MapType.osmandplus:
      if (Platform.isIOS) {
        return Utils.buildUrl(
          url: 'osmandmaps://',
          queryParams: {
            'lat': '${params.coords.latitude}',
            'lon': '${params.coords.longitude}',
            'z': '${params.zoom}',
            'title': params.title,
            ...params.extraParams,
          },
        );
      }
      return Utils.buildUrl(
        url: 'http://osmand.net/go',
        queryParams: {
          'lat': '${params.coords.latitude}',
          'lon': '${params.coords.longitude}',
          'z': '${params.zoom}',
          ...params.extraParams,
        },
      );

    case MapType.doubleGis:
      if (Platform.isIOS) {
        return Utils.buildUrl(
          url:
              'dgis://2gis.ru/geo/${params.coords.longitude},${params.coords.latitude}',
          queryParams: {
            ...params.extraParams,
          },
        );
      }

      // android app does not seem to support marker by coordinates
      // so falling back to directions
      return Utils.buildUrl(
        url:
            'dgis://2gis.ru/routeSearch/rsType/car/to/${params.coords.longitude},${params.coords.latitude}',
        queryParams: {
          ...params.extraParams,
        },
      );

    case MapType.tencent:
      return Utils.buildUrl(
        url: 'qqmap://map/marker',
        queryParams: {
          'marker':
              'coord:${params.coords.latitude},${params.coords.longitude}${params.title.isNotEmpty ? ';title:${params.title}' : ''}',
          ...params.extraParams,
        },
      );

    case MapType.here:
      return Utils.buildUrl(
        url:
            'https://share.here.com/l/${params.coords.latitude},${params.coords.longitude},${params.title}',
        queryParams: {
          'z': '${params.zoom}',
          ...params.extraParams,
        },
      );

    case MapType.petal:
      return Utils.buildUrl(
        url: 'petalmaps://poidetail',
        queryParams: {
          'marker': '${params.coords.latitude},${params.coords.longitude}',
          'z': '${params.zoom}',
          ...params.extraParams,
        },
      );

    case MapType.tomtomgo:
      if (Platform.isIOS) {
        // currently uses the navigate endpoint on iOS, even when just showing a marker
        return Utils.buildUrl(
          url: 'tomtomgo://x-callback-url/navigate',
          queryParams: {
            'destination':
                '${params.coords.latitude},${params.coords.longitude}',
            ...params.extraParams,
          },
        );
      }
      return Utils.buildUrl(
        url: 'geo:${params.coords.latitude},${params.coords.longitude}',
        queryParams: {
          'q':
              '${params.coords.latitude},${params.coords.longitude}${params.title.isNotEmpty ? '(${params.title})' : ''}',
          ...params.extraParams,
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
          'marker': '${params.coords.latitude},${params.coords.longitude}',
          'name': params.title,
          ...params.extraParams,
        },
      );
  }
}
