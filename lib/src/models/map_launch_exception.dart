/// Thrown when launching a map URL fails.
class MapLaunchException implements Exception {
  /// Creates a [MapLaunchException] with a [message], the [url] that failed,
  /// and an optional [cause].
  const MapLaunchException(this.message, {required this.url, this.cause});

  /// A human-readable description of the failure.
  final String message;

  /// The URL that failed to launch.
  final String url;

  /// The underlying exception, if any.
  final Exception? cause;

  @override
  String toString() => 'MapLaunchException: $message (url: $url)';
}
