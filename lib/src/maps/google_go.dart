import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/google_go_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Google Maps Go. Android only, coordinates, directions with travel mode.
class GoogleMapsGo extends MapApp {
  /// Creates a [GoogleMapsGo].
  const GoogleMapsGo();

  @override
  String get id => 'googleGo';

  @override
  String get name => 'Google Maps Go';

  @override
  String? get playStoreId => 'com.google.android.apps.mapslite';

  @override
  Uint8List get iconBytes => googleGoIcon;

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
    url: 'geo:0,0',
    queryParams: {
      'q': coords.title != null
          ? '${coords.latlng}(${coords.title})'
          : coords.latlng,
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
    url: 'google.navigation:',
    queryParams: {
      'q': destination.latlng,
      if (travelMode != null) 'mode': travelMode.name.substring(0, 1),
    },
  );
}
