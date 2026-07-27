import 'dart:typed_data';
import 'package:flutter/foundation.dart' show protected;
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/flitsmeister_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Flitsmeister. Traffic/navigation only.
class Flitsmeister extends MapApp {
  /// Creates a [Flitsmeister].
  const Flitsmeister();

  @override
  String get id => 'flitsmeister';

  @override
  String get name => 'Flitsmeister';

  @override
  String? get playStoreId => 'nl.flitsmeister';

  @override
  Uint8List get iconBytes => flitsmeisterIcon;

  /// The URL scheme for this map app.
  @protected
  String get scheme => 'flitsmeister';

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
  }) {
    if (platform == .ios) {
      return buildUrl(url: '$scheme://', queryParams: {'geo': coords.latlng});
    }
    return buildUrl(
      url: 'geo:${coords.latlng}',
      queryParams: {'q': coords.latlng},
    );
  }

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) {
    if (platform == .ios) {
      return buildUrl(
        url: '$scheme://',
        queryParams: {'geo': destination.latlng},
      );
    }
    return 'geo:${destination.latlng}';
  }
}
