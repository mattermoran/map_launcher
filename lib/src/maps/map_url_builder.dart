import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/travel_mode.dart';

/// Base class for per-map URL building strategies.
///
/// Each map type has its own subclass that knows how to construct
/// universal links (HTTPS) and optionally URL scheme links.
///
/// This class is internal — users interact with [MapLauncher],
/// [MarkerRequest], and [DirectionsRequest] instead.
abstract class MapUrlBuilder {
  /// Creates a [MapUrlBuilder].
  const MapUrlBuilder();

  /// The map type this strategy handles.
  MapType get mapType;

  /// Builds a universal link (HTTPS) for showing a marker.
  ///
  /// Returns `null` if not supported.
  String? markerUrl(LocationCoords coords, {int? zoom});

  /// Builds a universal link (HTTPS) for showing a marker via text search.
  ///
  /// Returns `null` if not supported.
  String? markerSearchUrl(String query) => null;

  /// Builds a universal link (HTTPS) for showing directions.
  ///
  /// Returns `null` if not supported.
  String? directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  });

  /// Builds a universal link (HTTPS) for showing directions via text search.
  ///
  /// Returns `null` if not supported.
  String? directionsSearchUrl(
    String query, {
    LocationCoords? origin,
    TravelMode? travelMode,
  }) => null;

  /// Builds a URL scheme link for showing a marker (mobile-only).
  ///
  /// Returns `null` if no scheme-based URL is available.
  String? markerSchemeUrl(
    LocationCoords coords, {
    int? zoom,
    required MapPlatform platform,
  }) => null;

  /// Builds a URL scheme link for showing a marker via text search (mobile-only).
  ///
  /// Returns `null` if not supported.
  String? markerSchemeSearchUrl(
    String query, {
    required MapPlatform platform,
  }) => null;

  /// Builds a URL scheme link for showing directions (mobile-only).
  ///
  /// Returns `null` if no scheme-based URL is available.
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => null;

  /// Builds a URL scheme link for directions via text search (mobile-only).
  ///
  /// Returns `null` if not supported.
  String? directionsSchemeSearchUrl(
    String query, {
    LocationCoords? origin,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => null;

  /// Whether this map supports markers via coordinates.
  bool get supportsMarkerCoords => true;

  /// Whether this map supports markers via text search query.
  bool get supportsMarkerSearch => false;

  /// Whether this map supports directions via coordinates.
  bool get supportsDirectionsCoords => true;

  /// Whether this map supports directions via text search query.
  bool get supportsDirectionsSearch => false;

  /// Whether this map supports waypoints in directions.
  bool get supportsWaypoints => false;

  /// Whether this map supports the given [mode] for directions.
  bool supportsTravelMode(TravelMode mode) => true;

  /// Returns the best URL for a marker.
  ///
  /// When [platform] is non-null (mobile): prefers scheme (native app),
  /// falls back to universal. When `null` (web/desktop): uses universal only.
  String? bestMarkerUrl(Location location, {int? zoom, MapPlatform? platform}) {
    return switch (location) {
      LocationCoords coords => () {
        if (platform != null) {
          final scheme = markerSchemeUrl(
            coords,
            zoom: zoom,
            platform: platform,
          );
          if (scheme != null) return scheme;
        }
        return markerUrl(coords, zoom: zoom);
      }(),
      LocationSearch search => () {
        if (platform != null) {
          final scheme = markerSchemeSearchUrl(
            search.query,
            platform: platform,
          );
          if (scheme != null) return scheme;
        }
        return markerSearchUrl(search.query);
      }(),
    };
  }

  /// Returns the best URL for directions.
  ///
  /// When [platform] is non-null (mobile): prefers scheme (native app),
  /// falls back to universal. When `null` (web/desktop): uses universal only.
  String? bestDirectionsUrl({
    required Location destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    MapPlatform? platform,
  }) {
    return switch (destination) {
      LocationCoords coords => () {
        if (platform != null) {
          final scheme = directionsSchemeUrl(
            destination: coords,
            origin: origin,
            waypoints: waypoints,
            travelMode: travelMode,
            platform: platform,
          );
          if (scheme != null) return scheme;
        }
        return directionsUrl(
          destination: coords,
          origin: origin,
          waypoints: waypoints,
          travelMode: travelMode,
        );
      }(),
      LocationSearch search => () {
        if (platform != null) {
          final scheme = directionsSchemeSearchUrl(
            search.query,
            origin: origin,
            travelMode: travelMode,
            platform: platform,
          );
          if (scheme != null) return scheme;
        }
        return directionsSearchUrl(
          search.query,
          origin: origin,
          travelMode: travelMode,
        );
      }(),
    };
  }
}
