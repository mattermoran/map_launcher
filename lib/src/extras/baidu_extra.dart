import 'dart:collection';

/// Baidu Maps caller attribution for `extra` or `providerExtras`.
///
/// Works with `map: .baidu`. These options are optional for plugin discovery
/// and launch; they do not certify provider acceptance.
class BaiduExtra extends MapView<String, String> {
  /// Creates Baidu extra parameters.
  ///
  /// [src] is the complete caller attribution: `andr.company.application` on
  /// Android or `ios.company.application` on iOS. This is not an API key.
  /// Unlike `BaiduMaps(source: ...)`, this helper does not add a platform prefix.
  /// Pass the raw value; launch encodes it.
  BaiduExtra({required String src}) : super({'src': src});
}
