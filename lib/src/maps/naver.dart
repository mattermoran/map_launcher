import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/naver_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Naver Map. Mobile only, directions with origin.
class NaverMap extends MapApp {
  /// Creates a [NaverMap].
  const NaverMap();

  @override
  String get id => 'naver';

  @override
  String get name => 'Naver Map';

  @override
  String? get playStoreId => 'com.nhn.android.nmap';

  @override
  String? get appStoreId => '311867728';

  @override
  String? get iosScheme => 'nmap://';

  @override
  Uint8List get iconBytes => naverIcon;

  @override
  bool supportsTravelMode(TravelMode mode) => mode == .driving;
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
    url: 'nmap://place',
    queryParams: {
      'lat': coords.lat.toString(),
      'lng': coords.lng.toString(),
      if (zoom != null) 'zoom': zoom.toString(),
      if (coords.title != null) 'name': coords.title!,
    },
  );

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => buildUrl(
    url: 'nmap://route/car',
    queryParams: {
      if (origin != null) ...{
        'slat': origin.lat.toString(),
        'slng': origin.lng.toString(),
        if (origin.title != null) 'sname': origin.title!,
      },
      'dlat': destination.lat.toString(),
      'dlng': destination.lng.toString(),
      if (destination.title != null) 'dname': destination.title!,
    },
  );
}
