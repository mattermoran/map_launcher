import 'dart:collection';

/// Google Maps-specific URL parameters.
///
/// Use with the `extra` parameter on any request:
/// ```dart
/// MapLauncher.marker(.coords(48.85, 2.29)).show(
///   map: .google,
///   extra: GoogleExtra(queryPlaceId: 'ChIJLU7j...'),
/// );
/// ```
class GoogleExtra extends MapView<String, String> {
  /// Creates Google Maps extra parameters.
  ///
  /// - [queryPlaceId]: Google Place ID for precise location matching.
  /// - [navigate]: Start turn-by-turn navigation immediately.
  /// - [destinationPlaceId]: Place ID for the direction destination.
  /// - [originPlaceId]: Place ID for the direction origin.
  GoogleExtra({
    String? queryPlaceId,
    bool navigate = false,
    String? destinationPlaceId,
    String? originPlaceId,
  }) : super({
         'query_place_id': ?queryPlaceId,
         if (navigate) 'dir_action': 'navigate',
         'destination_place_id': ?destinationPlaceId,
         'origin_place_id': ?originPlaceId,
       });
}
