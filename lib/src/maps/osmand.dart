import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';

import 'package:map_launcher/src/utils/url_builder.dart';

/// OsmAnd — mobile only, iOS uses scheme, Android uses http.
class OsmAndBuilder extends MapUrlBuilder {
  /// Creates an [OsmAndBuilder].
  const OsmAndBuilder();

  @override
  MapType get mapType => .osmand;

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

/// OsmAnd+ — same as OsmAnd but different package identifier.
class OsmAndPlusBuilder extends OsmAndBuilder {
  /// Creates an [OsmAndPlusBuilder].
  const OsmAndPlusBuilder();

  @override
  MapType get mapType => .osmandplus;
}
