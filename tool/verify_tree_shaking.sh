#!/usr/bin/env bash
#
# Release gate: proves that unreferenced maps are tree-shaken out of
# consumer release binaries.
#
# Builds a minimal app that references only MapApp.apple and MapApp.google,
# then scans the release binary and bundle:
#   - identifiers of unreferenced maps must be absent
#   - identifiers of the referenced maps must be present (proves the scan works)
#   - no plugin assets may ship in the bundle (icons are compiled into Dart)
#
# Usage: tool/verify_tree_shaking.sh [macos|apk]   (default: macos on macOS, apk otherwise)
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if command -v fvm >/dev/null 2>&1 && [ -f "$PLUGIN_DIR/.fvmrc" ]; then
  FLUTTER="fvm flutter"
else
  FLUTTER="flutter"
fi

if [ "${1:-}" != "" ]; then
  TARGET="$1"
elif [ "$(uname)" = "Darwin" ]; then
  TARGET="macos"
else
  TARGET="apk"
fi

# Strings that must not appear when their maps are unreferenced. Includes the
# embargo-sensitive Neshan identifiers (the original App Store rejection) plus
# a sample of other maps' schemes/packages.
FORBIDDEN='neshan|nshn\.ir|rajman|dgis://|2gis|citymapper|baidumap|mapswithme|szn-mapy'
# Strings that must appear (the referenced maps). Proves the scan sees the snapshot.
REQUIRED=('comgooglemaps' 'maps.apple.com')

WORK_DIR="$(mktemp -d)"
# KEEP=1 tool/verify_tree_shaking.sh   keep the scratch app for debugging
if [ "${KEEP:-0}" != "1" ]; then
  trap 'rm -rf "$WORK_DIR"' EXIT
fi

echo "==> Creating scratch app in $WORK_DIR (target: $TARGET)"
cd "$WORK_DIR"
platform_flag="macos"; [ "$TARGET" = "apk" ] && platform_flag="android"
$FLUTTER create --platforms="$platform_flag" -e shake_check >/dev/null

cd shake_check
python3 - "$PLUGIN_DIR" <<'EOF'
import sys
dep = f"  map_launcher:\n    path: {sys.argv[1]}\n"
s = open('pubspec.yaml').read()
s = s.replace('dependencies:\n  flutter:\n    sdk: flutter\n',
              'dependencies:\n  flutter:\n    sdk: flutter\n' + dep)
open('pubspec.yaml', 'w').write(s)
EOF

cat > lib/main.dart <<'EOF'
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ElevatedButton(
        onPressed: () async {
          final maps = await MapLauncher.marker(
            .coords(48.85, 2.29, title: 'Eiffel Tower'),
          ).getSupportedMaps([.apple, .google]);
          await maps.first.show();
        },
        child: const Text('open'),
      ),
    );
  }
}
EOF

echo "==> Building release ($TARGET)"
if [ "$TARGET" = "apk" ]; then
  $FLUTTER build apk --release >/dev/null
  APK="build/app/outputs/flutter-apk/app-release.apk"
  unzip -o -q "$APK" 'lib/arm64-v8a/libapp.so' -d extracted
  BIN="extracted/lib/arm64-v8a/libapp.so"
  BUNDLE="$APK"
  ASSET_LEAK() { unzip -l "$APK" | grep -c 'flutter_assets/packages/map_launcher' || true; }
else
  $FLUTTER build macos --release >/dev/null
  APP="$(ls -d build/macos/Build/Products/Release/*.app)"
  BIN="$APP/Contents/Frameworks/App.framework/App"
  BUNDLE="$APP"
  ASSET_LEAK() { find "$APP" -path '*/flutter_assets/packages/map_launcher*' | grep -c . || true; }
fi

echo "==> Scanning $BIN"
FAIL=0

# Extract once; grep the file (piping into `grep -q` under pipefail is racy:
# grep exits on first match and strings dies with SIGPIPE).
STRINGS_FILE="$WORK_DIR/binary-strings.txt"
strings "$BIN" > "$STRINGS_FILE"

LEAKS="$(grep -iE "$FORBIDDEN" "$STRINGS_FILE" | sort -u || true)"
if [ -n "$LEAKS" ]; then
  echo "FAIL: unreferenced map identifiers found in release binary:"
  echo "$LEAKS"
  FAIL=1
fi

for req in "${REQUIRED[@]}"; do
  if ! grep -q "$req" "$STRINGS_FILE"; then
    echo "FAIL: expected referenced-map string '$req' missing. Scan may be broken"
    FAIL=1
  fi
done

LEAKED="$(ASSET_LEAK)"
if [ "$LEAKED" != "0" ]; then
  echo "FAIL: $LEAKED plugin asset(s) found in bundle $BUNDLE"
  FAIL=1
fi

if [ "$FAIL" = "0" ]; then
  echo "OK: no unreferenced map identifiers, no leaked plugin assets."
fi
exit "$FAIL"
