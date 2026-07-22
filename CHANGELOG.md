## 5.0.0-dev.1

**Breaking Changes:**

- **New builder-style API**: `MapLauncher.showMarker()` / `MapLauncher.showDirections()` → `MapLauncher.marker(...).show()` / `MapLauncher.directions(...).show()`. Methods on `AvailableMap` are gone too.
- **`AvailableMap` → `SupportedMap`**: No longer carries `mapName` or `icon` — those are now properties on `MapType` itself (`MapType.displayName`, `MapType.icon`). `SupportedMap` only pairs a `MapType` with `isInstalled`.
- **`Coords` → `LocationCoords`**: `Coords(latitude, longitude)` → `.coords(lat, lng, title: '...')`. Title moved from `showMarker()` into the location. `latitude`/`longitude` fields renamed to `lat`/`lng`.
- **`Waypoint` removed**: Use `LocationCoords` directly in the waypoints list.
- **`DirectionsMode` → `TravelMode`**: Same values (driving, walking, transit, bicycling), renamed.
- **`extraParams` → `extra`**: Now accepts typed extras (`GoogleExtra`, `AppleExtra`, etc.) or raw `Map<String, String>`. Passed via `show(extra: ...)` instead of the old method parameter.
- **`MapType` enum values reordered**: `google` is now before `googleGo`. Enum carries `displayName`, `playStoreId`, `appStoreId`, `hasUniversalLink`, `icon`.
- **`MapLauncher.getAvailableMaps()` → `MapLauncher.getAvailableMaps()`**: Same name, but returns `List<SupportedMap>` instead of `List<AvailableMap>`.
- **`isMapAvailable()` removed**: Use `getSupportedMaps()` on a request instead.
- **Minimum SDK**: Dart 3.11+, Flutter 3.3+.

**New Features:**

- **Desktop & web support**: macOS, Windows, Linux, and web platforms via universal links (HTTPS URLs).
- **Scheme-to-universal fallback**: On mobile, if a native app scheme URL fails (app not installed), automatically falls back to the universal HTTPS URL.
- **Search-based markers and directions**: Google and Apple Maps support text queries for both markers and destinations.
- **URL inspection**: `getUrl()`, `getUniversalUrl()`, and `getSchemeUrl()` let you preview URLs without launching.
- **Extras system**: Type-safe, map-specific parameters via `GoogleExtra`, `AppleExtra`, `WazeExtra`, `TencentExtra`, `YandexNaviExtra`.
- **`getSupportedMaps()`**: Per-request map discovery that respects capabilities (marker support, search support, waypoint support).
- **`getAvailableMaps()`**: Platform-wide map discovery returning both installed and universal-link maps.
- **Store URLs on `MapType`**: `appStoreUrl` and `playStoreUrl` getters for linking to app store pages.
- **`MapLaunchException`**: Typed exception with the URL and underlying cause when a launch fails.

**Docs:**

- Added `CONTRIBUTING.md` with step-by-step guide for adding new map providers.

## 4.6.0

