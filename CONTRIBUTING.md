# Contributing to Map Launcher

## Adding a New Map

Most contributions add support for a new map app. Follow these steps:

### 1. Create a `MapApp` subclass

Create `lib/src/maps/my_map.dart` with a class extending [`MapApp`](lib/src/maps/map_app.dart). See existing maps like [`GoogleMaps`](lib/src/maps/google_maps.dart) for the pattern.

At minimum you need:

- `id`: unique identifier (camelCase, e.g. `'myMap'`)
- `name`: display name shown to users
- `iconBytes`: the PNG icon (see step 4)
- `markerUrl()`: show a location
- `directionsUrl()`: show directions

Override `markerSchemeUrl()` / `directionsSchemeUrl()` for native URL schemes, and return `null` for any method your map doesn't support.

Set `hasUniversalLink: true` only if the map has HTTPS URLs that work in any browser.

### 2. Register the map

In [`lib/src/maps/map_app.dart`](lib/src/maps/map_app.dart):

- Import your new class
- Add a `static const` field (e.g. `static const myMap = MyMap()`)
- Add it to the `MapApp.all` list

### 3. Export from the barrel file

In [`lib/map_launcher.dart`](lib/map_launcher.dart), add an export for your map file:

```dart
export 'src/maps/my_map.dart';
```

### 4. Add an icon

Icons are 256×256 PNGs stored in `assets/icons/`. The filename must match the `id` exactly (e.g. `myMap.png`).

To fetch icons automatically from the App Store / Play Store:

```bash
dart run tool/fetch_icons.dart --only myMap
```

Then regenerate Dart icon constants:

```bash
dart run tool/generate_icons.dart
```

This creates `lib/src/maps/icons/my_map_icon.dart` with a `Uint8List` constant that your `iconBytes` getter should return.

### 5. Add native detection

**Android** (`android/src/main/kotlin/.../MapLauncherPlugin.kt`):

- Add your package name to the `mapPackages` map.

**Android** (`android/src/main/AndroidManifest.xml`):

- Add a `<package>` entry under `<queries>`.

**iOS** (`ios/map_launcher/Sources/map_launcher/MapLauncherPlugin.swift`):

- Add your URL scheme to the `mapSchemes` dictionary.

**iOS** (`example/ios/Runner/Info.plist`):

- Add your URL scheme to `LSApplicationQueriesSchemes`.

Skip the platform if your map doesn't support it (e.g., Android-only apps don't need iOS entries).

### 6. Add tests

Add a test file at `test/maps/my_map_test.dart` covering the URLs your map generates. See existing test files in `test/maps/` for examples.

### 7. Update docs

- Add your map to the supported maps list and capability tables in [`README.md`](README.md).

## Development Setup

```bash
# Get dependencies
flutter pub get
cd example && flutter pub get && cd ..

# Run tests
flutter test

# Run analysis
dart analyze
```

## Running the Example App

```bash
cd example
flutter run
```

## Pull Request Guidelines

- One map per PR (keeps review simple).
- Include the PNG icon (generated via `tool/fetch_icons.dart` and `tool/generate_icons.dart`).
- Make sure `dart analyze` and `flutter test` pass.
- Add your map to the README tables.

## Architecture Overview

```
lib/
├── map_launcher.dart              # Public barrel file (exports all public API)
├── map_launcher_platform_interface.dart  # Platform contract
├── map_launcher_method_channel.dart      # Mobile implementation
├── map_launcher_web.dart                 # Web implementation
├── map_launcher_desktop.dart             # Desktop implementation
└── src/
    ├── map_launcher.dart          # MapLauncher entry point
    ├── models/                    # Data types (Location, TravelMode, etc.)
    ├── maps/                      # MapApp subclasses (one per map app)
    │   ├── map_app.dart           # Base class + static const instances + all list
    │   ├── google_maps.dart       # Example: GoogleMaps extends MapApp
    │   └── icons/                 # Generated Dart icon constants (Uint8List)
    ├── requests/                  # MarkerRequest, DirectionsRequest
    ├── extras/                    # Map-specific parameter helpers
    └── utils/                     # URL building utilities

assets/icons/                      # 256×256 PNG icons (source files)
tool/
├── fetch_icons.dart               # Downloads icons from App Store / Play Store
└── generate_icons.dart            # Converts PNGs to Dart Uint8List constants
test/maps/                         # Tests for individual map URL builders
```

The plugin is intentionally thin on the native side. It only detects installed apps and launches URLs. All URL construction happens in Dart.
