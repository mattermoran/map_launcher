import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Sygic Truck — mobile only, destination only, pipe-separated URL.
class SygicTruckBuilder extends MapUrlBuilder {
  /// Creates a [SygicTruckBuilder].
  const SygicTruckBuilder();

  @override
  MapType get mapType => .sygicTruck;

  @override
  bool get supportsMarkerCoords => false;

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
    url: [
      'com.sygic.aura://coordinate',
      coords.lng,
      coords.lat,
      'show',
    ].join('|'),
    queryParams: {},
  );

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => buildUrl(
    url: [
      'com.sygic.aura://coordinate',
      destination.lng,
      destination.lat,
      'drive',
    ].join('|'),
    queryParams: {},
  );
}
