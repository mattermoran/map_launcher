import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Air Navigation Pro — flight navigation, marker only.
class AirNavProBuilder extends MapUrlBuilder {
  /// Creates an [AirNavProBuilder].
  const AirNavProBuilder();

  @override
  MapType get mapType => .airnavPro;

  @override
  bool get supportsDirectionsCoords => false;

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
  }) => _schemeUrl(coords, platform: platform);

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => _schemeUrl(destination, platform: platform);

  static String _schemeUrl(
    LocationCoords coords, {
    required MapPlatform platform,
  }) {
    final location = '${coords.lat}_${coords.lng},0.0';
    return switch (platform) {
      .ios => buildUrl(
        url: 'airnavpro://direct-to',
        queryParams: {'coordinates': 'wgs84-decimal', 'location': location},
      ),
      .android => buildUrl(
        url: 'https://airnavigation.aero/direct-to',
        queryParams: {'coordinates': 'wgs84-decimal', 'location': location},
      ),
    };
  }
}
