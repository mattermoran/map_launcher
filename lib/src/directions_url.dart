import 'dart:io';

import 'package:map_launcher/src/models.dart';
import 'package:map_launcher/src/utils/direction_modes.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

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
      return buildUrl(
        url: 'https://www.google.com/maps/dir/',
        queryParams: {
          'api': '1',
          'destination': '${destination.latitude},${destination.longitude}',
          if (origin != null)
            'origin': '${origin.latitude},${origin.longitude}',
          if (waypoints != null)
            'waypoints': waypoints
                .map((waypoint) => '${waypoint.latitude},${waypoint.longitude}')
                .join('|'),
          'travelmode': ?directionsMode?.name,
          ...?extraParams,
        },
      );

    case MapType.googleGo:
      return buildUrl(
        url: 'https://www.google.com/maps/dir/',
        queryParams: {
          'api': '1',
          'destination': '${destination.latitude},${destination.longitude}',
          if (origin != null)
            'origin': '${origin.latitude},${origin.longitude}',
          if (waypoints != null)
            'waypoints': waypoints
                .map((waypoint) => '${waypoint.latitude},${waypoint.longitude}')
                .join('|'),
          'travelmode': ?directionsMode?.name,
          ...?extraParams,
        },
      );

    case MapType.apple:
      return buildUrl(
        url: 'http://maps.apple.com/maps',
        queryParams: {
          'daddr': '${destination.latitude},${destination.longitude}',
          ...?extraParams,
        },
      );

    case MapType.amap:
      return buildUrl(
        url: Platform.isIOS ? 'iosamap://path' : 'amapuri://route/plan/',
        queryParams: {
          'sourceApplication': 'applicationName',
          'dlat': destination.latitude.toString(),
          'dlon': destination.longitude.toString(),
          'dname': ?destinationTitle,
          if (origin != null) ...{
            'slat': origin.latitude.toString(),
            'slon': origin.longitude.toString(),
          },
          'sname': ?originTitle,
          't': getAmapDirectionsMode(directionsMode),
          'dev': '0',
          ...?extraParams,
        },
      );

    case MapType.baidu:
      return buildUrl(
        url: 'baidumap://map/direction',
        queryParams: {
          'destination':
              'name: ${destinationTitle ?? 'Destination'}|latlng:${destination.latitude},${destination.longitude}',
          if (origin != null)
            'origin':
                'name: ${originTitle ?? 'Origin'}|latlng:${origin.latitude},${origin.longitude}',
          'coord_type': 'gcj02',
          'mode': getBaiduDirectionsMode(directionsMode),
          'src': 'dev.fluttered.map_launcher',
          ...?extraParams,
        },
      );

    case MapType.waze:
      return buildUrl(
        url: 'waze://',
        queryParams: {
          'll': '${destination.latitude},${destination.longitude}',
          'z': '10',
          'navigate': 'yes',
          ...?extraParams,
        },
      );

    case MapType.citymapper:
      return buildUrl(
        url: 'citymapper://directions',
        queryParams: {
          'endcoord': '${destination.latitude},${destination.longitude}',
          'endname': ?destinationTitle,
          if (origin != null)
            'startcoord': '${origin.latitude},${origin.longitude}',
          'startname': ?originTitle,
          ...?extraParams,
        },
      );

    case MapType.osmand:
    case MapType.osmandplus:
      if (Platform.isIOS) {
        return buildUrl(
          url: 'osmandmaps://navigate',
          queryParams: {
            'lat': destination.latitude.toString(),
            'lon': destination.longitude.toString(),
            'title': ?destinationTitle,
            ...?extraParams,
          },
        );
      }
      return 'osmand.navigation:q=${destination.latitude},${destination.longitude}';

    case MapType.mapswithme:
      return buildUrl(
        url: 'mapsme://map',
        queryParams: {
          'v': '1',
          'll': '${destination.latitude},${destination.longitude}',
          'n': ?destinationTitle,
          ...?extraParams,
        },
      );

    case MapType.yandexMaps:
      return buildUrl(
        url: 'yandexmaps://maps.yandex.com/',
        queryParams: {
          'rtext':
              '${origin?.latitude},${origin?.longitude}~${destination.latitude},${destination.longitude}',
          'rtt': getYandexMapsDirectionsMode(directionsMode),
          ...?extraParams,
        },
      );

    case MapType.yandexNavi:
      return buildUrl(
        url: 'yandexnavi://build_route_on_map',
        queryParams: {
          'lat_to': destination.latitude.toString(),
          'lon_to': destination.longitude.toString(),
          if (origin != null) ...{
            'lat_from': origin.latitude.toString(),
            'lon_from': origin.longitude.toString(),
          },
          ...?extraParams,
        },
      );

    case MapType.doubleGis:
      return buildUrl(
        url:
            'dgis://2gis.ru/routeSearch/rsType/${getDoubleGisDirectionsMode(directionsMode)}/${origin == null ? '' : 'from/${origin.longitude},${origin.latitude}/'}to/${destination.longitude},${destination.latitude}',
        queryParams: {...?extraParams},
      );

    case MapType.tencent:
      return buildUrl(
        url: 'qqmap://map/routeplan',
        queryParams: {
          'from': ?originTitle,
          if (origin != null)
            'fromcoord': '${origin.latitude},${origin.longitude}',
          'to': ?destinationTitle,
          'tocoord': '${destination.latitude},${destination.longitude}',
          'type': getTencentDirectionsMode(directionsMode),
          ...?extraParams,
        },
      );

    case MapType.here:
      return buildUrl(
        url:
            'https://share.here.com/r/${origin?.latitude},${origin?.longitude},$originTitle/${destination.latitude},${destination.longitude}',
        queryParams: {
          'm': getHereDirectionsMode(directionsMode),
          ...?extraParams,
        },
      );

    case MapType.petal:
      return buildUrl(
        url: 'petalmaps://route',
        queryParams: {
          'daddr':
              '${destination.latitude},${destination.longitude}${destinationTitle != null && destinationTitle.isNotEmpty ? ' ($destinationTitle)' : ''}',
          if (origin != null)
            'saddr':
                '${origin.latitude},${origin.longitude}${originTitle != null && originTitle.isNotEmpty ? ' ($originTitle)' : ''}',

          'type': getTencentDirectionsMode(directionsMode),
          ...?extraParams,
        },
      );

    case MapType.tomtomgo:
      if (Platform.isIOS) {
        return buildUrl(
          url: 'tomtomgo://x-callback-url/navigate',
          queryParams: {
            'destination': '${destination.latitude},${destination.longitude}',
            ...?extraParams,
          },
        );
      }
      return buildUrl(
        url: 'google.navigation:',
        queryParams: {
          'q': '${destination.latitude},${destination.longitude}',
          ...?extraParams,
        },
        // the TomTom Go app cannot handle the ? at the start of the query
      ).replaceFirst('?', '');

    case MapType.copilot:
      // Documentation:
      // https://developer.trimblemaps.com/copilot-navigation/v10-19/feature-guide/advanced-features/url-launch/
      return buildUrl(
        url: 'copilot://mydestination',
        queryParams: {
          'type': 'LOCATION',
          'action': 'GOTO',
          'name': destinationTitle ?? '',
          'lat': "${destination.latitude}",
          'long': "${destination.longitude}",
          ...?extraParams,
        },
      );

    case MapType.tomtomgofleet:
      return buildUrl(
        url: 'google.navigation:',
        queryParams: {
          'q': '${destination.latitude},${destination.longitude}',
          ...?extraParams,
        },
      );

    case MapType.sygicTruck:
      // Documentation:
      // https://www.sygic.com/developers/professional-navigation-sdk/introduction
      return buildUrl(
        url:
            'com.sygic.aura://coordinate|${destination.longitude}|${destination.latitude}|drive',
        queryParams: {...?extraParams},
      );

    case MapType.flitsmeister:
      if (Platform.isIOS) {
        return buildUrl(
          url: 'flitsmeister://',
          queryParams: {
            'geo': '${destination.latitude},${destination.longitude}',
            ...?extraParams,
          },
        );
      }
      return buildUrl(
        url: 'geo:${destination.latitude},${destination.longitude}',
        queryParams: {...?extraParams},
      );

    case MapType.truckmeister:
      if (Platform.isIOS) {
        return buildUrl(
          url: 'truckmeister://',
          queryParams: {
            'geo': '${destination.latitude},${destination.longitude}',
            ...?extraParams,
          },
        );
      }
      return buildUrl(
        url: 'geo:${destination.latitude},${destination.longitude}',
        queryParams: {
          'q': '${destination.latitude},${destination.longitude}',
          ...?extraParams,
        },
      );

    case MapType.naver:
      return buildUrl(
        url: 'nmap://route/car',
        queryParams: {
          if (origin != null) ...{
            'slat': origin.latitude.toString(),
            'slng': origin.longitude.toString(),
          },
          'sname': ?originTitle,
          'dlat': destination.latitude.toString(),
          'dlng': destination.longitude.toString(),
          'dname': ?destinationTitle,
          ...?extraParams,
        },
      );

    case MapType.kakao:
      return buildUrl(
        url: 'kakaomap://route',
        queryParams: {
          if (origin != null) 'sp': '${origin.latitude},${origin.longitude}',
          'ep': '${destination.latitude},${destination.longitude}',
          ...?extraParams,
        },
      );

    case MapType.tmap:
      return buildUrl(
        url: 'tmap://route',
        queryParams: {
          'startname': ?originTitle,
          if (origin != null) ...{
            'startx': origin.longitude.toString(),
            'starty': origin.latitude.toString(),
          },
          'goalname': ?destinationTitle,
          'goaly': destination.latitude.toString(),
          'goalx': destination.longitude.toString(),
          'carType': '1',
          ...?extraParams,
        },
      );

    case MapType.mapyCz:
      return buildUrl(
        url: 'https://mapy.cz/zakladni',
        queryParams: {
          'id': '${destination.longitude},${destination.latitude}',
          'source': 'coor',
          ...?extraParams,
        },
      );

    case MapType.mappls:
      return buildUrl(
        url: "https://mappls.com/navigation",
        queryParams: {
          'places':
              '${destination.latitude},${destination.longitude}${destinationTitle != null && destinationTitle.isNotEmpty ? ',$destinationTitle' : ''}',
          'mode': getMapplsDirectionsMode(directionsMode),
          ...?extraParams,
        },
      );
  }
}
