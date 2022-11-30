import 'dart:io';
import 'package:map_launcher/src/models.dart';
import 'package:map_launcher/src/utils.dart';

/// Returns a url that is used by [showDirections]
String getMapDirectionsUrl({
  required MapType mapType,
  required Coords? destination,
  String? destinationTitle,
  Coords? origin,
  String? originTitle,
  DirectionsMode? directionsMode,
  List<Coords>? waypoints,
  Map<String, String>? extraParams,
}) {
  switch (mapType) {
    case MapType.googleGo:
    case MapType.google:
      // https://developers.google.com/maps/documentation/urls/get-started#directions-action
      return Utils.buildUrl(
        url: 'https://www.google.com/maps/dir/',
        queryParams: {
          'api': '1',
          'destination': destination != null
              ? '${destination.latitude},${destination.longitude}'
              : destinationTitle,
          'origin': Utils.nullOrValue(
            origin,
            '${origin?.latitude},${origin?.longitude}',
          ),
          'waypoints': waypoints
              ?.map((coords) => '${coords.latitude},${coords.longitude}')
              .join('|'),
          'travelmode': Utils.enumToString(directionsMode),
          ...(extraParams ?? {}),
        },
      );
    case MapType.apple:
      // https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html
      // https://itnext.io/apple-maps-url-schemes-e1d3ac7340af
      return Utils.buildUrl(
        url: Platform.isIOS ? 'maps://' : 'http://maps.apple.com/maps',
        queryParams: {
          'dirflg': Utils.getAppleDirectionsMode(directionsMode),
          'saddr': origin != null
              ? '${origin.latitude},${origin.longitude}'
              : originTitle,
          'daddr': destination != null
              ? '${destination.latitude},${destination.longitude}'
              : destinationTitle,
          ...(extraParams ?? {}),
        },
      );

    case MapType.amap:
      // Android: https://lbs.amap.com/api/amap-mobile/guide/android/route
      // iOS: https://lbs.amap.com/api/amap-mobile/guide/ios/route
      return Utils.buildUrl(
        url: Platform.isIOS ? 'iosamap://path' : 'amapuri://route/plan/',
        queryParams: {
          'sourceApplication': 'applicationName',
          'dlat': destination?.latitude.toString(),
          'dlon': destination?.longitude.toString(),
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
      // Android: https://lbsyun.baidu.com/index.php?title=uri/api/android#:~:text=URL%E6%8E%A5%E5%8F%A3%EF%BC%9A-,baidumap%3A//map/direction,-%E5%8F%82%E6%95%B0%E8%AF%B4%E6%98%8E
      // iOS: https://lbsyun.baidu.com/index.php?title=uri/api/ios#:~:text=%E6%9C%8D%E5%8A%A1%E5%9C%B0%E5%9D%80-,baidumap%3A//map/direction,-//%20iOS%E6%9C%8D%E5%8A%A1%E5%9C%B0%E5%9D%80
      String? loc(Coords? coords, String? title) =>
          title != null && coords != null
              ? 'name:$title|latlng:${coords.latitude},${coords.longitude}'
              : coords != null
                  ? '${coords.latitude},${coords.longitude}'
                  : title;

      return Utils.buildUrl(
        url: 'baidumap://map/direction',
        queryParams: {
          'destination': loc(destination, destinationTitle),
          'origin': loc(origin, originTitle),
          'coord_type': 'gcj02',
          'mode': Utils.getBaiduDirectionsMode(directionsMode),
          'src': 'com.map_launcher',
          ...(extraParams ?? {}),
        },
      );

    case MapType.waze:
      destination ??= Coords.zero; // Not tested, fallback to zero.
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
      destination ??= Coords.zero; // Not tested, fallback to zero.
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
      destination ??= Coords.zero; // Not tested, fallback to zero.
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
      destination ??= Coords.zero; // Not tested, fallback to zero.
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
      destination ??= Coords.zero; // Not tested, fallback to zero.
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
      destination ??= Coords.zero; // Not tested, fallback to zero.
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
      destination ??= Coords.zero; // Not tested, fallback to zero.
      return Utils.buildUrl(
        url:
            'dgis://2gis.ru/routeSearch/rsType/${Utils.getDoubleGisDirectionsMode(directionsMode)}/${origin == null ? '' : 'from/${origin.longitude},${origin.latitude}/'}to/${destination.longitude},${destination.latitude}',
        queryParams: {
          ...(extraParams ?? {}),
        },
      );

    case MapType.tencent:
      // When destination is null, you need to manually click the input box to search.
      // https://lbs.qq.com/webApi/uriV1/uriGuide/uriMobileRoute
      return Utils.buildUrl(
        url: 'qqmap://map/routeplan',
        queryParams: {
          'from': originTitle,
          'fromcoord': origin != null //
              ? '${origin.latitude},${origin.longitude}'
              : null,
          'to': destinationTitle,
          'tocoord': destination != null
              ? '${destination.latitude},${destination.longitude}'
              : null,
          'type': Utils.getTencentDirectionsMode(directionsMode),
          ...(extraParams ?? {}),
        },
      );

    case MapType.here:
      destination ??= Coords.zero; // Not tested, fallback to zero.
      return Utils.buildUrl(
        url:
            'https://share.here.com/r/${origin?.latitude},${origin?.longitude},$originTitle/${destination.latitude},${destination.longitude}',
        queryParams: {
          'm': Utils.getHereDirectionsMode(directionsMode),
          ...(extraParams ?? {}),
        },
      );

    case MapType.petal:
      destination ??= Coords.zero; // Not tested, fallback to zero.
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
      destination ??= Coords.zero; // Not tested, fallback to zero.
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
  }
}
