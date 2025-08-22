import 'dart:io';

import 'package:map_launcher/src/models.dart';
import 'package:map_launcher/src/utils/direction_modes.dart';
import 'package:map_launcher/src/utils/url_builder.dart';
import 'package:map_launcher/src/utils/utils.dart';

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
    case MapType.googleGo:
      return buildUrl(
        url: 'https://www.google.com/maps/dir/',
        queryParams: {
          'api': '1',
          'destination': destination.latlng,
          'origin': ?origin?.latlng,
          'waypoints': ?waypoints
              ?.map((waypoint) => waypoint.coords.latlng)
              .join('|'),
          'travelmode': ?directionsMode?.name,
          ...?extraParams,
        },
      );

    case MapType.apple:
      return buildUrl(
        url: 'http://maps.apple.com/maps',
        queryParams: {'daddr': destination.latlng, ...?extraParams},
      );

    case MapType.amap:
      return buildUrl(
        url: Platform.isIOS ? 'iosamap://path' : 'amapuri://route/plan/',
        queryParams: {
          'sourceApplication': 'applicationName',
          'dlat': destination.latitude.toString(),
          'dlon': destination.longitude.toString(),
          'dname': ?destinationTitle,
          'slat': ?origin?.latitude.toString(),
          'slon': ?origin?.longitude.toString(),
          'sname': ?originTitle,
          't': getAmapDirectionsMode(directionsMode),
          'dev': '0',
          ...?extraParams,
        },
      );

    case MapType.baidu:
      final formattedDestinationTitle = destinationTitle.isNotNullOrEmpty
          ? destinationTitle
          : 'Destination';
      final formattedOriginTitle = destinationTitle.isNotNullOrEmpty
          ? originTitle
          : 'Origin';
      return buildUrl(
        url: 'baidumap://map/direction',
        queryParams: {
          'destination':
              'name: $formattedDestinationTitle|latlng:${destination.latlng}',
          if (origin != null)
            'origin': 'name: $formattedOriginTitle|latlng:${origin.latlng}',
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
          'll': destination.latlng,
          'z': '10',
          'navigate': 'yes',
          ...?extraParams,
        },
      );

    case MapType.citymapper:
      return buildUrl(
        url: 'citymapper://directions',
        queryParams: {
          'endcoord': destination.latlng,
          'endname': ?destinationTitle,
          'startcoord': ?origin?.latlng,
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
      return 'osmand.navigation:q=${destination.latlng}';

    case MapType.mapswithme:
      return buildUrl(
        url: 'mapsme://map',
        queryParams: {
          'v': '1',
          'll': destination.latlng,
          'n': ?destinationTitle,
          ...?extraParams,
        },
      );

    case MapType.yandexMaps:
      // https://yandex.com/dev/yandex-apps-launch-maps/doc/en/
      return buildUrl(
        url: 'yandexmaps://maps.yandex.com/',
        queryParams: {
          'rtext': [
            ?origin?.latlng,
            ...?waypoints?.map((waypoint) => waypoint.coords.latlng),
            destination.latlng,
          ].join('~'),
          'rtt': getYandexMapsDirectionsMode(directionsMode),
          ...?extraParams,
        },
      );

    case MapType.yandexNavi:
      // https://yandex.ru/dev/navigator/doc/ru/
      return buildUrl(
        url: 'yandexnavi://build_route_on_map',
        queryParams: {
          'lat_to': destination.latitude.toString(),
          'lon_to': destination.longitude.toString(),
          'lat_from': ?origin?.latitude.toString(),
          'lon_from': ?origin?.longitude.toString(),
          for (var i = 0; i < (waypoints?.length ?? 0); i++) ...{
            'lat_via_$i': '${waypoints?[i].latitude}',
            'lon_via_$i': '${waypoints?[i].longitude}',
          },
          ...?extraParams,
        },
      );

    case MapType.doubleGis:
      return buildUrl(
        url: [
          'dgis://2gis.ru/routeSearch/rsType',
          getDoubleGisDirectionsMode(directionsMode),
          if (origin != null) 'from/${origin.lnglat}',
          'to/${destination.lnglat}',
        ].join('/'),
        queryParams: {...?extraParams},
      );

    case MapType.tencent:
      return buildUrl(
        url: 'qqmap://map/routeplan',
        queryParams: {
          'from': ?originTitle,
          'fromcoord': ?origin?.latlng,
          'to': ?destinationTitle,
          'tocoord': destination.latlng,
          'type': getTencentDirectionsMode(directionsMode),
          ...?extraParams,
        },
      );

    case MapType.here:
      return buildUrl(
        url: [
          'https://share.here.com/r',
          '${origin?.latlng},$originTitle',
          destination.latlng,
        ].join('/'),
        queryParams: {
          'm': getHereDirectionsMode(directionsMode),
          ...?extraParams,
        },
      );

    case MapType.petal:
      final formattedDestinationTitle = destinationTitle.isNotNullOrEmpty
          ? '($destinationTitle)'
          : '';
      final formattedOriginTitle = destinationTitle.isNotNullOrEmpty
          ? '($originTitle)'
          : '';
      return buildUrl(
        url: 'petalmaps://route',
        queryParams: {
          'daddr': '${destination.latlng}$formattedDestinationTitle',
          if (origin != null) 'saddr': '${origin.latlng}$formattedOriginTitle',
          'type': getTencentDirectionsMode(directionsMode),
          ...?extraParams,
        },
      );

    case MapType.tomtomgo:
      if (Platform.isIOS) {
        return buildUrl(
          url: 'tomtomgo://x-callback-url/navigate',
          queryParams: {'destination': destination.latlng, ...?extraParams},
        );
      }
      return buildUrl(
        url: 'google.navigation:',
        queryParams: {'q': destination.latlng, ...?extraParams},
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
          'lat': destination.latitude.toString(),
          'long': destination.longitude.toString(),
          ...?extraParams,
        },
      );

    case MapType.tomtomgofleet:
      return buildUrl(
        url: 'google.navigation:',
        queryParams: {'q': destination.latlng, ...?extraParams},
      );

    case MapType.sygicTruck:
      // Documentation:
      // https://www.sygic.com/developers/professional-navigation-sdk/introduction
      return buildUrl(
        url: [
          'com.sygic.aura://coordinate',
          destination.longitude,
          destination.latitude,
          'drive',
        ].join('|'),

        queryParams: {...?extraParams},
      );

    case MapType.flitsmeister:
      if (Platform.isIOS) {
        return buildUrl(
          url: 'flitsmeister://',
          queryParams: {'geo': destination.latlng, ...?extraParams},
        );
      }
      return buildUrl(
        url: 'geo:${destination.latlng}',
        queryParams: {...?extraParams},
      );

    case MapType.truckmeister:
      if (Platform.isIOS) {
        return buildUrl(
          url: 'truckmeister://',
          queryParams: {'geo': destination.latlng, ...?extraParams},
        );
      }
      return buildUrl(
        url: 'geo:${destination.latlng}',
        queryParams: {'q': destination.latlng, ...?extraParams},
      );

    case MapType.naver:
      return buildUrl(
        url: 'nmap://route/car',
        queryParams: {
          'slat': ?origin?.latitude.toString(),
          'slng': ?origin?.longitude.toString(),
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
          'sp': ?origin?.latlng,
          'ep': destination.latlng,
          ...?extraParams,
        },
      );

    case MapType.tmap:
      return buildUrl(
        url: 'tmap://route',
        queryParams: {
          'startname': ?originTitle,
          'startx': ?origin?.longitude.toString(),
          'starty': ?origin?.latitude.toString(),
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
          'id': destination.lnglat,
          'source': 'coor',
          ...?extraParams,
        },
      );

    case MapType.mappls:
      final formattedDestinationTitle = destinationTitle.isNotNullOrEmpty
          ? ',$destinationTitle'
          : '';
      return buildUrl(
        url: "https://mappls.com/navigation",
        queryParams: {
          'places': '${destination.latlng}$formattedDestinationTitle',
          'mode': getMapplsDirectionsMode(directionsMode),
          ...?extraParams,
        },
      );

    case MapType.moovit:
      // https: //moovit.com/developers/deeplinking/
      return buildUrl(
        url: 'moovit://directions',
        queryParams: {
          'dest_lat': destination.latitude.toString(),
          'dest_lon': destination.longitude.toString(),
          'dest_name': ?destinationTitle,
          'orig_lat': ?origin?.latitude.toString(),
          'orig_lon': ?origin?.longitude.toString(),
          'orig_name': ?originTitle,
          ...?extraParams,
        },
      );

    case MapType.neshan:
      return buildUrl(
        url: Platform.isIOS ? 'neshan://' : 'https://nshn.ir/',
        queryParams: {
          'origin': ?origin?.latlng,
          'destination': destination.latlng,
          ...?extraParams,
        },
      );
  }
}
