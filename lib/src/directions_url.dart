import 'dart:io';

import 'package:map_launcher/src/models.dart';
import 'package:map_launcher/src/utils.dart';

/// Returns a url that is used by [showDirections]
String getMapDirectionsUrl({
  required MapType mapType,
  required Coords destination,
  String? destinationTitle,
  Coords? origin,
  String? originTitle,
  DirectionsMode? directionsMode,
  List<Waypoint>? waypoints,
  Map<String, String>? extraParams,
}) {
  switch (mapType) {
    case MapType.google:
      return Utils.buildUrl(
        url: 'https://www.google.com/maps/dir/',
        queryParams: {
          'api': '1',
          'destination': '${destination.latitude},${destination.longitude}',
          'origin': Utils.nullOrValue(
            origin,
            '${origin?.latitude},${origin?.longitude}',
          ),
          'waypoints': waypoints
              ?.map((waypoint) => '${waypoint.latitude},${waypoint.longitude}')
              .join('|'),
          'travelmode': Utils.enumToString(directionsMode),
          ...(extraParams ?? {}),
        },
      );

    case MapType.googleGo:
      return Utils.buildUrl(
        url: 'https://www.google.com/maps/dir/',
        queryParams: {
          'api': '1',
          'destination': '${destination.latitude},${destination.longitude}',
          'origin': Utils.nullOrValue(
            origin,
            '${origin?.latitude},${origin?.longitude}',
          ),
          'waypoints': waypoints
              ?.map((waypoint) => '${waypoint.latitude},${waypoint.longitude}')
              .join('|'),
          'travelmode': Utils.enumToString(directionsMode),
          ...(extraParams ?? {}),
        },
      );

    case MapType.apple:
      return Utils.buildUrl(
        url: 'http://maps.apple.com/maps',
        queryParams: {
          'daddr': '${destination.latitude},${destination.longitude}',
          ...(extraParams ?? {}),
        },
      );

    case MapType.amap:
      return Utils.buildUrl(
        url: Platform.isIOS ? 'iosamap://path' : 'amapuri://route/plan/',
        queryParams: {
          'sourceApplication': 'applicationName',
          'dlat': '${destination.latitude}',
          'dlon': '${destination.longitude}',
          'dname': destinationTitle,
          'slat': Utils.nullOrValue(origin, '${origin?.latitude}'),
          'slon': Utils.nullOrValue(origin, '${origin?.longitude}'),
          'sname': originTitle,
          't': Utils.getAmapDirectionsMode(directionsMode),
          'dev': '0',
          ...(extraParams ?? {}),
        },
      );

    case MapType.baidu:
      return Utils.buildUrl(
        url: 'baidumap://map/direction',
        queryParams: {
          'destination':
              'name: ${destinationTitle ?? 'Destination'}|latlng:${destination.latitude},${destination.longitude}',
          'origin': Utils.nullOrValue(
            origin,
            'name: ${originTitle ?? 'Origin'}|latlng:${origin?.latitude},${origin?.longitude}',
          ),
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
      return Utils.buildUrl(url: 'citymapper://directions', queryParams: {
        'endcoord': '${destination.latitude},${destination.longitude}',
        'endname': destinationTitle,
        'startcoord': Utils.nullOrValue(
          origin,
          '${origin?.latitude},${origin?.longitude}',
        ),
        'startname': originTitle,
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
            'title': destinationTitle,
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
          'n': destinationTitle,
          ...(extraParams ?? {}),
        },
      );

    case MapType.yandexMaps:
      return Utils.buildUrl(
        url: 'yandexmaps://maps.yandex.com/',
        queryParams: {
          'rtext':
              '${origin?.latitude},${origin?.longitude}~${destination.latitude},${destination.longitude}',
          'rtt': Utils.getYandexMapsDirectionsMode(directionsMode),
          ...(extraParams ?? {}),
        },
      );

    case MapType.yandexNavi:
      return Utils.buildUrl(
        url: 'yandexnavi://build_route_on_map',
        queryParams: {
          'lat_to': '${destination.latitude}',
          'lon_to': '${destination.longitude}',
          'lat_from': Utils.nullOrValue(origin, '${origin?.latitude}'),
          'lon_from': Utils.nullOrValue(origin, '${origin?.longitude}'),
        },
      );

    case MapType.doubleGis:
      return Utils.buildUrl(
        url:
            'dgis://2gis.ru/routeSearch/rsType/${Utils.getDoubleGisDirectionsMode(directionsMode)}/${origin == null ? '' : 'from/${origin.longitude},${origin.latitude}/'}to/${destination.longitude},${destination.latitude}',
        queryParams: {
          ...(extraParams ?? {}),
        },
      );

    case MapType.tencent:
      return Utils.buildUrl(
        url: 'qqmap://map/routeplan',
        queryParams: {
          'from': originTitle,
          'fromcoord': '${origin?.latitude},${origin?.longitude}',
          'to': destinationTitle,
          'tocoord': '${destination.latitude},${destination.longitude}',
          'type': Utils.getTencentDirectionsMode(directionsMode),
          ...(extraParams ?? {}),
        },
      );

    case MapType.here:
      return Utils.buildUrl(
        url:
            'https://share.here.com/r/${origin?.latitude},${origin?.longitude},$originTitle/${destination.latitude},${destination.longitude}',
        queryParams: {
          'm': Utils.getHereDirectionsMode(directionsMode),
          ...(extraParams ?? {}),
        },
      );

    case MapType.petal:
      return Utils.buildUrl(url: 'petalmaps://route', queryParams: {
        'daddr':
            '${destination.latitude},${destination.longitude} (${destinationTitle ?? 'Destination'})',
        'saddr': Utils.nullOrValue(
          origin,
          '${origin?.latitude},${origin?.longitude} (${originTitle ?? 'Origin'})',
        ),
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
          'name': destinationTitle ?? '',
          'lat': "${destination.latitude}",
          'long': "${destination.longitude}",
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
        url:
            'com.sygic.aura://coordinate|${destination.longitude}|${destination.latitude}|drive',
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
      return Utils.buildUrl(
        url: 'nmap://route/car',
        queryParams: {
          'slat': origin?.latitude.toString(),
          'slng': origin?.longitude.toString(),
          'sname': originTitle,
          'dlat': '${destination.latitude}',
          'dlng': '${destination.longitude}',
          'dname': destinationTitle,
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
      return Utils.buildUrl(
        url: 'tmap://route',
        queryParams: {
          'startname': originTitle,
          'startx': origin?.longitude.toString(),
          'starty': origin?.latitude.toString(),
          'goalname': destinationTitle,
          'goaly': '${destination.latitude}',
          'goalx': '${destination.longitude}',
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

    case MapType.mappls:
      var query = '';
      if (origin != null) {
        query =
            '$query${origin.latitude},${origin.longitude}${originTitle != null ? ',$originTitle' : ''}';
      }
      var viaPoints = "";

      if (waypoints != null) {
        for (Waypoint element in waypoints) {
          if (viaPoints.isNotEmpty) {
            viaPoints = '$viaPoints;';
          }
          viaPoints =
              '$viaPoints${element.latitude},${element.longitude}${element.title ?? ''}';
        }
      }

      if (query.isNotEmpty) {
        query = '$query;';
      }
      query =
          '$query${destination.latitude},${destination.longitude}${destinationTitle != null ? ',$destinationTitle' : ''}';

      var mode = 'driving';
      if (directionsMode != null) {
        switch (directionsMode) {
          case DirectionsMode.driving:
            mode = 'driving';
            break;

          case DirectionsMode.walking:
            mode = 'walking';
            break;

          case DirectionsMode.bicycling:
            mode = 'biking';
            break;

          case DirectionsMode.transit:
            mode = 'trucking';
            break;
        }
      }

      return Utils.buildUrl(
        url: "https://mappls.com/navigation",
        queryParams: {
          'places': query,
          'viaPoints': viaPoints,
          'mode': mode,
        },
      );
  }
}
