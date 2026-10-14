# Map Launcher

![Illustrated map apps connected by routes](screenshots/banner.webp)

[![pub package](https://img.shields.io/pub/v/map_launcher)](https://pub.dev/packages/map_launcher)
[![likes](https://img.shields.io/pub/likes/map_launcher)](https://pub.dev/packages/map_launcher/score)
![Pub Monthly Downloads](https://img.shields.io/pub/dm/map_launcher)
[![pub points](https://img.shields.io/pub/points/map_launcher)](https://pub.dev/packages/map_launcher/score)
[![GitHub stars](https://img.shields.io/github/stars/mattermoran/map_launcher?logo=github)](https://github.com/mattermoran/map_launcher/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/mattermoran/map_launcher?logo=github)](https://github.com/mattermoran/map_launcher/network)

Map Launcher is a Flutter plugin to open maps on **all platforms**: iOS, Android, web, and desktop. Show markers, get directions, or search across 30 supported maps.

Uses universal links (HTTPS URLs), with native app detection on mobile.

Map implementations and icons are tree-shakeable in Dart release builds. Native discovery declarations are separate and belong to your app. See [Binary Size & Native Declarations](#binary-size--native-declarations).

|                                Marker                                 |                                Navigation                                 |
| :-------------------------------------------------------------------: | :-----------------------------------------------------------------------: |
| ![Marker](https://media.giphy.com/media/YNE1A6jrQQx4fArqKb/giphy.gif) | ![Navigation](https://media.giphy.com/media/gKIAdlbEzTDl6n7IOS/giphy.gif) |

### Supported Maps

See the [map references](doc/maps/README.md) for per-map documentation
links, detailed parameter references, platform differences, and known gaps.

| Map                                                                                                                                 | Marker | Search | Directions | Origin | Travel Mode | Waypoints | Platform |
| ----------------------------------------------------------------------------------------------------------------------------------- | :----: | :----: | :--------: | :----: | :---------: | :-------: | -------- |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/google.png" width="20"> Google Maps                   |   ✓    |   ✓    |     ✓      |   ✓    |      ✓      |     ✓     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/apple.png" width="20"> Apple Maps                     |   ✓    |   ✓    |     ✓      |   ✓    | No cycling  |     —     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/waze.png" width="20"> Waze                            |   —    |   —    |     ✓      |   —    | Driving     |     —     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/yandexMaps.png" width="20"> Yandex Maps               |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     ✓     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/doubleGis.png" width="20"> 2GIS                       |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/here.png" width="20"> HERE WeGo                       |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/mapyCz.png" width="20"> Mapy.cz                       |   ✓    |   —    |     ✓      |   ✓    | No transit  |     —     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/mappls.png" width="20"> Mappls                        |   ✓    |   —    |     ✓      |   —    | No transit  |     —     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/baidu.png" width="20"> Baidu Maps                     |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/amap.png" width="20"> Amap                            |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/tencent.png" width="20"> Tencent (QQ)                 |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/yandexNavi.png" width="20"> Yandex Navi               |   ✓    |   —    |     ✓      |   ✓    | Driving     |     ✓     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/googleGo.png" width="20"> Google Maps Go                |   ✓    |   —    |     ✓      |   —    |      ✓      |     —     | Android  |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/naver.png" width="20"> Naver Map                      |   ✓    |   —    |     ✓      |   ✓    | Driving     |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/kakao.png" width="20"> Kakao Maps                     |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/tmap.png" width="20"> TMap                            |   ✓    |   —    |     ✓      |   ✓    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/osmand.png" width="20"> OsmAnd                        |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     ✓     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/osmandplus.png" width="20"> OsmAnd+                   |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     ✓     | Android  |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/petal.png" width="20"> Petal Maps                     |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | Android  |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/mapswithme.png" width="20"> MAPS.ME                   |   ✓    |   —    |     ✓      | Required |    ✓      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/neshan.png" width="20"> Neshan                        |   ✓    |   —    |     ✓      |   ✓    | iOS all; Android driving | — | Mobile |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/copilot.png" width="20"> CoPilot                      |   ✓    |   —    |     ✓      |   —    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/moovit.png" width="20"> Moovit                        |   —    |   —    |     ✓      |   ✓    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/citymapper.png" width="20"> Citymapper                |   —    |   —    |     ✓      |   ✓    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/tomtomgo.png" width="20"> TomTom Go                   | Android |   —    |     ✓      |   —    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/tomtomgofleet.png" width="20"> TomTom Go Fleet        |   ✓    |   —    |     ✓      |   —    |      —      |     —     | Android  |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/sygicTruck.png" width="20"> Sygic Truck               |   —    |   —    |     ✓      |   —    | Driving     |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/flitsmeister.png" width="20"> Flitsmeister            |   —    |   —    |     ✓      |   —    |      —      |     —     | Android  |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/airnavPro.png" width="20"> Air Nav Pro                |   —    |   —    |     —      |   —    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/magicEarth.png" width="20"> Magic Earth               |   ✓    |   —    |     ✓      |   —    |      ✓      |     —     | Mobile   |

**Platform:** **All** = universal links (iOS, Android, web, desktop) • **Mobile** = native app (iOS + Android) • **Android** = Android only

The table describes implemented request support, not verified native behavior.
Travel Mode **✓** means all four enum modes are serialized; **—** means no
explicit mode selection (mode-free directions may still work). Origin means an
explicit coordinate origin. Baidu Android requires one; iOS uses its documented
current-location token when omitted. Naver, Baidu and Tencent document caller
options (see [Extras](#extras)); missing options do not block discovery or launch
in this plugin, but provider acceptance is not guaranteed. Go grammar/transit/companion
behavior, Mappls bicycle meaning, Flitsmeister geo navigation, Yandex omitted
origin with stops/native cycling and 2GIS legacy bicycle remain unverified.

## Table of Contents

- [Quick Start](#quick-start)
- [Setup](#setup)
- [API](#api)
  - [Markers](#markers)
  - [Directions](#directions)
  - [Choosing a Map](#choosing-a-map)
  - [Discovering Maps](#discovering-maps)
  - [URL Inspection](#url-inspection)
  - [Map Info & Store Links](#map-info--store-links)
  - [Extras](#extras)
- [Example: Bottom Sheet Picker](#example-bottom-sheet-picker)
- [Binary Size & Native Declarations](#binary-size--native-declarations)
- [Custom Maps](#custom-maps)
- [Migrating from 5.x](#migrating-from-5x)
- [Known Issues](#known-issues)
- [Contributing](#contributing)

## Quick Start

Requires Flutter **3.41+** and Dart **3.11+**. Android supports AGP 8 and AGP 9.

```yaml
dependencies:
  map_launcher: ^7.0.0
```

```dart
import 'package:map_launcher/map_launcher.dart';

// Show a marker (opens the best available map)
await MapLauncher.marker(.coords(59.33, 18.07, title: 'Gamla Stan')).show();

// Show directions
await MapLauncher.directions(.coords(59.33, 18.07), mode: .walking).show();

// Search
await MapLauncher.marker(.search('Fika near Södermalm')).show();

// Specific map
await MapLauncher.marker(.coords(59.33, 18.07)).show(map: .google);

// Discover available maps (pass the maps your app supports)
final maps = await MapLauncher.marker(.coords(59.33, 18.07))
    .getSupportedMaps([.apple, .google, .waze]);
if (maps.isNotEmpty) await maps.first.show();
```

## Setup

### iOS: Add URL schemes to Info.plist

For installed-app discovery, add only the schemes your app uses to
`Info.plist`. For example, Google Maps and Waze:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>comgooglemaps</string>
  <string>waze</string>
</array>
```

Apple Maps needs no entry. Other schemes are available as
`MapApp.<name>.iosScheme`. The [example plist](example/ios/Runner/Info.plist)
lists the full showcase; copy only your selected entries.

<details>
<summary>All iOS schemes — copy only the maps you use</summary>

Add selected lines inside your `LSApplicationQueriesSchemes` array:

```xml
<string>comgooglemaps</string> <!-- Google Maps -->
<string>waze</string> <!-- Waze -->
<string>iosamap</string> <!-- Amap -->
<string>baidumap</string> <!-- Baidu Maps -->
<string>yandexmaps</string> <!-- Yandex Maps -->
<string>yandexnavi</string> <!-- Yandex Navigator -->
<string>citymapper</string> <!-- Citymapper -->
<string>mapswithme</string> <!-- MAPS.ME -->
<string>osmandmaps</string> <!-- OsmAnd -->
<string>dgis</string> <!-- 2GIS -->
<string>qqmap</string> <!-- Tencent (QQ Maps) -->
<string>here-location</string> <!-- HERE WeGo -->
<string>tomtomgo</string> <!-- TomTom Go -->
<string>copilot</string> <!-- CoPilot -->
<string>com.sygic.aura</string> <!-- Sygic Truck -->
<string>nmap</string> <!-- Naver Map -->
<string>kakaomap</string> <!-- Kakao Maps -->
<string>tmap</string> <!-- TMap -->
<string>szn-mapy</string> <!-- Mapy.cz -->
<string>mappls</string> <!-- Mappls -->
<string>moovit</string> <!-- Moovit -->
<string>neshan</string> <!-- Neshan -->
<string>airnavpro</string> <!-- Air Navigation Pro -->
<string>magicearth</string> <!-- Magic Earth -->
```

</details>

If you pass a map to discovery but forget its plist entry, debug builds print
a warning naming the exact scheme to add. Without the entry the map can
never be detected, which is otherwise indistinguishable from "not installed".

### Android: Declare selected packages for discovery

On Android 11+, installed-app discovery requires package visibility. Version 7
does not bundle provider `<queries>` in the library manifest. Add the packages
you want to discover under `<manifest>` in your app's `AndroidManifest.xml`.
For example, Google Maps and Waze:

```xml
<queries>
  <package android:name="com.google.android.apps.maps" />
  <package android:name="com.waze" />
</queries>
```

Apple Maps has no Android package. Other package names are available as
`MapApp.<name>.playStoreId`. The [example manifest](example/android/app/src/main/AndroidManifest.xml)
declares the full showcase; copy only your selected entries. Missing visibility
can make an installed app appear absent. These declarations are for discovery,
not a requirement to call bare `show()`, which launches without detection.

<details>
<summary>All Android packages — copy only the maps you use</summary>

Add selected lines inside your manifest's `<queries>` element:

```xml
<package android:name="com.google.android.apps.maps" /> <!-- Google Maps -->
<package android:name="com.google.android.apps.mapslite" /> <!-- Google Maps Go -->
<package android:name="com.waze" /> <!-- Waze -->
<package android:name="com.autonavi.minimap" /> <!-- Amap -->
<package android:name="com.baidu.BaiduMap" /> <!-- Baidu Maps -->
<package android:name="ru.yandex.yandexmaps" /> <!-- Yandex Maps -->
<package android:name="ru.yandex.yandexnavi" /> <!-- Yandex Navigator -->
<package android:name="com.citymapper.app.release" /> <!-- Citymapper -->
<package android:name="com.mapswithme.maps.pro" /> <!-- MAPS.ME -->
<package android:name="net.osmand" /> <!-- OsmAnd -->
<package android:name="net.osmand.plus" /> <!-- OsmAnd+ -->
<package android:name="ru.dublgis.dgismobile" /> <!-- 2GIS -->
<package android:name="com.tencent.map" /> <!-- Tencent (QQ Maps) -->
<package android:name="com.here.app.maps" /> <!-- HERE WeGo -->
<package android:name="com.huawei.maps.app" /> <!-- Petal Maps -->
<package android:name="com.tomtom.gplay.navapp" /> <!-- TomTom Go -->
<package android:name="com.tomtom.gplay.navapp.gofleet" /> <!-- TomTom Go Fleet -->
<package android:name="com.alk.copilot.mapviewer" /> <!-- CoPilot -->
<package android:name="com.sygic.truck" /> <!-- Sygic Truck -->
<package android:name="nl.flitsmeister" /> <!-- Flitsmeister -->
<package android:name="com.nhn.android.nmap" /> <!-- Naver Map -->
<package android:name="net.daum.android.map" /> <!-- Kakao Maps -->
<package android:name="com.skt.tmap.ku" /> <!-- TMap -->
<package android:name="cz.seznam.mapy" /> <!-- Mapy.cz -->
<package android:name="com.mmi.maps" /> <!-- Mappls -->
<package android:name="com.tranzmate" /> <!-- Moovit -->
<package android:name="org.rajman.neshan.traffic.tehran.navigator" /> <!-- Neshan -->
<package android:name="com.xample.airnavigation" /> <!-- Air Navigation Pro -->
<package android:name="com.generalmagic.magicearth" /> <!-- Magic Earth -->
```

</details>

### Web / Desktop: No setup needed

Desktop launches HTTP(S) links in the default browser using `open` on macOS,
`xdg-open` on Linux, and Windows PowerShell on Windows. These system launchers
and a browser handler must be available. Browser popup blocking can prevent web
launches; launch from a user gesture and handle `MapLaunchException`.

## API

### Markers

```dart
// By coordinates
await MapLauncher.marker(.coords(59.33, 18.07, title: 'Gamla Stan')).show();

// With zoom level
await MapLauncher.marker(.coords(59.33, 18.07), zoom: 14).show();

// By search query (Google & Apple Maps)
await MapLauncher.marker(.search('Vasa Museum Stockholm')).show();
```

### Error Handling

`show()` throws `MapLaunchException` if no provider can fulfill the request or
handoff fails. `reason` is a `MapLaunchFailure`: `noEligibleMap`, `exhausted`,
`blocked` or `unknown`. Ordered `issues` describe preparation/transport failures;
`url` is nullable. Avoid logging URLs containing private data.

```dart
try {
  await MapLauncher.marker(.coords(59.33, 18.07)).show(map: .google);
} on MapLaunchException catch (e) {
  print('Failed to open map: $e');
}
```

### Directions

Discovery excludes maps that declare the requested travel mode unsupported.
Explicitly launching an unsupported request throws `MapLaunchException`;
URL inspection returns `null`. Text origins require search support. Waypoints
currently require a coordinate destination and a waypoint-capable map.
Explicit coordinate origins also require `supportsDirectionsOrigin`; they are
not silently dropped. Marker getters likewise honor marker capability flags.

```dart
// Basic
await MapLauncher.directions(.coords(59.33, 18.07)).show();

// With origin, mode, and waypoints
await MapLauncher.directions(
  .coords(59.33, 18.07),
  from: .coords(59.33, 18.10, title: 'Djurgården'),
  mode: .walking,
  waypoints: [.coords(59.32, 18.08)],
).show();

// Search-based destination
await MapLauncher.directions(.search('Vasa Museum')).show();

// Search-based origin
await MapLauncher.directions(
  .coords(59.33, 18.07),
  from: .search('Stockholm Central'),
).show();
```

### Choosing a Map

```dart
// Specific map
await MapLauncher.marker(.coords(59.33, 18.07)).show(map: .google);

// Without map: iOS tries Apple then Google; elsewhere Google then Apple.
// No installation-detection await before launch.
```

Automatic launch skips unsupported or misconfigured candidates and retries only
after confirmed non-handoff. Blocked popups and unknown outcomes are terminal.
Explicit maps and picker entries never switch provider, though they may retry
that provider's transports. Launch from a user gesture on web.

### Discovering Maps

Pass the providers your app offers. Declare the list once and reuse it:

```dart
const myMaps = <MapApp>[.apple, .google, .waze];

// Maps that support a specific marker request
final marker = MapLauncher.marker(.coords(59.33, 18.07));
final maps = await marker.getSupportedMaps(myMaps);
for (final map in maps) {
  print('${map.name} (installed: ${map.isInstalled})');
}
if (maps.isNotEmpty) await maps.first.show(); // captured request and options

// Maps that support a specific directions request
final directions = MapLauncher.directions(.coords(59.33, 18.07), mode: .walking);
final navMaps = await directions.getSupportedMaps(myMaps);

// Metadata only: List<AvailableMap>, no show() method
final allAvailable = await MapLauncher.getAvailableMaps(myMaps);
```

`MapApp.all` was removed in v7. Configure extras before request discovery and
refresh results when the request changes. Entries capture validated options;
unsupported or misconfigured providers are excluded. Availability does not
guarantee a successful launch.

### URL Inspection

Getters return raw base URLs: they do not append extras or validate required
caller configuration. Discovery and `show()` validate prepared options, not
credential validity. Expected provider rejections use `MapConfigurationError`
and become filtered discovery entries or `MapLaunchException` launch issues.
Google universal-only extras may change the URL family at preparation.

```dart
final marker = MapLauncher.marker(.coords(59.33, 18.07, title: 'Gamla Stan'));

// Best URL for this platform (scheme on mobile, universal on web)
final url = marker.getUrl(map: .google);

// Universal (HTTPS) URL, always works in browser
final universal = marker.getUniversalUrl(map: .google);
// → https://www.google.com/maps/search/?api=1&query=59.33%2C18.07

// Native scheme URL, only works with installed app
final scheme = marker.getSchemeUrl(map: .google);
// → comgooglemaps://?q=59.33,18.07

// Preview scheme URL for a different platform
final iosScheme = marker.getSchemeUrl(map: .google, platform: .ios);
final androidScheme = marker.getSchemeUrl(map: .google, platform: .android);
```

### Map Info & Store Links

`MapApp` properties are synchronous:

```dart
MapApp.waze.name          // "Waze"
MapApp.waze.id            // "waze", stable and safe to persist in preferences
MapApp.waze.iconBytes    // PNG bytes, use with Image.memory()
MapApp.waze.appStoreUrl   // "https://apps.apple.com/app/id323229106"
MapApp.waze.playStoreUrl  // "https://play.google.com/store/apps/details?id=com.waze"
MapApp.waze.hasUniversalLink // true
```

### Extras

Use `providerExtras` for automatic launch or discovery. Options apply only to
the matching provider ID; an Apple fallback does not inherit Google options.
Keep essential origin, mode and stops in the request fields.

```dart
final request = MapLauncher.directions(
  .coords(59.33, 18.07),
  mode: .walking,
  providerExtras: {.google: GoogleExtra(navigate: true)},
);
await request.show();
final maps = await request.getSupportedMaps([.apple, .google]);
if (maps.isNotEmpty) await maps.first.show();
```

Raw `extra` requires explicit `show(map: ...)`. Precedence, highest first:
show extras → request extras → provider extras. Conflicting generated URL
parameters are rejected; identical values are kept once. Extras and waypoints
are copied into immutable snapshots; duplicate provider IDs are rejected.

Google Place-ID/navigation extras select HTTPS and require companion fields.
See the [Google reference](doc/maps/google.md) for requirements and limits.

```dart
// Google: Place IDs, navigation mode
await MapLauncher.marker(.coords(59.33, 18.07)).show(
  map: .google,
  extra: GoogleExtra(queryPlaceId: 'ChIJLU7jZClu5kcR4PcOOO6p3I0'),
);

await MapLauncher.directions(.coords(59.33, 18.07)).show(
  map: .google,
  extra: GoogleExtra(navigate: true, destinationPlaceId: 'ChIJLU7j...'),
);

// Apple: map display type, search bias location
await MapLauncher.marker(.coords(59.33, 18.07)).show(
  map: .apple,
  extra: AppleExtra(display: AppleMapDisplay.satellite),
);

await MapLauncher.marker(.search('restaurants')).show(
  map: .apple,
  extra: AppleExtra(near: LocationCoords(59.33, 18.07)),
);

// Waze: auto-navigate
await MapLauncher.directions(.coords(59.33, 18.07)).show(
  map: .waze,
  extra: WazeExtra(navigate: true),
);

// Tencent: API key
await MapLauncher.marker(.coords(39.9, 116.4)).show(
  map: .tencent,
  extra: TencentExtra(referer: 'your-app-key'),
);

// Naver: use the caller identity appropriate to the target platform
await MapLauncher.marker(.coords(37.5665, 126.9780)).show(
  map: .naver,
  extra: NaverExtra(appName: 'com.example.myapp'),
);

// Baidu: complete attribution, including the platform prefix
await MapLauncher.marker(.coords(39.9, 116.4)).show(
  map: .baidu,
  extra: BaiduExtra(src: 'andr.example.myapp'),
);
// Use ios.example.myapp on iOS. No default attribution is invented.
// All these helpers also work in providerExtras before discovery:
final request = MapLauncher.marker(
  .coords(37.5665, 126.9780),
  providerExtras: {.naver: NaverExtra(appName: 'com.example.myapp')},
);
final maps = await request.getSupportedMaps([.naver, .google]);

// Yandex Navigator: auth
await MapLauncher.directions(.coords(55.75, 37.62)).show(
  map: .yandexNavi,
  extra: YandexNaviExtra(client: 'your-client-id', signature: 'your-sig'),
);

// Raw map, works with any map
await MapLauncher.marker(.coords(59.33, 18.07)).show(
  map: .apple,
  extra: {'t': 'k'}, // satellite view via raw params
);
```

## Example: Bottom Sheet Picker

```dart
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';

class MapPickerSheet extends StatelessWidget {
  final LocationCoords destination;

  const MapPickerSheet({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    final request = MapLauncher.marker(destination);

    return FutureBuilder<List<SupportedMap>>(
      future: request.getSupportedMaps([.apple, .google, .waze, .citymapper]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final maps = snapshot.data!;

        return SafeArea(
          child: SingleChildScrollView(
            child: Wrap(
              children: [
                for (final map in maps)
                  ListTile(
                    onTap: () => map.show(),
                    title: Text(map.name),
                    leading: Image.memory(map.iconBytes,
                      height: 30,
                      width: 30,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Usage
showModalBottomSheet(
  context: context,
  builder: (_) => MapPickerSheet(
    destination: .coords(59.33, 18.07, title: 'Gamla Stan'),
  ),
);
```

## Binary Size & Native Declarations

Dart tree shaking removes unreferenced providers, including their icons and URL
strings. Discovery lists retain their providers; bare `show()` also retains Apple
and Google.

Native declarations are separate. Declare only the Android packages and iOS
schemes your app uses (see [Setup](#setup)). When identifier presence matters,
inspect the merged manifest, plist and release archive. These checks do not
guarantee store approval.

## Custom Maps

Subclass `MapApp` to add a map the plugin doesn't ship. No fork needed:

```dart
class AcmeMaps extends MapApp {
  const AcmeMaps();

  @override
  String get id => 'acmeMaps';

  @override
  String get name => 'Acme Maps';

  @override
  bool get hasUniversalLink => true;

  @override
  String? get playStoreId => 'com.acme.maps';

  @override
  String? get iosScheme => 'acmemaps://';

  @override
  Uint8List get iconBytes => myIconPngBytes;

  @override
  String? markerUrl(LocationCoords coords, {int? zoom}) =>
      'https://maps.acme.com/?ll=${coords.latlng}';

  @override
  String? directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  }) => 'https://maps.acme.com/directions?to=${destination.latlng}';
}

// Works everywhere a built-in map does:
await MapLauncher.marker(.coords(59.33, 18.07)).show(map: const AcmeMaps());
final maps = await request.getSupportedMaps([.google, const AcmeMaps()]);
```

Override the scheme-URL methods and capability flags (`supportsWaypoints`,
`supportsMarkerSearch`, ...) as needed. See any map in
[`lib/src/maps/`](lib/src/maps/) for a template.

Use `validateLaunchUrl` and `validateLaunchTransport` to reject expected invalid
configuration with `MapConfigurationError`. Discovery/automatic selection can
skip those rejections; unexpected programming errors propagate.

For a custom map to be **detected** as installed, add its identifiers to your
own app config. This applies to every selected provider, built-in or custom;
the plugin does not bundle provider discovery declarations:

- **iOS**: add its scheme to `LSApplicationQueriesSchemes` (debug builds warn
  if you forget).
- **Android**: add a `<queries>` entry to your `AndroidManifest.xml`:

  ```xml
  <queries>
    <package android:name="com.acme.maps" />
  </queries>
  ```

  Note there is no warning for this on Android. The OS gives apps no way to
  check their own `<queries>`, so a missing entry looks exactly like "app
  not installed". Launching (`show(map: const AcmeMaps())`) works either way;
  only detection needs these entries.

## Migrating from 5.x

Follow [5.x → 6.0](MIGRATION.md#5x--60), then
[6.x → 7.0](MIGRATION.md#6x--70). If you already use v6, only the second guide
applies. The [changelog](CHANGELOG.md) lists release changes.

## Known Issues

- On iOS it's possible to "delete" Apple Maps which actually just removes it from the home screen and does not actually delete it. Because of that Apple Maps will always show up as available on iOS. [More info](https://stackoverflow.com/questions/39603120/how-to-check-if-apple-maps-is-installed)

## Contributing

Pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for setup instructions and guidelines.
