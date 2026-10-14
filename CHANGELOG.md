## 7.0.0

Version 7 makes provider selection explicit, validates requests before launch,
and limits retries to confirmed failed handoffs. See the
[6 → 7 migration guide](MIGRATION.md#6x--70) before upgrading.

### Breaking changes

- **Provider lists and native discovery:** remove `MapApp.all`. Pass your own
  list to discovery and declare the selected Android packages in your app's
  `<queries>`; the library no longer bundles them. iOS query declarations remain
  app-owned. Bare `show()` still uses Apple/Google defaults.
- **Discovery results:** `getAvailableMaps()` now returns metadata-only
  `AvailableMap` entries. Request discovery returns `SupportedMap` entries with
  prepared options and parameterless `show()`; configure extras before discovery.
  The unnamed `SupportedMap` constructor is removed. Entries now use identity
  equality, so retain provider IDs rather than entries across discovery refreshes.
- **Extra parameters:** nonempty raw `extra` requires explicit `show(map: ...)`.
  Use `providerExtras` for automatic selection or discovery. Extras that conflict
  with generated URL parameters are rejected rather than appended as duplicates.
- **Immutable requests:** extras and waypoints are copied into unmodifiable
  snapshots. Request constructors are no longer `const`.
- **Launch failures and retries:** unsupported explicit launches now throw
  `MapLaunchException` instead of `UnsupportedError`, and its `url` is nullable.
  Retries require confirmation that no handoff occurred; blocked or unknown
  outcomes stop immediately. Custom platform adapters must use
  `MapHandoffException` to identify confirmed failed handoffs.
- **Request support:** reject unsupported origins, modes, marker actions and
  stops instead of silently dropping them. This includes Apple legacy cycling
  links, non-driving Sygic Truck requests, MAPS.ME routes without an origin,
  Baidu Android routes without an origin, TomTom iOS markers, Fleet iOS
  directions and Air Navigation Pro markers. Search destinations cannot have
  waypoints; use coordinates instead.
- **Google URL limits:** enforce the 2,048-character HTTPS limit and allow up to
  nine intermediate stops for Android package-targeted or desktop launches,
  three for mobile unpinned HTTPS. Over-limit transports are excluded, not
  truncated, including browser fallbacks.
- **Input validation:** reject non-finite coordinates and blank search queries.
- **Minimum Flutter version:** correct the declared minimum from 3.3 to 3.41
  to match the existing Dart 3.11 requirement.

### Added

- Add provider-scoped `providerExtras` to requests and factories. Options are
  matched by provider ID and copied into immutable snapshots.
- Add `NaverExtra(appName: ...)` and `BaiduExtra(src: ...)` for use with shorthand
  providers, plus optional `NaverMap(appName: ...)` and `BaiduMaps(source: ...)`
  configuration. Naver/Baidu caller attribution and Tencent's existing `referer`
  option remain optional for plugin discovery and launch; provider acceptance
  is not guaranteed.
- Add `MapLaunchException.reason` and ordered `issues` for inspecting launch
  failures. Add provider validation hooks using `MapConfigurationError` for
  expected configuration rejections.
- Let custom providers define text-origin parameter names independently of
  their IDs.

### Fixed

- Prepare requests consistently for discovery and launch. Exclude providers
  with unsupported operations or rejected configuration, including custom maps
  whose universal links cannot fulfill the request. URL getters remain base
  URLs without extras or launch validation.
- Try Apple then Google on iOS, Google then Apple elsewhere for automatic
  launches, without awaiting installation detection. Explicit selection and
  picker entries never switch providers. Android HTTPS fallbacks remove the
  package target, even when retrying the same URL.
- Preserve existing URL bytes when appending extras, keep identical built-in
  parameters once, and handle opaque navigation URLs correctly.
- Correct route and marker URLs for Amap, HERE, Kakao, MAPS.ME, Mapy, Mappls,
  OsmAnd and Neshan. Preserve spaces and literal plus signs in MAPS.ME labels
  for the referenced receiver's percent-only decoder.
- Preserve Google Maps text origins in iOS URLs. Select HTTPS for universal-only
  extras, validate their companion fields, and omit unsupported marker zoom.
- Preserve the empty origin slot in Yandex Maps route URLs so the first waypoint
  is not serialized as the origin ([#228](https://github.com/mattermoran/map_launcher/issues/228)).
  Current-location routing with waypoints still needs native-app verification.
- Send latitude and longitude fields for CoPilot markers, use coordinates for
  blank Naver marker names, and correct Petal's bicycling mode and label encoding.
- Preserve caller-supplied Baidu marker descriptions and named origins. Apply
  iOS defaults only for absent options and validate origins after extras merge.
- Correct Air Navigation Pro and Magic Earth App Store links and icon lookup IDs.
- Restore Android build compatibility with Flutter 3.41 / AGP 8 while retaining
  AGP 9 support ([#227](https://github.com/mattermoran/map_launcher/issues/227)).
- Pass Windows URLs as encoded PowerShell data rather than interpolating them
  into `cmd`, preserving query separators and preventing shell expansion.
- Report blocked browser popups and wrap platform launch failures in
  `MapLaunchException`.
- Bundle the iOS privacy manifest through CocoaPods and Swift Package Manager.
- Validate example inputs, discard stale discovery results after parameter
  changes, and make discovery and launch failures recoverable. Allow an omitted
  origin and provider-default travel mode so origin-/mode-limited maps are usable.

### Deprecated

- Deprecate `opensNatively` and `opensInBrowser`. Use `isInstalled` and
  `hasUniversalLink` as availability hints, not guarantees of which app the OS
  will open.

### Tooling and documentation

- Update development and example tooling to Flutter 3.47.6 / Dart 3.13.5,
  AGP 9.1.0, Kotlin 2.4.0 and Gradle 9.3.1. Set example deployment targets to
  iOS 15 / macOS 12 and retain CI coverage for Flutter 3.41 / AGP 8.
- Add [provider references](docs/maps/README.md) with source links, supported
  parameters and known uncertainties for existing integrations and requested
  maps from [#111](https://github.com/mattermoran/map_launcher/issues/111).
  Research entries do not imply new built-in providers.
- Document v7 migration, platform defaults and the distinction between Dart
  tree shaking and app-owned native declarations. Neither tree shaking nor
  archive inspection guarantees store approval.
- Fix cached icon fetching, support ImageMagick outside macOS, and report
  icon-generation failures.

## 6.0.0

Add your own map apps, ship only the maps you use, and launch them in one line.

Maps are now `MapApp` objects instead of enum values. **Subclass `MapApp`** to
add any map app without forking the plugin. **Only the maps you reference are
retained in Dart release code**; native manifest entries are separate.
And discovery results are **directly launchable**:
`maps.first.show()`.

See [MIGRATION.md](https://github.com/mattermoran/map_launcher/blob/master/MIGRATION.md) for the full 5.x → 6.0 guide.

**New Features:**

- **Custom maps**: subclass `MapApp` to add any map app (regional, proprietary,
  internal) without forking the plugin. Works everywhere a built-in map does,
  including discovery and launching.
- **Tree-shakeable maps**: referencing `MapApp.waze` compiles in only Waze's
  Dart code, strings, and icon. Unreferenced maps are stripped from Dart AOT
  snapshots, not from native manifests. Bare `show()` also retains its defaults.
- **Launchable discovery results**: `final maps = await request.getSupportedMaps([...])`
  then `maps.first.show()`. No more request/mapType plumbing in pickers.
- **Misconfiguration warning (iOS)**: debug builds print a warning when a map
  passed to discovery is missing from `LSApplicationQueriesSchemes`, naming
  the exact scheme to add. Previously indistinguishable from "not installed".
- **Official app icons**: 256×256 PNG icons sourced from iTunes and Google Play
  Store APIs, embedded as `Uint8List`. No `flutter_svg` dependency needed.
  Run `dart run tool/fetch_icons.dart` to refresh.
- **Generic native layer**: iOS/Android detection is driven entirely from
  Dart. The Android manifest still declares map-specific package queries.

**Breaking Changes:**

- **`MapType` enum → `MapApp` objects**: `MapType.google` → `MapApp.google`.
  Dot-shorthand call sites like `show(map: .google)` compile unchanged.
- **Discovery takes an explicit list**: `getSupportedMaps()` →
  `getSupportedMaps([.apple, .google, .waze])`, `getAvailableMaps()` →
  `getAvailableMaps(myMaps)`. Use `MapApp.all` for every supported map (this
  opts out of tree shaking).
- **Icons are PNG bytes, not SVG assets**: `SvgPicture.asset(map.icon)` →
  `Image.memory(map.iconBytes)`. No extra dependencies needed. `flutter_svg`
  is no longer required.
- **`SupportedMap`**: `map.mapType` → `map.map` (a `MapApp`),
  `map.displayName` → `map.name`. Entries returned by a request are directly
  launchable via `map.show()`.
- **Persisted map names**: `MapType.values.byName(saved)` →
  `myMaps.firstWhere((m) => m.id == saved)`. `MapApp.id` matches the old
  enum names, so stored preferences keep working.
- **Removed maps**: `truckmeister` (discontinued by Flitsmeister) and
  `spedionNavigation` (integrated module in the SPEDION fleet app, not a
  standalone map) have been removed. Use the custom `MapApp` subclass feature
  to add them back if needed.

## 5.0.1

- fix: remove `dart:io` from web import

## 5.0.0

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

**Breaking Changes:**

- **New builder-style API**: `MapLauncher.showMarker()` / `MapLauncher.showDirections()` → `MapLauncher.marker(...).show()` / `MapLauncher.directions(...).show()`. Methods on `AvailableMap` are gone too.
- **`AvailableMap` → `SupportedMap`**: No longer carries `mapName` or `icon`. Those are now properties on `MapType` itself (`MapType.displayName`, `MapType.icon`). `SupportedMap` only pairs a `MapType` with `isInstalled`.
- **`Coords` → `LocationCoords`**: `Coords(latitude, longitude)` → `.coords(lat, lng, title: '...')`. Title moved from `showMarker()` into the location. `latitude`/`longitude` fields renamed to `lat`/`lng`.
- **`Waypoint` removed**: Use `LocationCoords` directly in the waypoints list.
- **`DirectionsMode` → `TravelMode`**: Same values (driving, walking, transit, bicycling), renamed.
- **`extraParams` → `extra`**: Now accepts typed extras (`GoogleExtra`, `AppleExtra`, etc.) or raw `Map<String, String>`. Passed via `show(extra: ...)` instead of the old method parameter.
- **`MapType` enum values reordered**: `google` is now before `googleGo`. Enum carries `displayName`, `playStoreId`, `appStoreId`, `hasUniversalLink`, `icon`.
- **`MapLauncher.getAvailableMaps()` → `MapLauncher.getAvailableMaps()`**: Same name, but returns `List<SupportedMap>` instead of `List<AvailableMap>`.
- **`isMapAvailable()` removed**: Use `getSupportedMaps()` on a request instead.
- **Minimum SDK**: Dart 3.11+, Flutter 3.3+.

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
