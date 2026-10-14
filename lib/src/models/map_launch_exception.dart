/// Why a map request could not be handed off.
enum MapLaunchFailure {
  /// No provider could prepare this request and its configuration.
  noEligibleMap,

  /// Every attempted transport reported a failed handoff.
  exhausted,

  /// The platform blocked launching (for example, a browser popup).
  blocked,

  /// Handoff could not be confirmed; retrying could open a second app.
  unknown,
}

/// Expected provider configuration failure, distinct from a builder bug.
class MapConfigurationError extends ArgumentError {
  /// Describes why this provider cannot prepare the request.
  MapConfigurationError(super.message);
}

/// A platform adapter may throw this only when no handoff occurred.
class MapHandoffException implements Exception {
  /// Set [blocked] for failures where trying another provider cannot help.
  const MapHandoffException(this.message, {this.blocked = false});

  /// Description without sensitive URL contents.
  final String message;

  /// Whether the failure is terminal for this launch call.
  final bool blocked;

  @override
  String toString() => 'MapHandoffException: $message';
}

/// One rejected provider or failed transport. URLs may contain private data.
class MapLaunchIssue {
  /// Records preparation ([url] absent) or a failed handoff.
  const MapLaunchIssue({
    required this.mapId,
    required this.cause,
    this.url,
    this.androidPackageName,
    this.stackTrace,
  });

  /// Provider's stable ID.
  final String mapId;

  /// Original failure; may contain sensitive configuration.
  final Object cause;

  /// Attempted URL, absent for rejected configuration.
  final String? url;

  /// Android package target, absent for unpinned launches.
  final String? androidPackageName;

  /// Original failure stack, when available.
  final StackTrace? stackTrace;
}

/// Thrown when no eligible map can be launched, or a handoff fails.
class MapLaunchException implements Exception {
  /// Creates a [MapLaunchException] with a [message], the [url] that failed,
  /// and an optional [cause].
  const MapLaunchException(
    this.message, {
    this.url,
    this.cause,
    this.reason = MapLaunchFailure.unknown,
    this.issues = const [],
  });

  /// A human-readable description of the failure.
  final String message;

  /// The URL that failed to launch.
  final String? url;

  /// The underlying exception, if any.
  final Exception? cause;

  /// Machine-readable outcome for application error handling.
  final MapLaunchFailure reason;

  /// Ordered preparation and launch failures. Library-created lists are immutable.
  final List<MapLaunchIssue> issues;

  @override
  String toString() => 'MapLaunchException($reason): $message';
}
