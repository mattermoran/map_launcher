# Migrating to 6.0

> Upgrading from 4.x? The 5.0.0 entry in [CHANGELOG.md](CHANGELOG.md) covers
> the 4.x → 5.0 breaking changes. Apply those first, then follow this guide.

6.0 replaces the `MapType` enum and the internal map registry with plain
`MapApp` objects. The payoff: **only the maps your code references are
compiled into your app**. If you never reference Neshan, nothing about it
(URL scheme, package name, store id, icon) exists in your release binary.

Why this matters: App Store review scans binaries for references to embargoed
services, and apps using 5.x were rejected for containing identifiers of map
apps they never used. In 5.x every map shipped in every app; in 6.0 that's
opt-in per map.

The request API (`MapLauncher.marker(...)`, `.directions(...)`, `.show(...)`)
is unchanged. Most call sites compile as-is.

## What compiles unchanged

Dot-shorthands re-resolve from the enum to the new objects automatically:

```dart
// Identical in 5.x and 6.0:
await MapLauncher.marker(.coords(59.33, 18.07)).show();
await MapLauncher.marker(.coords(59.33, 18.07)).show(map: .google);
await MapLauncher.directions(.coords(59.33, 18.07), mode: .walking).show(
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

To keep the 5.x behavior of offering every supported map, pass `MapApp.all`,
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

### 8. (Optional) Prune the Android manifest

The plugin still ships `<queries>` entries for all maps so detection works
out of the box. Play does not scan these, but if you want a minimal merged
manifest, remove entries per map in your app's `AndroidManifest.xml`:

```xml
<queries>
  <package android:name="org.rajman.neshan.traffic.tehran.navigator"
           tools:node="remove" />
</queries>
```

## Quick reference

| 5.x | 6.0 |
| --- | --- |
| `show(map: .google)` | unchanged |
| `MapType.google` | `MapApp.google` |
| `getSupportedMaps()` | `getSupportedMaps(myMaps)` |
| `MapLauncher.getAvailableMaps()` | `MapLauncher.getAvailableMaps(myMaps)` |
| offer every map | pass `MapApp.all` (opts out of tree shaking) |
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

No output means it's not in your binary.
