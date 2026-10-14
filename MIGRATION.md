# Migration guides

## 6.x → 7.0

### Replace the bundled discovery list and native queries

Replace `MapApp.all` with the providers your app offers:

```dart
const myMaps = <MapApp>[.apple, .google, .waze];
final available = await MapLauncher.getAvailableMaps(myMaps);
final supported = await request.getSupportedMaps(myMaps);
```

Add selected Android packages to your app's `<queries>` for Android 11+
discovery; the library no longer declares them. Remove old `tools:node="remove"`
overrides that only removed library entries. iOS `LSApplicationQueriesSchemes`
requirements are unchanged. See [setup examples](README.md#setup).

Dart tree shaking does not remove native declarations. Keep both lists limited
to providers your app offers; this is not a guarantee of store approval.

### Scope options before automatic launch or discovery

Raw `extra` still works with explicit `show(map: ...)`. Automatic launch and
request discovery reject nonempty raw extras with `ArgumentError`; use
`providerExtras` instead:

```dart
final request = MapLauncher.directions(
  .coords(59.33, 18.07),
  mode: .walking,
  providerExtras: <MapApp, Map<String, String>>{
    .google: GoogleExtra(navigate: true),
  },
);
await request.show();
final maps = await request.getSupportedMaps([.apple, .google]);
if (maps.isNotEmpty) await maps.first.show();
```

Options match by provider ID; duplicate IDs are rejected. Keep essential origin,
mode and stops in request fields: another provider need not honor Google options.
For explicit launch, precedence (highest first) is show extras → request extras → provider extras.
Conflicts with generated URL parameters are rejected.

Extras and waypoints are copied into unmodifiable snapshots. Remove `const`
from request constructors.

### Update picker and availability types

| v6 usage | v7 replacement |
| --- | --- |
| `getAvailableMaps(myMaps)` returning `List<SupportedMap>` | `List<AvailableMap>` — metadata only |
| `SupportedMap(map: ..., isInstalled: ...)` | `AvailableMap(map: ..., isInstalled: ...)` |
| Picker entry `show(extra: ...)` | Configure `providerExtras` before discovery, then `show()` |
| Compare picker entries across refreshes | Compare `map.id`; `SupportedMap` now uses identity equality |
| `opensNatively` / `opensInBrowser` | `isInstalled` / `hasUniversalLink` — hints, not handler guarantees |

Request discovery returns launchable `SupportedMap` entries. Rebuild them when
the request changes, handle empty results, and resolve saved IDs against fresh
entries before launching.

### Handle typed failures and provider validation

Catch `MapLaunchException` rather than `UnsupportedError` for unsupported launches.
Its `reason` is `noEligibleMap`, `exhausted`, `blocked` or `unknown`; `issues`
contains ordered failures and `url` is nullable. URLs may contain private data.

Bare `show()` tries Apple then Google on iOS, Google then Apple elsewhere,
skipping unsupported or misconfigured candidates. Only confirmed failed handoffs
retry; blocked or unknown outcomes stop. Explicit maps and picker entries never
switch provider. URL getters remain base URLs without extras or launch validation.

Custom providers: throw `MapConfigurationError` from `validateLaunchUrl` or
`validateLaunchTransport` for expected rejections. Other errors propagate.

Custom platform adapters: throw `MapHandoffException` only for confirmed failed
handoffs. Set `blocked: true` for terminal restrictions such as blocked popups.
Other exceptions stop retries to avoid opening a second map.

Naver/Baidu caller attribution and Tencent's `referer` remain optional in the
plugin. Follow [provider requirements](docs/maps/README.md) for app acceptance;
Naver/Baidu attribution is not an API key.

### Check stricter request support

Unsupported origins, modes, marker actions and stops are rejected rather than
silently dropped. Search destinations with waypoints remain unsupported; use
coordinates. MAPS.ME requires origin; Baidu Android routes require coordinate
`from` or a named `origin` extra (validated after extras are merged);
TomTom iOS markers, Fleet iOS directions and Air Navigation Pro marker launches
are unavailable. Sygic Truck accepts driving only. OsmAnd now plans routes and
Mapy uses its v1 route API.

Apple legacy links reject bicycling and waypoints; automatic cycling requests
can use Google instead. Google validates the final HTTPS URL's 2,048-character
cap and allows up to nine intermediate stops on Android package-targeted or
desktop transports, three on mobile unpinned HTTPS. Over-limit transports are
excluded, never truncated; a nine-stop Android route cannot fall back to the
three-stop browser transport.

## 5.x → 6.0

> Historical guide for 6.0 only. For v7, also apply the 6 → 7 section above:
> `MapApp.all` and bundled Android provider queries no longer exist.

> Upgrading from 4.x? The 5.0.0 entry in [CHANGELOG.md](CHANGELOG.md) covers
> the 4.x → 5.0 breaking changes. Apply those first, then follow this guide.

6.0 replaces the `MapType` enum and the internal map registry with plain
`MapApp` objects. The payoff: **only the maps your code references are
retained in Dart release code**, including their URL schemes, store ids, and icons.
Bare `show()` retains Apple and Google as defaults. Native manifest entries
are not tree-shaken: prune Android `<queries>` and iOS query schemes separately.

This reduces unused Dart code, but does not guarantee identifier-free binaries
or App Store approval. Inspect the final release artifact if that is required.

The request API (`MapLauncher.marker(...)`, `.directions(...)`, `.show(...)`)
is unchanged. Most call sites compile as-is.

## What compiles unchanged

Dot-shorthands re-resolve from the enum to the new objects automatically:

```dart
// Identical in 5.x and 6.0:
await MapLauncher.marker(.coords(59.33, 18.07)).show();
await MapLauncher.marker(.coords(59.33, 18.07)).show(map: .google);
await MapLauncher.directions(.coords(59.33, 18.07), mode: .driving).show(
  map: .waze,
  extra: WazeExtra(navigate: true),
);
```

## What changes

### 1. `MapType.x` → `MapApp.x`

Same names, different type:

```dart
// 5.x                          // 6.0
MapType.google                  MapApp.google
MapType.waze.displayName        MapApp.waze.name
MapType.waze.appStoreUrl        MapApp.waze.appStoreUrl   // unchanged
```

### 2. Discovery takes your map list

This is the one place the compiler forces a decision: which maps does your
app actually support? Declare them once and reuse:

```dart
const myMaps = <MapApp>[.apple, .google, .waze, .citymapper];

// 5.x
final maps = await request.getSupportedMaps();
final all = await MapLauncher.getAvailableMaps();

// 6.0
final maps = await request.getSupportedMaps(myMaps);
final all = await MapLauncher.getAvailableMaps(myMaps);
```

In 6.0 only, to keep the 5.x behavior of offering every supported map, pass `MapApp.all`,
but note this references all 30 maps, so all their identifiers ship in your
binary again (that's what it did in 5.x implicitly; now it's your explicit
choice).

### 3. `SupportedMap` members renamed, and entries are launchable

```dart
// 5.x
onTap: () => request.show(map: map.mapType),
title: Text(map.mapType.displayName),
leading: SvgPicture.asset(map.mapType.icon),

// 6.0
onTap: () => map.show(),          // launches the originating request
title: Text(map.name),
leading: Image.memory(map.iconBytes),
```

`map.map` gives you the underlying `MapApp` if you need it.

### 4. Icons are PNG bytes, not bundled assets

The plugin no longer bundles any asset files or requires `flutter_svg`.
`MapApp.x.iconBytes` is a `Uint8List` containing 256×256 PNG data. Render it
with Flutter's built-in `Image.memory(...)`. No extra dependencies needed.
Unused icons are tree-shaken with their maps.

### 5. Removed maps

`truckmeister` and `spedionNavigation` have been removed:
- **Truckmeister** was discontinued by Flitsmeister (features merged into the
  main Flitsmeister app).
- **SPEDION Navigation** is an integrated module in the SPEDION fleet app, not
  a standalone map.

If you need either of these, use the custom `MapApp` subclass feature to add
them back in your own code.

### 6. Persisted map selections

`MapApp.id` matches the old enum names exactly, so stored preferences keep
working:

```dart
// 5.x
prefs.setString('map', map.name);            // enum name
final map = MapType.values.byName(saved);

// 6.0
prefs.setString('map', map.id);              // same strings ('google', ...)
final map = myMaps.firstWhere((m) => m.id == saved);
```

### 7. Prune your iOS Info.plist

`LSApplicationQueriesSchemes` is part of *your* app and is visible to App
Store review. The plugin can't manage it for you. Remove the schemes of maps
you don't offer; each map's scheme is available as `MapApp.x.iosScheme`. See
the [README setup section](README.md#setup) for the annotated list.

### 8. Android queries in 6.0 (historical)

6.0 bundled `<queries>` entries for all maps. Version 7 removes those entries;
do not follow older per-package removal recipes. Declare selected packages in
your app instead, as described in the current [setup guide](README.md#setup).

## Historical quick reference: 5.x → 6.0 only

| 5.x | 6.0 |
| --- | --- |
| `show(map: .google)` | unchanged |
| `MapType.google` | `MapApp.google` |
| `getSupportedMaps()` | `getSupportedMaps(myMaps)` |
| `MapLauncher.getAvailableMaps()` | `MapLauncher.getAvailableMaps(myMaps)` |
| offer every map | 6.0 only: pass `MapApp.all` (removed in v7) |
| `map.mapType` | `map.map` |
| `map.displayName` / `MapType.x.displayName` | `map.name` / `MapApp.x.name` |
| `SvgPicture.asset(map.icon)` | `Image.memory(map.iconBytes)` (no `flutter_svg` needed) |
| `MapType.values.byName(saved)` | `myMaps.firstWhere((m) => m.id == saved)` |
| `request.show(map: supported.mapType)` | `supported.show()` |

## Verifying the result

Build a release binary and search it for a map you don't use:

```sh
# Android
unzip -p build/app/outputs/flutter-apk/app-release.apk lib/arm64-v8a/libapp.so \
  | strings | grep -i neshan

# iOS (from the built .app)
strings YourApp.app/Frameworks/App.framework/App | grep -i neshan
```

No output only means this search did not find that string in the inspected
file. Inspect native declarations and the full release archive separately;
these checks do not prove identifier absence or guarantee store approval.
