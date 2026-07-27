import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/osmand_icon.dart';
import 'package:map_launcher/src/maps/icons/osmandplus_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';

import 'package:map_launcher/src/utils/url_builder.dart';

/// OsmAnd. Mobile only, iOS uses scheme, Android uses http.
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
    if (platform == .ios) {
      return buildUrl(
        url: 'osmandmaps://navigate',
        queryParams: {
          'lat': destination.lat.toString(),
          'lon': destination.lng.toString(),
          if (destination.title != null) 'title': destination.title!,
        },
      );
    }
    return buildUrl(
      url: 'http://osmand.net/go',
      queryParams: {
        'lat': destination.lat.toString(),
        'lon': destination.lng.toString(),
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
