import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/apple_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Apple Maps. Supports coordinates, text queries, directions with
/// origin and travel mode. No waypoint support.
class AppleMaps extends MapApp {
  /// Creates a [AppleMaps].
  const AppleMaps();

  @override
  String get id => 'apple';

  @override
  String get name => 'Apple Maps';

  @override
  bool get hasUniversalLink => true;

  @override
  String? get appStoreId => '915056765';

  @override
  Uint8List get iconBytes => appleIcon;

  @override
  bool isAlwaysAvailable(MapPlatform platform) => platform == MapPlatform.ios;

  @override
  bool get supportsMarkerSearch => true;

  @override
  bool get supportsDirectionsSearch => true;
  @override
  String markerUrl(LocationCoords coords, {int? zoom}) => buildUrl(
    url: 'https://maps.apple.com/',
    queryParams: {
      'll': coords.latlng,
      'q': ?coords.title,
      if (zoom != null) 'z': zoom.toString(),
    },
  );

  @override
  String markerSearchUrl(String query) =>
      buildUrl(url: 'https://maps.apple.com/', queryParams: {'q': query});

  @override
  String directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  }) => buildUrl(
    url: 'https://maps.apple.com/',
    queryParams: {
      'daddr': destination.latlng,
      if (origin != null) 'saddr': origin.latlng,
      if (travelMode != null)
        'dirflg': switch (travelMode) {
          .driving => 'd',
          .walking => 'w',
          .transit => 'r',
          .bicycling => 'b',
        },
    },
  );

  @override
  String directionsSearchUrl(
    String query, {
    LocationCoords? origin,
    TravelMode? travelMode,
  }) => buildUrl(
    url: 'https://maps.apple.com/',
    queryParams: {
      'daddr': query,
      if (origin != null) 'saddr': origin.latlng,
      if (travelMode != null)
        'dirflg': switch (travelMode) {
          .driving => 'd',
          .walking => 'w',
          .transit => 'r',
          .bicycling => 'b',
        },
    },
  );
}
