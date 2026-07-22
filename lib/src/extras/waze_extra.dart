import 'dart:collection';

/// Waze-specific URL parameters.
///
/// Waze is navigation-focused with few extra parameters.
/// Use with the `extra` parameter on any request:
/// ```dart
/// MapLauncher.directions(.coords(48.85, 2.29)).show(
///   map: .waze,
///   extra: WazeExtra(navigate: true),
/// );
/// ```
class WazeExtra extends MapView<String, String> {
  /// Creates Waze extra parameters.
  ///
  /// - [navigate]: Start navigation immediately.
  WazeExtra({bool navigate = false}) : super({if (navigate) 'navigate': 'yes'});
}