- feat: add support for SPEDION Navigation ([#220](https://github.com/mattermoran/map_launcher/pull/220)) (@D3nn7)
- feat: add support for Magic Earth ([#222](https://github.com/mattermoran/map_launcher/pull/222)) (@APopaMagicLane)

## 4.5.0

- feat: add support for Air Navigation Pro ([#219](https://github.com/mattermoran/map_launcher/pull/219)) (@BranislavKljaic96)

## 4.4.3

- fix: gracefully handle invalid urls ([#216](https://github.com/mattermoran/map_launcher/pull/216))

## 4.4.2

- fix: preserve url scheme casing ([#212](https://github.com/mattermoran/map_launcher/pull/212)) (@eryanwcp)

## 4.4.1

- fix: isMapAvailable method regression ([#210](https://github.com/mattermoran/map_launcher/pull/210))

## 4.4.0

- feat: add support for neshan map ([#208](https://github.com/mattermoran/map_launcher/pull/208)) (@AmirJabbari)

## 4.3.0

- feat: add support for moovit map ([#207](https://github.com/mattermoran/map_launcher/pull/207)) (@kfiross)

## 4.2.0

- feat: add waypoints support for yandex maps and yandex navi ([#206](https://github.com/mattermoran/map_launcher/pull/206)) (@ahmetcj4)

## 4.1.0

- Add support for swift package manager and bump min ios to 13 ([#205](https://github.com/mattermoran/map_launcher/pull/205))

## 4.0.2

- Fix parsing available map json ([#204](https://github.com/mattermoran/map_launcher/pull/204))

## 4.0.1

- Fix search param URL encoding ([#201](https://github.com/mattermoran/map_launcher/pull/201))
- Improve public API documentation ([#200](https://github.com/mattermoran/map_launcher/pull/200))

## 4.0.0

- Recreate the plugin with new structure to prepare for multiplatform support
- Bump android min sdk to 21

## 3.5.0

- Add Mappls MapmyIndia (@Ajaay7 & @Saksham66)

## 3.4.0

- Remove support for apps using android v1 embedding

## 3.3.1

- Remove support for Maps.me on android as it stopped working a while ago

## 3.3.0

- Add privacy manifest
- Bump flutter min version to 3.13.0
- Bump dart min version to 3.1.0

## 3.2.0

- Add Mapy.cz (@TheHumr)

## 3.1.0

- Add Naver Map, KakaoMap and TMAP (@trentcharlie & @JulyWitch)
- Add support for AGP 7.4.2 and up (@bitsydarel)

## 3.0.1

- Rename Sygic to Sygic Truck
- Remove deprecated `launchMap` method. use `showMarker` instead

## 3.0.0

BREAKING: waypoints parameter now uses `List<Waypoint>` instead of `List<Coord>``

- Add CoPilot map (@tjeffree)
- Add Go Fleet and Sygic Truck maps (@amrahmed242)
- Add Flitsmeister and Truckmeister (@robinbonnes & @frankvollebregt)
- Add waypoint labels for Apple Maps (@manafire)
- Add support for gradle 8 (@m-derakhshi)
- Fix future not completing on iOS

## 2.5.0+1

- Update screenshots

## 2.5.0

- Add support for waypoints on Apple Maps

## 2.4.0

- Bump kotlin version to 1.5.31

## 2.3.0+1

- Cleanup

## 2.3.0

- Add TomTom Go #125 (@frankvollebregt)

## 2.2.3

- Fix empty title in Google Maps

## 2.2.2

- Fix `originTitle` on `showDirections` method

## 2.2.1+2

- Add dartdoc comments
- Update `directions_url.dart` formatting
- Update broken link in the README

## 2.2.1+1

- Update README with information that title should now work in Google Maps for Android starting from v11.12

## 2.2.1

- Update Petal maps icon

## 2.2.0

- Add Petal maps #103 (@mericgerceker)

## 2.1.2

- Replace jcenter with mavenCentral #100

## 2.1.1

- Fix iOS crash when using unsupported MapTypes #83 (@bridystone)

## 2.1.0

- Add OSMAnd+ #82 (@bridystone)
- Add Here WeGo #77 (@aleksandr-m)
- Add zoom level for OSMAnd on iOS #79 (@bridystone)
- Fix deprecation compiler warning in Xcode #78 (@bridystone)
- Bump minimum iOS version to 10

## 2.0.0+1

- Fix formatting

## 2.0.0

- Stable null safety

## 2.0.0-nullsafety.0

- Migrate to null safety
- Thanks to @LDevineau-eVtech

## 1.1.3+1

- Add warning for v1.1.3

## 1.1.3

Breaking change! See [here](https://github.com/mattermoran/map_launcher/issues/60#issuecomment-771388357) for migration

- Fix Android 11 not showing installed maps #58
- Thanks to @BasPhair, @olsisaqe

## 1.1.2

- Fix Tencent Maps and 2GIS url scheme on ios #56

## 1.1.1

- Add `extraParams` option to support passing additional query parameters that might be needed like api keys etc

## 1.1.0

- Add support for Tencent (QQ Maps)

## 1.0.0

- BREAKING CHANGE: not depending on flutter_svg anymore. See README for migration
- Add support for Google Maps GO
- Under the hood changes
- Thanks to @andoni97, @Pavel-Sulimau, @grinder15 for contribution

## 0.12.2

- Add import fallback for `#import <map_launcher/map_launcher-Swift.h>`
- Thanks to @fisherjoe

## 0.12.1

- Fix default zoom level

## 0.12.0

- Add support for 2GIS

## 0.11.0

- Add waypoints for Google Maps

## 0.10.0

- Add zoom parameter

## 0.9.0

- Add showDirections method
- Update example app

## 0.8.2

- Update flutter_svg constraint </br>
  Thanks to @tuarrep and @jcsena

## 0.8.1

- Fix #31 </br>
  Thanks to @LeonidVeremchuk

## 0.8.0

- Add support for android embedding v2

## 0.7.1

- Add constraint for flutter_svg

## 0.7.0

- Replace png icons with svgs </br>
  Thanks to @shinsenter

## 0.6.0

- Add support for Maps.Me and OsmAnd </br>
  Thanks to @gsi-yoan and @gsi-alejandrogomez

## 0.5.0

- Add support for Citymapper </br>
  Thanks to @Kiruel

## 0.4.5

- Fix Google Maps title issue on iOS </br>
  Thanks to @illiashvedov

## 0.4.4

- Specify swift version in map_launcher.podspec file

## 0.4.3

- Add license

## 0.4.2

- Add code to show title in Google Maps for Android. Should work once fixed in Google Maps. Update README.

## 0.4.1

- Update README file. Remove author field from pubspec.yaml

## 0.4.0

- Added support for Yandex Maps and Yandex Navigator </br>
  Updated icons

## 0.3.2

- Fixes #1 'MKCoordinateRegionMake' is unavailable in Swift </br>
  Thanks to @diegogarciar

## 0.3.1

- Throw a PlatformException if map is not installed

## 0.3.0

- Added Waze support

## 0.2.0

- Added method to check if map is available

## 0.1.3

- Added icons for maps
- Added iOS gif to README

## 0.1.2

- Migrate to AndroidX

## 0.1.1

- Update description in pubspec.yaml

## 0.1.0

- Get available maps on iOS and Android
- Launch maps with a marker
