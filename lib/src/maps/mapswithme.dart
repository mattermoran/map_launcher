import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/mapswithme_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';

import 'package:map_launcher/src/utils/url_builder.dart';

/// MAPS.ME. Mobile only, destination only.
class MapsMe extends MapApp {
  /// Creates a [MapsMe].
  const MapsMe();

  @override
  String get id => 'mapswithme';

  @override
  String get name => 'MAPS.ME';

  @override
  String? get playStoreId => 'com.mapswithme.maps.pro';

  @override
  String? get appStoreId => '510623322';

  // The app registers both mapswithme:// and mapsme://. Detection uses
  // mapswithme:// because that is the scheme consumers declare in
  // LSApplicationQueriesSchemes (per the README, unchanged since 5.x).
  @override
  String? get iosScheme => 'mapswithme://';

  @override
  Uint8List get iconBytes => mapswithmeIcon;

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
    url: 'mapsme://map',
    queryParams: {
      'v': '1',
      'll': coords.latlng,
      if (coords.title != null) 'n': coords.title!,
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
    url: 'mapsme://route',
    queryParams: {
      'v': '1',
      'll': destination.latlng,
      if (destination.title != null) 'n': destination.title!,
    },
  );
}
