# Contributing to Map Launcher

## Adding a New Map

Most contributions add support for a new map app. Follow these steps:

### 1. Add the enum entry

In [`lib/src/models/map_type.dart`](lib/src/models/map_type.dart), add your map to the `MapType` enum:

```dart
/// My Map App.
myMap(
  displayName: 'My Map App',
  playStoreId: 'com.example.mymap',    // Android package name, or omit
  appStoreId: '123456789',              // App Store numeric ID, or omit
),
```

- Set `hasUniversalLink: true` only if the map has HTTPS URLs that work in any browser.
- Use the exact Google Play / App Store IDs (check the store listing URL).

### 2. Create a URL builder

Create `lib/src/maps/my_map.dart` implementing `MapUrlBuilder`. See existing builders for the pattern — at minimum you need:

- `markerUrl()` / `markerSchemeUrl()` — show a location
- `directionsUrl()` / `directionsSchemeUrl()` — show directions

Return `null` for any method your map doesn't support.

### 3. Register the builder

In [`lib/src/maps/map_registry.dart`](lib/src/maps/map_registry.dart), import your builder and add it to the `_builders` map.

### 4. Add native detection

**Android** (`android/src/main/kotlin/.../MapLauncherPlugin.kt`):

- Add your package name to the `mapPackages` map.

**Android** (`android/src/main/AndroidManifest.xml`):

- Add a `<package>` entry under `<queries>`.

**iOS** (`ios/map_launcher/Sources/map_launcher/MapLauncherPlugin.swift`):

- Add your URL scheme to the `mapSchemes` dictionary.

**iOS** (`example/ios/Runner/Info.plist`):

- Add your URL scheme to `LSApplicationQueriesSchemes`.

Skip the platform if your map doesn't support it (e.g., Android-only apps don't need iOS entries).

### 5. Add an icon

Add an SVG icon at `assets/icons/<enumName>.svg`. The filename must match the enum value name exactly.

### 6. Update docs

- Add your map to the supported maps list and capability tables in [`README.md`](README.md).

## Development Setup

```bash
# Get dependencies
flutter pub get
cd example && flutter pub get && cd ..

# Run tests
flutter test

# Run analysis
flutter analyze
```

## Running the Example App

```bash
cd example
flutter run
```

## Pull Request Guidelines

- One map per PR (keeps review simple).
- Include the SVG icon.
- Make sure `flutter analyze` and `flutter test` pass.
- Add your map to the README tables.

## Architecture Overview

```
lib/
├── map_launcher.dart              # Public barrel file
├── map_launcher_platform_interface.dart  # Platform contract
├── map_launcher_method_channel.dart      # Mobile implementation
├── map_launcher_web.dart                 # Web implementation
├── map_launcher_desktop.dart             # Desktop implementation
└── src/
    ├── map_launcher.dart          # MapLauncher entry point
    ├── models/                    # Data types (MapType, Location, etc.)
    ├── maps/                      # URL builders (one per map app)
    ├── requests/                  # MarkerRequest, DirectionsRequest
    ├── extras/                    # Map-specific parameter helpers
    └── utils/                     # URL building utilities
```

The plugin is intentionally thin on the native side — it only detects installed apps and launches URLs. All URL construction happens in Dart.
