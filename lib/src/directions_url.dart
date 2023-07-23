import 'dart:io';
import 'package:map_launcher/src/models.dart';
import 'package:map_launcher/src/utils.dart';

/// Returns a url that is used by [showDirections]
String getMapDirectionsUrl(MapDirectionsParams params) {
  switch (params.mapType) {
    case MapType.google:
      return Utils.buildUrl(
        url: 'https://www.google.com/maps/dir/',
        queryParams: {
          'api': '1',
          'destination':
              '${params.destination.latitude},${params.destination.longitude}',
          'origin': Utils.nullOrValue(
            params.origin,
            '${params.origin?.latitude},${params.origin?.longitude}',
          ),
          'waypoints': params.waypoints
              ?.map((coords) => '${coords.latitude},${coords.longitude}')
              .join('|'),
          'travelmode': params.directionsMode?.name,
          ...params.extraParams,
        },
      );

    case MapType.googleGo:
      return Utils.buildUrl(
        url: 'https://www.google.com/maps/dir/',
        queryParams: {
          'api': '1',
          'destination':
              '${params.destination.latitude},${params.destination.longitude}',
          'origin': Utils.nullOrValue(
            params.origin,
            '${params.origin?.latitude},${params.origin?.longitude}',
          ),
          'waypoints': params.waypoints
              ?.map((coords) => '${coords.latitude},${coords.longitude}')
              .join('|'),
          'travelmode': params.directionsMode?.name,
          ...params.extraParams
        },
      );

    case MapType.apple:
      return Utils.buildUrl(
        url: 'http://maps.apple.com/maps',
        queryParams: {
          'daddr':
              '${params.destination.latitude},${params.destination.longitude}',
          ...params.extraParams
        },
      );

    case MapType.amap:
      return Utils.buildUrl(
        url: Platform.isIOS ? 'iosamap://path' : 'amapuri://route/plan/',
        queryParams: {
          'sourceApplication': 'applicationName',
          'dlat': '${params.destination.latitude}',
          'dlon': '${params.destination.longitude}',
          'dname': params.destinationTitle,
          'slat':
              Utils.nullOrValue(params.origin, '${params.origin?.latitude}'),
          'slon':
              Utils.nullOrValue(params.origin, '${params.origin?.longitude}'),
          'sname': params.originTitle,
          't': Utils.getAmapDirectionsMode(params.directionsMode),
          'dev': '0',
          ...params.extraParams
        },
      );

    case MapType.baidu:
      return Utils.buildUrl(
        url: 'baidumap://map/direction',
        queryParams: {
          'destination':
              'name: ${params.destinationTitle ?? 'Destination'}|latlng:${params.destination.latitude},${params.destination.longitude}',
          'origin': Utils.nullOrValue(
            params.origin,
            'name: ${params.originTitle ?? 'Origin'}|latlng:${params.origin?.latitude},${params.origin?.longitude}',
          ),
          'coord_type': 'gcj02',
          'mode': Utils.getBaiduDirectionsMode(params.directionsMode),
          'src': 'com.map_launcher',
          ...params.extraParams
        },
      );

    case MapType.waze:
      return Utils.buildUrl(
        url: 'waze://',
        queryParams: {
          'll':
              '${params.destination.latitude},${params.destination.longitude}',
          'z': '10',
          'navigate': 'yes',
          ...params.extraParams
        },
      );

    case MapType.citymapper:
      return Utils.buildUrl(url: 'citymapper://directions', queryParams: {
        'endcoord':
            '${params.destination.latitude},${params.destination.longitude}',
        'endname': params.destinationTitle,
        'startcoord': Utils.nullOrValue(
          params.origin,
          '${params.origin?.latitude},${params.origin?.longitude}',
        ),
        'startname': params.originTitle,
        ...params.extraParams
      });

    case MapType.osmand:
    case MapType.osmandplus:
      if (Platform.isIOS) {
        return Utils.buildUrl(
          url: 'osmandmaps://navigate',
          queryParams: {
            'lat': '${params.destination.latitude}',
            'lon': '${params.destination.longitude}',
            'title': params.destinationTitle,
            ...params.extraParams
          },
        );
      }
      return 'osmand.navigation:q=${params.destination.latitude},${params.destination.longitude}';

    case MapType.mapswithme:
      // Couldn't get //route to work properly as of 2020/07
      // so just using the marker method for now
      // return Utils.buildUrl(
      //   url: 'mapsme://route',
      //   queryParams: {
      //     'dll': '${params.destination.latitude},${params.destination.longitude}',
      //     'daddr': params.destinationTitle,
      //     'sll': Utils.nullOrValue(
      //       origin,
      //       '${params.origin?.latitude},${params.origin?.longitude}',
      //     ),
      //     'saddr': params.originTitle,
      //     'type': Utils.getMapsMeDirectionsMode(params.directionsMode),
      //   },
      // );
      return Utils.buildUrl(
        url: 'mapsme://map',
        queryParams: {
          'v': '1',
          'll':
              '${params.destination.latitude},${params.destination.longitude}',
          'n': params.destinationTitle,
          ...params.extraParams
        },
      );

    case MapType.yandexMaps:
      return Utils.buildUrl(
        url: 'yandexmaps://maps.yandex.com/',
        queryParams: {
          'rtext':
              '${params.origin?.latitude},${params.origin?.longitude}~${params.destination.latitude},${params.destination.longitude}',
          'rtt': Utils.getYandexMapsDirectionsMode(params.directionsMode),
          ...params.extraParams
        },
      );

    case MapType.yandexNavi:
      return Utils.buildUrl(
        url: 'yandexnavi://build_route_on_map',
        queryParams: {
          'lat_to': '${params.destination.latitude}',
          'lon_to': '${params.destination.longitude}',
          'lat_from':
              Utils.nullOrValue(params.origin, '${params.origin?.latitude}'),
          'lon_from':
              Utils.nullOrValue(params.origin, '${params.origin?.longitude}'),
        },
      );

    case MapType.doubleGis:
      return Utils.buildUrl(
        url:
            'dgis://2gis.ru/routeSearch/rsType/${Utils.getDoubleGisDirectionsMode(params.directionsMode)}/${params.origin == null ? '' : 'from/${params.origin!.longitude},${params.origin!.latitude}/'}to/${params.destination.longitude},${params.destination.latitude}',
        queryParams: {...params.extraParams},
      );

    case MapType.tencent:
      return Utils.buildUrl(
        url: 'qqmap://map/routeplan',
        queryParams: {
          'from': params.originTitle,
          'fromcoord': '${params.origin?.latitude},${params.origin?.longitude}',
          'to': params.destinationTitle,
          'tocoord':
              '${params.destination.latitude},${params.destination.longitude}',
          'type': Utils.getTencentDirectionsMode(params.directionsMode),
          ...params.extraParams
        },
      );

    case MapType.here:
      return Utils.buildUrl(
        url:
            'https://share.here.com/r/${params.origin?.latitude},${params.origin?.longitude},$params.originTitle/${params.destination.latitude},${params.destination.longitude}',
        queryParams: {
          'm': Utils.getHereDirectionsMode(params.directionsMode),
          ...params.extraParams
        },
      );

    case MapType.petal:
      return Utils.buildUrl(url: 'petalmaps://route', queryParams: {
        'daddr':
            '${params.destination.latitude},${params.destination.longitude} (${params.destinationTitle ?? 'Destination'})',
        'saddr': Utils.nullOrValue(
          params.origin,
          '${params.origin?.latitude},${params.origin?.longitude} (${params.originTitle ?? 'Origin'})',
        ),
        'type': Utils.getTencentDirectionsMode(params.directionsMode),
        ...params.extraParams
      });

    case MapType.tomtomgo:
      if (Platform.isIOS) {
        return Utils.buildUrl(
          url: 'tomtomgo://x-callback-url/navigate',
          queryParams: {
            'destination':
                '${params.destination.latitude},${params.destination.longitude}',
            ...params.extraParams
          },
        );
      }
      return Utils.buildUrl(
        url: 'google.navigation:',
        queryParams: {
          'q': '${params.destination.latitude},${params.destination.longitude}',
          ...params.extraParams
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
          'name': params.destinationTitle ?? '',
          'lat': "${params.destination.latitude}",
          'long': "${params.destination.longitude}",
          ...params.extraParams
        },
      );
  }
}
