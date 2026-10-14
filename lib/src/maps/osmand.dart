import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/osmand_icon.dart';
import 'package:map_launcher/src/maps/icons/osmandplus_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';

import 'package:map_launcher/src/utils/url_builder.dart';

/// OsmAnd. Mobile markers and HTTP(S) route-planning links.
class OsmAnd extends MapApp {
  /// Creates a [OsmAnd].
  const OsmAnd();

  @override
  String get id => 'osmand';

  @override
  String get name => 'OsmAnd';

  @override
  String? get playStoreId => 'net.osmand';

  @override
  String? get appStoreId => '934850257';

  @override
  String? get iosScheme => 'osmandmaps://';

  @override
  Uint8List get iconBytes => osmandIcon;

  @override
  bool get supportsWaypoints => true;

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
      return buildUrl(
        url: 'osmandmaps://',
        queryParams: {
          'lat': coords.lat.toString(),
          'lon': coords.lng.toString(),
          if (zoom != null) 'z': zoom.toString(),
          if (coords.title != null) 'title': coords.title!,
        },
      );
    }
    return buildUrl(
      url: 'http://osmand.net/go',
      queryParams: {
        'lat': coords.lat.toString(),
        'lon': coords.lng.toString(),
        if (zoom != null) 'z': zoom.toString(),
      },
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
    // Both 5.3 release branches parse this route-planning contract.
    // Unlike /go or the iOS custom navigate action, it honors route inputs.
    return buildUrl(
      url: 'https://osmand.net/map/navigate',
      queryParams: {
        if (origin != null) 'start': origin.latlng,
        'end': destination.latlng,
        if (waypoints != null && waypoints.isNotEmpty)
          'via': waypoints.map((point) => point.latlng).join(';'),
        if (travelMode != null)
          'profile': switch (travelMode) {
            .driving => 'car',
            .walking => 'pedestrian',
            .transit => 'public_transport',
            .bicycling => 'bicycle',
          },
      },
    );
  }
}

/// OsmAnd+. Same as OsmAnd but different package identifier.
class OsmAndPlus extends OsmAnd {
  /// Creates a [OsmAndPlus].
  const OsmAndPlus();

  @override
  String get id => 'osmandplus';

  @override
  String get name => 'OsmAnd+';

  @override
  String? get playStoreId => 'net.osmand.plus';

  // OsmAnd+ is Android-only; inheriting OsmAnd's iOS identifiers would
  // report it as installed on iOS whenever OsmAnd is, and link its
  // appStoreUrl to the OsmAnd app.
  @override
  String? get appStoreId => null;

  @override
  String? get iosScheme => null;

  @override
  Uint8List get iconBytes => osmandplusIcon;
}
