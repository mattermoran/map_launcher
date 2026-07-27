import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/airnav_pro_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Air Navigation Pro. Flight navigation, marker only.
class AirNavPro extends MapApp {
  /// Creates a [AirNavPro].
  const AirNavPro();

  @override
  String get id => 'airnavPro';

  @override
  String get name => 'Air Navigation Pro';

  @override
  String? get playStoreId => 'com.xample.airnavigation';

  @override
  String? get appStoreId => '304684223';

  @override
  String? get iosScheme => 'airnavpro://';

  @override
  Uint8List get iconBytes => airnavProIcon;

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
