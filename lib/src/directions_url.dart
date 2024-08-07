import 'dart:io';

import 'package:map_launcher/src/models.dart';
import 'package:map_launcher/src/utils.dart';

/// Returns a url that is used by [showDirections]
String getMapDirectionsUrl({
  required MapType mapType,
  required Waypoint destination,
  Waypoint? origin,
  DirectionsMode? directionsMode,
  List<Waypoint>? waypoints,
  Map<String, String>? extraParams,
}) {
  switch (mapType) {
    case MapType.google:
      String addr(Waypoint p) => '${p.latitude},${p.longitude}';

      return Utils.buildUrl(
        url: 'https://www.google.com/maps/dir/',
        queryParams: {
          'api': '1',
          'destination': addr(destination),
          if (origin != null) 'origin': addr(origin),
          'waypoints': waypoints?.map(addr).join('|'),
          'travelmode': Utils.enumToString(directionsMode),
          ...(extraParams ?? {}),
        },
      );

    case MapType.googleGo:
      String addr(Waypoint p) => '${p.latitude},${p.longitude}';

      return Utils.buildUrl(
        url: 'https://www.google.com/maps/dir/',
        queryParams: {
          'api': '1',
          'destination': addr(destination),
          if (origin != null) 'origin': addr(origin),
          'waypoints': waypoints?.map(addr).join('|'),
          'travelmode': Utils.enumToString(directionsMode),
          ...(extraParams ?? {}),
        },
      );

    case MapType.apple:
      return Utils.buildUrl(
        url: 'https://maps.apple.com/maps',
        queryParams: {
          'daddr': '${destination.latitude},${destination.longitude}',
          ...(extraParams ?? {}),
        },
      );

    case MapType.amap:
      Map<String, String?> addr(Waypoint p, String prefix) {
        return {
          '${prefix}lat': '${p.latitude}',
          '${prefix}lon': '${p.longitude}',
          '${prefix}name': p.title,
        };
      }
      return Utils.buildUrl(
        url: Platform.isIOS ? 'iosamap://path' : 'amapuri://route/plan/',
        queryParams: {
          'sourceApplication': 'applicationName',
          ...addr(destination, 'd'),
          if (origin != null) ...addr(origin, 's'),
          't': Utils.getAmapDirectionsMode(directionsMode),
          'dev': '0',
          ...(extraParams ?? {}),
        },
      );

    case MapType.baidu:
      String addr(Waypoint p, String defaultTitle) {
        return 'name: ${p.title ?? defaultTitle}'
            '|latlng:${p.latitude},${p.longitude}';
      }

      return Utils.buildUrl(
        url: 'baidumap://map/direction',
        queryParams: {
          'destination': addr(destination, 'Destination'),
          if (origin != null) 'origin': addr(origin, 'Origin'),
          'coord_type': 'gcj02',
          'mode': Utils.getBaiduDirectionsMode(directionsMode),
          'src': 'com.map_launcher',
          ...(extraParams ?? {}),
        },
      );

    case MapType.waze:
      return Utils.buildUrl(
        url: 'waze://',
        queryParams: {
          'll': '${destination.latitude},${destination.longitude}',
          'z': '10',
          'navigate': 'yes',
          ...(extraParams ?? {}),
        },
      );

    case MapType.citymapper:
      Map<String, String?> addr(Waypoint p, String prefix) {
        return {
          '${prefix}coord': '${p.latitude},${p.longitude}',
          '${prefix}name': p.title,
        };
      }

      return Utils.buildUrl(url: 'citymapper://directions', queryParams: {
        ...addr(destination, 'end'),
        if (origin != null) ...addr(origin, 'start'),
        ...(extraParams ?? {}),
      });

    case MapType.osmand:
    case MapType.osmandplus:
      if (Platform.isIOS) {
        return Utils.buildUrl(
          url: 'osmandmaps://navigate',
          queryParams: {
            'lat': '${destination.latitude}',
            'lon': '${destination.longitude}',
            'title': destination.title,
            ...(extraParams ?? {}),
          },
        );
      }
      return 'osmand.navigation:q=${destination.latitude},${destination.longitude}';

    case MapType.mapswithme:
      // Couldn't get //route to work properly as of 2020/07
      // so just using the marker method for now
      // return Utils.buildUrl(
      //   url: 'mapsme://route',
      //   queryParams: {
      //     'dll': '${destination.latitude},${destination.longitude}',
      //     'daddr': destinationTitle,
      //     'sll': Utils.nullOrValue(
      //       origin,
      //       '${origin?.latitude},${origin?.longitude}',
      //     ),
      //     'saddr': originTitle,
      //     'type': Utils.getMapsMeDirectionsMode(directionsMode),
      //   },
      // );
      return Utils.buildUrl(
        url: 'mapsme://map',
        queryParams: {
          'v': '1',
          'll': '${destination.latitude},${destination.longitude}',
          'n': destination.title,
          ...(extraParams ?? {}),
        },
      );

    case MapType.yandexMaps:
      String addr(Waypoint p) => '${p.latitude},${p.longitude}';

      return Utils.buildUrl(
        url: 'yandexmaps://maps.yandex.com/',
        queryParams: {
          'rtext': [
            if (origin != null) addr(origin),
            addr(destination),
          ].join('~'),
          'rtt': Utils.getYandexMapsDirectionsMode(directionsMode),
          ...(extraParams ?? {}),
        },
      );

    case MapType.yandexNavi:
      Map<String, String?> addr(Waypoint p, String suffix) {
        return {
          'lat_$suffix': '${p.latitude}',
          'lon_$suffix': '${p.longitude}',
        };
      }

      return Utils.buildUrl(
        url: 'yandexnavi://build_route_on_map',
        queryParams: {
          ...addr(destination, 'to'),
          if (origin != null) ...addr(origin, 'from'),
        },
      );

    case MapType.doubleGis:
      String addr(Waypoint p, String prefix) =>
          '$prefix/${p.longitude},${p.latitude}';

      return Utils.buildUrl(
        url: [
          'dgis://2gis.ru/routeSearch/rsType',
          Utils.getDoubleGisDirectionsMode(directionsMode),
          if (origin != null) addr(origin, 'from'),
          addr(destination, 'to')
        ].join('/'),
        queryParams: {
          ...(extraParams ?? {}),
        },
      );

    case MapType.tencent:
      Map<String, String?> addr(Waypoint p, String prefix) {
        return {
          prefix: p.title,
          '${prefix}coord': '${p.latitude},${p.longitude}',
        };
      }

      return Utils.buildUrl(
        url: 'qqmap://map/routeplan',
        queryParams: {
          if (origin != null) ...addr(origin, 'from'),
          ...addr(destination, 'to'),
          'type': Utils.getTencentDirectionsMode(directionsMode),
          ...(extraParams ?? {}),
        },
      );

    case MapType.here:
      String addr(Waypoint p) {
        final title = p.title;
        return [
          p.latitude,
          p.longitude,
          if (title != null) title,
        ].join(',');
      }

      return Utils.buildUrl(
        url: [
          'here-route:/',
          if (origin != null) addr(origin) else 'mylocation',
          if (waypoints != null) ...waypoints.map(addr),
          addr(destination),
        ].join('/'),
        queryParams: {
          'm': Utils.getHereDirectionsMode(directionsMode),
          ...(extraParams ?? {}),
        },
      );

    case MapType.petal:
      String addr(Waypoint p, String defaultTitle) =>
          '${p.latitude},${p.longitude} (${p.title ?? defaultTitle})';

      return Utils.buildUrl(url: 'petalmaps://route', queryParams: {
        'daddr': addr(destination, 'Destination'),
        if (origin != null) 'saddr': addr(origin, 'Origin'),
        'type': Utils.getTencentDirectionsMode(directionsMode),
        ...(extraParams ?? {}),
      });

    case MapType.tomtomgo:
      if (Platform.isIOS) {
        return Utils.buildUrl(
          url: 'tomtomgo://x-callback-url/navigate',
          queryParams: {
            'destination': '${destination.latitude},${destination.longitude}',
            ...(extraParams ?? {}),
          },
        );
      }
      return Utils.buildUrl(
        url: 'google.navigation:',
        queryParams: {
          'q': '${destination.latitude},${destination.longitude}',
          ...(extraParams ?? {}),
        },
        // the TomTom Go app cannot handle the ? at the start of the query
      ).replaceFirst('?', '');

    case MapType.copilot:
      // Documentation:
      // https://developer.trimblemaps.com/copilot-navigation/v10-19/feature-guide/advanced-features/url-launch/
      return Utils.buildUrl(
        url: 'copilot://mydestination',
        queryParams: {
          'type': 'LOCATION',
          'action': 'GOTO',
          'name': destination.title ?? '',
          'lat': '${destination.latitude}',
          'long': '${destination.longitude}',
          ...(extraParams ?? {}),
        },
      );

    case MapType.tomtomgofleet:
      return Utils.buildUrl(
        url: 'google.navigation:',
        queryParams: {
          'q': '${destination.latitude},${destination.longitude}',
          ...(extraParams ?? {}),
        },
      );

    case MapType.sygicTruck:
      // Documentation:
      // https://www.sygic.com/developers/professional-navigation-sdk/introduction
      return Utils.buildUrl(
        url: 'com.sygic.aura://coordinate'
            '|${destination.longitude}|${destination.latitude}'
            '|drive',
        queryParams: {
          ...(extraParams ?? {}),
        },
      );

    case MapType.flitsmeister:
      if (Platform.isIOS) {
        return Utils.buildUrl(
          url: 'flitsmeister://',
          queryParams: {
            'geo': '${destination.latitude},${destination.longitude}',
            ...(extraParams ?? {}),
          },
        );
      }
      return Utils.buildUrl(
        url: 'geo:${destination.latitude},${destination.longitude}',
        queryParams: {},
      );

    case MapType.truckmeister:
      if (Platform.isIOS) {
        return Utils.buildUrl(
          url: 'truckmeister://',
          queryParams: {
            'geo': '${destination.latitude},${destination.longitude}',
            ...(extraParams ?? {}),
          },
        );
      }
      return Utils.buildUrl(
        url: 'geo:${destination.latitude},${destination.longitude}',
        queryParams: {
          'q': '${destination.latitude},${destination.longitude}',
          ...(extraParams ?? {}),
        },
      );

    case MapType.naver:
      Map<String, String?> addr(Waypoint p, String prefix) {
        return {
          '${prefix}lat': '${p.latitude}',
          '${prefix}lng': '${p.longitude}',
          '${prefix}name': p.title,
        };
      }

      return Utils.buildUrl(
        url: 'nmap://route/car',
        queryParams: {
          if (origin != null) ...addr(origin, 's'),
          ...addr(destination, 'd'),
          ...(extraParams ?? {}),
        },
      );

    case MapType.kakao:
      return Utils.buildUrl(
        url: 'kakaomap://route',
        queryParams: {
          'sp':
              origin == null ? null : '${origin.latitude},${origin.longitude}',
          'ep': '${destination.latitude},${destination.longitude}',
          ...(extraParams ?? {}),
        },
      );

    case MapType.tmap:
      Map<String, String?> addr(Waypoint p, String prefix) {
        return {
          '${prefix}name': p.title,
          '${prefix}x': '${p.longitude}',
          '${prefix}y': '${p.latitude}',
        };
      }

      return Utils.buildUrl(
        url: 'tmap://route',
        queryParams: {
          if (origin != null) ...addr(origin, 'start'),
          ...addr(destination, 'goal'),
          'carType': '1',
          ...(extraParams ?? {}),
        },
      );

    case MapType.mapyCz:
      return Utils.buildUrl(
        url: 'https://mapy.cz/zakladni',
        queryParams: {
          'id': '${destination.longitude},${destination.latitude}',
          'source': 'coor',
        },
      );
  }
}
