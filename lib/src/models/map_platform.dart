/// The platform the app is running on, used for selecting URL schemes.
///
/// On mobile, maps may use different URL schemes per platform
/// (e.g. `comgooglemaps://` on iOS vs `geo:` on Android).
///
/// `null` represents web/desktop where scheme URLs don't work.
enum MapPlatform {
  /// iOS. Uses iOS-specific URL schemes.
  ios,

  /// Android. Uses Android-specific URL schemes.
  android,
}
