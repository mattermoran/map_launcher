import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/tomtomgo_icon.dart';
import 'package:map_launcher/src/maps/icons/tomtomgofleet_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// TomTom Go. Navigation only, destination only.
class TomTomGo extends MapApp {
  /// Creates a [TomTomGo].
  const TomTomGo();

  @override
  String get id => 'tomtomgo';

  @override
  String get name => 'TomTom Go';

  @override
  String? get playStoreId => 'com.tomtom.gplay.navapp';

  @override
  String? get appStoreId => '884963367';

  @override
  String? get iosScheme => 'tomtomgo://';

  @override
  Uint8List get iconBytes => tomtomgoIcon;

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
      // iOS: uses navigate endpoint even for markers (original behavior)
      return buildUrl(
        url: 'tomtomgo://x-callback-url/navigate',
        queryParams: {'destination': coords.latlng},
      );
    }
    // Android: geo: intent with optional title
    final titleFormatted = coords.title != null
        ? '(${Uri.encodeComponent(coords.title!)})'
        : '';
    return buildUrl(
      url: 'geo:${coords.latlng}',
      queryParams: {'q': '${coords.latlng}$titleFormatted'},
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
        url: 'tomtomgo://x-callback-url/navigate',
        queryParams: {'destination': destination.latlng},
      );
    }
    // The TomTom Go app cannot handle the ? at the start of the query
    return buildUrl(
      url: 'google.navigation:',
      queryParams: {'q': destination.latlng},
    ).replaceFirst('?', '');
  }
}

/// TomTom Go Fleet. Android only, navigation only.
class TomTomGoFleet extends TomTomGo {
  /// Creates a [TomTomGoFleet].
  const TomTomGoFleet();

  @override
  String get id => 'tomtomgofleet';

  @override
  String get name => 'TomTom Go Fleet';

  @override
  String? get playStoreId => 'com.tomtom.gplay.navapp.gofleet';

  // TomTom Go Fleet is Android-only; null keeps it from inheriting
  // TomTom Go's iOS identifiers (double-reporting on iOS, wrong store link).
  @override
  String? get appStoreId => null;

  @override
  String? get iosScheme => null;

  @override
  Uint8List get iconBytes => tomtomgofleetIcon;
}
