import 'dart:collection';

/// Naver Map caller identity for `extra` or `providerExtras`.
///
/// Works with `map: .naver`; no custom `NaverMap` instance is needed.
/// These options are optional for plugin discovery and launch.
class NaverExtra extends MapView<String, String> {
  /// Creates Naver extra parameters.
  ///
  /// [appName] is the caller's Android application ID, iOS bundle ID, or mobile
  /// web page URL, not an API key. Pass the raw value; launch encodes it.
  NaverExtra({required String appName}) : super({'appname': appName});
}
