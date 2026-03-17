import 'dart:collection';

/// Tencent (QQ Maps)-specific URL parameters.
///
/// Use with the `extra` parameter on any request:
/// ```dart
/// MapLauncher.marker(.coords(39.9, 116.4)).show(
///   map: .tencent,
///   extra: TencentExtra(referer: 'your-app-key'),
/// );
/// ```
class TencentExtra extends MapView<String, String> {
  /// Creates Tencent extra parameters.
  ///
  /// - [referer]: Your registered app key for the Tencent Maps API.
  TencentExtra({required String referer}) : super({'referer': referer});
}
