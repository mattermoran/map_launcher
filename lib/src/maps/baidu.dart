import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/baidu_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_launch_exception.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/launch_helper.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Baidu Maps. Mobile only, directions with origin and travel mode.
class BaiduMaps extends MapApp {
  /// Creates a [BaiduMaps] with caller attribution, e.g. `company.application`.
  ///
  /// The platform prefix (`andr.` or `ios.`) is added automatically.
  /// Alternatively pass a complete `src` through request extras.
  /// Attribution is documented by Baidu but not enforced by this plugin.
  const BaiduMaps({this.source});

  /// Caller company and application, without the platform prefix.
  final String? source;

  @override
  String get id => 'baidu';

  @override
  String get name => 'Baidu Maps';

  @override
  String? get playStoreId => 'com.baidu.BaiduMap';

  @override
  String? get appStoreId => '452186370';

  @override
  String? get iosScheme => 'baidumap://';

  @override
  Uint8List get iconBytes => baiduIcon;

  @override
  String applyLaunchDefaults(String url, {MapPlatform? platform}) {
    if (platform != .ios) return url;
    final uri = Uri.parse(url);
    final params = uri.queryParameters;
    if (uri.path == '/marker' && !params.containsKey('content')) {
      return appendQueryParams(url, {'content': params['location']!});
    }
    if (uri.path == '/direction' && !params.containsKey('origin')) {
      return appendQueryParams(url, {'origin': '我的位置'});
    }
    return url;
  }

  @override
  void validateLaunchUrl(String url) {
    final uri = Uri.parse(url);
    if (uri.path == '/direction' &&
        uri.queryParameters['origin']?.trim().isNotEmpty != true) {
      throw MapConfigurationError('Baidu directions require an origin.');
    }
  }

  @override
  String? markerUrl(LocationCoords coords, {int? zoom}) => null;

  @override
  String? directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  }) => null;

  @override
  String? markerSchemeUrl(
    LocationCoords coords, {
    int? zoom,
    required MapPlatform platform,
  }) => buildUrl(
    url: 'baidumap://map/marker',
    queryParams: {
      'location': coords.latlng,
      'title': coords.title?.trim().isNotEmpty == true
          ? coords.title!
          : coords.latlng,
      if (platform == .android) 'traffic': 'on',
      if (source != null) 'src': '${platform == .ios ? 'ios' : 'andr'}.$source',
      'coord_type': 'gcj02',
      if (zoom != null) 'zoom': zoom.toString(),
    },
  );

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) {
    // Caller extras may supply a named origin. Validate after they are merged.
    return buildUrl(
      url: 'baidumap://map/direction',
      queryParams: {
        'destination':
            'latlng:${destination.latlng}|name:${destination.title ?? ''}',
        if (origin != null)
          'origin': 'latlng:${origin.latlng}|name:${origin.title ?? ''}',
        'coord_type': 'gcj02',
        if (source != null)
          'src': '${platform == .ios ? 'ios' : 'andr'}.$source',
        'mode': switch (travelMode) {
          .driving => 'driving',
          .walking => 'walking',
          .transit => 'transit',
          .bicycling => 'riding',
          null => 'driving',
        },
      },
    );
  }
}
