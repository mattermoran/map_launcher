import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/models/map_launch_exception.dart';

import 'package:map_launcher/map_launcher_platform_interface.dart';

/// Appends [extraParams] to [url] as query parameters.
///
/// Uses [Uri] for proper encoding, then appends to the URL as a string.
/// Works uniformly for all URL types (HTTP, custom schemes, geo:, etc.).
/// Correctly handles URLs with fragments (#) by inserting params before them.
/// Returns [url] unchanged if [extraParams] is null or empty.
/// Identical existing parameters are kept once. Conflicting extras throw
/// [ArgumentError] instead of creating an ambiguous duplicate key.
/// Existing bytes are never re-encoded (important for signed URLs).
String appendQueryParams(String url, Map<String, String>? extraParams) {
  if (extraParams == null || extraParams.isEmpty) return url;

  // Separate fragment if present. Params must go before it.
  final fragmentIndex = url.indexOf('#');
  final baseUrl = fragmentIndex >= 0 ? url.substring(0, fragmentIndex) : url;
  final fragment = fragmentIndex >= 0 ? url.substring(fragmentIndex) : '';

  // Google's navigation intent puts its parameters directly after the colon.
  final opaqueNavigation =
      baseUrl.startsWith('google.navigation:') && !baseUrl.contains('?');
  final queryIndex = opaqueNavigation
      ? baseUrl.indexOf(':')
      : baseUrl.indexOf('?');
  final additions = Map<String, String>.of(extraParams);
  if (queryIndex >= 0) {
    final query = baseUrl.substring(queryIndex + 1);
    final existing = Uri(query: query).queryParametersAll;
    for (final entry in extraParams.entries) {
      final values = existing[entry.key];
      if (values != null) {
        if (values.length != 1 || values.single != entry.value) {
          throw MapConfigurationError(
            'Extra parameter "${entry.key}" conflicts with a URL parameter.',
          );
        }
        additions.remove(entry.key);
      }
    }
  }
  if (additions.isEmpty) return url;

  // Use Uri to get properly encoded query string.
  final queryString = Uri(queryParameters: additions).query;
  final separator = queryIndex >= 0 ? '&' : '?';
  return '$baseUrl$separator$queryString$fragment';
}

/// A request's validated transports, in preference order.
class PreparedMapLaunch {
  /// Captures immutable attempts and the platform that prepared them.
  PreparedMapLaunch(
    this.map,
    this.platform,
    Iterable<({String url, String? package})> attempts,
  ) : attempts = List.unmodifiable(attempts);

  /// The configured provider, not an ID-based reconstruction.
  final MapApp map;

  /// Platform adapter used for this prepared request.
  final MapLauncherPlatform platform;

  /// Validated URLs and targets, in preference order.
  final List<({String url, String? package})> attempts;

  /// Whether discovery can offer this request without native installation.
  bool get hasUniversalAttempt => attempts.any(
    (a) => a.package == null && Uri.parse(a.url).scheme == 'https',
  );

  /// Stops after the first accepted handoff or an indeterminate failure.
  Future<void> show() async {
    final issues = <MapLaunchIssue>[];
    for (final attempt in attempts) {
      try {
        await platform.launch(attempt.url, androidPackageName: attempt.package);
        return;
      } on Exception catch (error, stack) {
        issues.add(
          MapLaunchIssue(
            mapId: map.id,
            cause: error,
            url: attempt.url,
            androidPackageName: attempt.package,
            stackTrace: stack,
          ),
        );
        final reason = error is MapHandoffException
            ? (error.blocked
                  ? MapLaunchFailure.blocked
                  : MapLaunchFailure.exhausted)
            : MapLaunchFailure.unknown;
        if (reason != MapLaunchFailure.exhausted || attempt == attempts.last) {
          throw MapLaunchException(
            'Could not open ${map.name}.',
            reason: reason,
            url: attempt.url,
            cause: error,
            issues: List.unmodifiable(issues),
          );
        }
      }
    }
  }
}

