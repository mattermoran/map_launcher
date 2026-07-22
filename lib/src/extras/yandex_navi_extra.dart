import 'dart:collection';

/// Yandex Navigator-specific URL parameters.
///
/// Use with the `extra` parameter on any request:
/// ```dart
/// MapLauncher.directions(.coords(55.75, 37.62)).show(
///   map: .yandexNavi,
///   extra: YandexNaviExtra(client: 'your-client-id', signature: 'your-sig'),
/// );
/// ```
class YandexNaviExtra extends MapView<String, String> {
  /// Creates Yandex Navigator extra parameters.
  ///
  /// - [client]: Your registered Yandex client identifier.
  /// - [signature]: Request signature for authentication.
  YandexNaviExtra({String? client, String? signature})
    : super({'client': ?client, 'signature': ?signature});
}
