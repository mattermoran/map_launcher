import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/citymapper_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Citymapper. Directions only, with optional origin.
class Citymapper extends MapApp {
  /// Creates a [Citymapper].
  const Citymapper();

  @override
  String get id => 'citymapper';

  @override
  String get name => 'Citymapper';

  @override
  String? get playStoreId => 'com.citymapper.app.release';

  @override
  String? get appStoreId => '469463298';

  @override
  String? get iosScheme => 'citymapper://';

  @override
  Uint8List get iconBytes => citymapperIcon;

  /// Intentionally `false` even though [markerSchemeUrl] returns a non-null
  /// URL. Citymapper is a nav-only app, so [markerSchemeUrl] routes to
  /// directions as a best-effort fallback, not a true marker pin.
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
  }) => _directionsUrl(coords); // best-effort: opens directions to that point

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => _directionsUrl(destination, origin: origin);

  static String _directionsUrl(
    LocationCoords destination, {
    LocationCoords? origin,
  }) {
    return buildUrl(
      url: 'citymapper://directions',
      queryParams: {
        'endcoord': destination.latlng,
        'endname': ?destination.title,
        if (origin != null) ...{
          'startcoord': origin.latlng,
          if (origin.title != null) 'startname': origin.title!,
        },
      },
    );
  }
}