/// Prepares all transports before any external side effect.
PreparedMapLaunch prepareMapLaunch({
  required MapApp map,
  required String? url,
  required String? universalUrl,
  Map<String, String>? extra,
}) {
  final platform = MapLauncherPlatform.instance;
  final packageName = platform.platform == .android ? map.playStoreId : null;
  final useUniversal = map.requiresUniversalUrl(extra ?? const {});
  if (url == null || (useUniversal && universalUrl == null)) {
    throw MapConfigurationError('${map.name} does not support this request.');
  }
  final primaryUrl = appendQueryParams(
    useUniversal ? universalUrl! : url,
    extra,
  );
  map.validateLaunchUrl(primaryUrl);
  final fallbackUrl = universalUrl == null
      ? null
      : appendQueryParams(universalUrl, extra);
  if (fallbackUrl != null) map.validateLaunchUrl(fallbackUrl);
  final candidates = {
    (url: primaryUrl, package: packageName),
    if (fallbackUrl != null) (url: fallbackUrl, package: null),
  };
  final attempts = <({String url, String? package})>[];
  MapConfigurationError? rejection;
  for (final candidate in candidates) {
    try {
      map.validateLaunchTransport(
        candidate.url,
        platform: platform.platform,
        packageTargeted: candidate.package != null,
      );
      attempts.add(candidate);
    } on MapConfigurationError catch (error) {
      rejection = error;
    }
  }
  if (attempts.isEmpty) throw rejection!;
  return PreparedMapLaunch(map, platform, attempts);
}

/// Explicit-provider helper; never switches providers.
Future<void> launchMapUrl({
  required MapApp map,
  required String url,
  required String? universalUrl,
  Map<String, String>? extra,
}) => prepareMapLaunch(
  map: map,
  url: url,
  universalUrl: universalUrl,
  extra: extra,
).show();

/// Executes candidates sequentially, without waiting for installation discovery.
Future<void> showMapRequest({
  MapApp? map,
  required PreparedMapLaunch Function(MapApp) prepare,
}) async {
  final issues = <MapLaunchIssue>[];
  MapLaunchException? lastFailure;
  for (final candidate in map == null ? defaultMaps : [map]) {
    final PreparedMapLaunch launch;
    try {
      launch = prepare(candidate);
    } on MapConfigurationError catch (error, stack) {
      issues.add(
        MapLaunchIssue(mapId: candidate.id, cause: error, stackTrace: stack),
      );
      continue;
    }
    try {
      await launch.show();
      return;
    } on MapLaunchException catch (error) {
      lastFailure = error;
      issues.addAll(error.issues);
      if (error.reason != MapLaunchFailure.exhausted) {
        throw MapLaunchException(
          error.message,
          reason: error.reason,
          url: error.url,
          cause: error.cause,
          issues: List.unmodifiable(issues),
        );
      }
    }
  }
  throw MapLaunchException(
    'No map could fulfill this request.',
    reason: lastFailure == null
        ? MapLaunchFailure.noEligibleMap
        : MapLaunchFailure.exhausted,
    issues: List.unmodifiable(issues),
    url: lastFailure?.url,
    cause: lastFailure?.cause,
  );
}

/// Copies provider-owned options without retaining caller-owned collections.
Map<MapApp, Map<String, String>> snapshotProviderExtras(
  Map<MapApp, Map<String, String>> extras,
) {
  if (extras.keys.map((m) => m.id).toSet().length != extras.length) {
    throw ArgumentError('Supply options once per provider ID.');
  }
  return Map.unmodifiable(
    extras.map(
      (map, values) => MapEntry(map, Map<String, String>.unmodifiable(values)),
    ),
  );
}

/// Selects only options explicitly bound to this provider ID.
Map<String, String> providerOptions(
  MapApp map,
  Map<MapApp, Map<String, String>> extras,
) =>
    extras.entries.where((e) => e.key.id == map.id).firstOrNull?.value ??
    const {};

/// Rejects ambiguous options before automatic selection or discovery.
void requireScopedExtras(Map<String, String>? extra) {
  if (extra?.isNotEmpty == true) {
    throw ArgumentError(
      'Unscoped extra requires show(map: ...). Use providerExtras for automatic selection or discovery.',
    );
  }
}

/// Returns the list of default maps used by bare `show()` calls.
List<MapApp> get defaultMaps => MapLauncherPlatform.instance.platform == .ios
    ? const [.apple, .google]
    : const [.google, .apple];
