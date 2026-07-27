import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/neshan_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Neshan. Mobile only, directions with origin.
class Neshan extends MapApp {
  /// Creates a [Neshan].
  const Neshan();

  @override
  String get id => 'neshan';

  @override
  String get name => 'Neshan';

  @override
  String? get playStoreId => 'org.rajman.neshan.traffic.tehran.navigator';

  @override
  String? get appStoreId => '1596368814';

  @override
  String? get iosScheme => 'neshan://';

  @override
  Uint8List get iconBytes => neshanIcon;

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
        url: 'neshan://',
        queryParams: {'destination': coords.latlng},
      );
    }
    return buildUrl(
      url: 'https://nshn.ir',
      queryParams: {'lat': coords.lat.toString(), 'lng': coords.lng.toString()},
    );
  }

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => buildUrl(
    url: platform == .ios ? 'neshan://' : 'https://nshn.ir/',
    queryParams: {
      if (origin != null) 'origin': origin.latlng,
      'destination': destination.latlng,
    },
  );
}
