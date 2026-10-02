# Air Navigation Pro external launch contract

Checked **2026-10-02**. map_launcher baseline [`8aa7a6e1152a80c4482003bdfaad8f850bdb6131`](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131) matched HEAD and fetched `origin/master`. Research only; **no installed-app navigation was exercised**.

## Sources and identity

**Post-audit correction:** the app metadata and icon-fetch registry now use
Apple ID `301046057`, confirmed independently through Apple's live lookup.
The table below records the audited baseline; the metadata regression test now
expects the corrected ID. No launch behavior was changed by this correction.

Primary contract: current official [Import / Export Data → Import via URL](https://airnavigation.aero/manual/en/html/manual/import-export-data.html#import-via-url), manual **8.4.150** (no page modification date supplied). Read in full, including examples; this is not the unrelated manager REST API. The guessed `/import-export.html` path returned 403; the correct `import-export-data.html` page was accessible. Homepage access also returned 403, which does not invalidate the accessible manual.

| Platform | Current identity/evidence | Comparison |
| --- | --- | --- |
| Android | [`com.xample.airnavigation`](https://play.google.com/store/apps/details?id=com.xample.airnavigation), Air Navigation SA; listing updated 2026-07-17 | Matches builder/package query. |
| iOS | Apple [`301046057`](https://apps.apple.com/us/app/air-navigation-pro/id301046057), bundle `ch.xample.Airnav`; Apple [lookup](https://itunes.apple.com/lookup?id=301046057) returned version **8.4.176**, released **2026-09-22T16:31:47Z** | **Mismatch:** builder uses `304684223`. Lookup of that old ID returned zero results, including Sweden; zero alone is not proof of global removal, but the current product's positive identity is clear. |
| Custom scheme | `airnavpro://<command>?<query>` in official manual | Matches our iOS detection/launch scheme. Manual does not give a platform-by-platform scheme-registration matrix. |
| Android HTTPS | Builder uses `https://airnavigation.aero/direct-to?...` | **Not established by accessible official URL docs**, which specify `airnavpro://`. Do not promote this to a verified universal-link/browser contract. |
| Web/desktop | URLs may originate in browser, email, QR code or another app | That is an app launch, not a web map fallback. No browser-based route rendering contract established. Apple lists Apple Silicon compatibility, but this does not establish separate desktop URL semantics. |

Both stores describe a 28-day trial and subscriptions. There is no separate free-vs-paid URL grammar documented. Feature availability/account onboarding can prevent use even when a URL opens the app. The manual limits custom-map imports to Smart Advanced; do not infer that all URL route operations have the same gate.

## All documented URL commands

Source for every row: official [URL commands and examples](https://airnavigation.aero/manual/en/html/manual/import-export-data.html#import-via-url). “Required” below means present in the documented syntax; omission defaults and malformed-input behavior are **not specified** unless stated.

| Command | Fields | Result |
| --- | --- | --- |
| `direct-to` | `coordinates=<format>` required; `location=<waypoint>` required | **Instantly navigates** directly to the waypoint. It is not a passive marker display command. |
| `add-waypoints` | `coordinates=<format>` required; `waypoints=<wp1>;<wp2>;...` required | Adds one or multiple waypoints to the database without creating a route; persistent mutation. |
| `new-route` | `coordinates=<format>`, `route-name=<name>`, `waypoints=<wp1>;<wp2>;...`, all present in documented syntax | Creates and loads a route. No separate origin/destination keys: ordered waypoint sequence defines route. No minimum/maximum count or behavior for missing route-name specified. |
| `new-route` with JeppView/FMS syntax | Same outer fields; `waypoints` may instead contain named fixes and coordinate tokens separated by ` DCT ` | Alternative documented route representation, e.g. `INVIR DCT 5500N01553E DCT ... DCT RIPAM`. Not free-text street-address search. |

No documented `search`, `show-on-map`, zoom/style, road-travel-mode, callback URL, return result, navigation-stop, arrival notification, or route-avoidance parameter was found. This means **not established by these docs**, not proof that no private mechanism exists.

## Waypoint fields, coordinate formats and encoding

Source: [Waypoint structure](https://airnavigation.aero/manual/en/html/manual/import-export-data.html#waypoint-structure), [Direct-To examples](https://airnavigation.aero/manual/en/html/manual/import-export-data.html#direct-to), [JeppView/FMS example](https://airnavigation.aero/manual/en/html/manual/import-export-data.html#route-jeppview-fms-format).

| Field/component | Type/syntax | Requiredness, values, defaults and limits |
| --- | --- | --- |
| `coordinates` | String enum selecting format | Must be specified. No default documented. Values below. |
| `location` | One waypoint record | `<coordinates>,<elevation>,<identifier>,<name>`; truncation/empty trailing component acceptance is undocumented. |
| `waypoints` | Sequence of waypoint records or documented FMS route text | Records separated by `;`. No maximum record count/URL length stated. |
| `route-name` | URL-encoded string | Included in new-route grammar; no character/length limit or omitted-value default stated. |
| Waypoint coordinates | Format-specific text, `_` between components | `wgs84-decimal` uses **latitude_longitude**, signed decimal degrees; hemisphere forms also shown. Not longitude-first. |
| Elevation | Number, **meters** | `0.0`, `789.1`, `600` shown. Zero means a supplied numeric elevation, not a documented “unknown altitude” sentinel. No range/default specified. |
| Identifier | String | Examples `WP1`, `WP7`; no length/character rule or default supplied. |
| Name | String | Examples include spaces (`Grass field`). No delimiter-escaping rule inside a record is documented. |

All documented `coordinates` values:

| Format family | Exact values | Documented examples/order |
| --- | --- | --- |
| WGS84 | `wgs84-decimal`, `wgs84-ddmmss`, `wgs84-ddmmdecimal` | Decimal `46.875_7.234`; signed `-46.7618888_-6.61331`; hemisphere `N 46.7618888_E 6.61331`. WGS84 explicitly identified by format. DMS/DDMM grammar beyond the enum names is not specified on this page. |
| UTM/UPS | `utm-std`, `utm-band`, `ups` | Listed as supported, but no full zone/hemisphere/component grammar on this page. Do not invent one. |
| MGRS | `mgrs100`, `mgrs10`, `mgrs1` | `32TLS177814`, `32TLS17748147`, `32TLS1774981470` respectively. Precision implied by names/examples, not a stated numeric range contract. |
| National grids | `swiss`, `uk`, `rt90`, `sweref99tm`, `irish`, `nzgd1949`, `nzgd2000` | Examples: `536950_179300`, `542740_180485`, `6158316_1346335`, `6154998_397217`, `315054_242612`, `2472155_5746387`, `1562158_5184773` respectively. These are not lat/lon degrees; axis order varies by grid. Preserve the specified grid representation rather than reusing latitude-first. |

The manual explicitly says parameters must be URL-encoded for external use. Compose record delimiters, then encode the query value once. It does **not** define how a literal comma or semicolon inside a waypoint name is escaped after query decoding; percent-encoding alone may not solve the inner-record ambiguity. Do not claim arbitrary punctuation is safe without testing/vendor confirmation. `+` versus `%20` decoding is likewise not documented.

Decoded official example:

```text
airnavpro://direct-to?coordinates=wgs84-decimal&location=46.875_7.234,0.0,WP1,Grass field
```

Encoded equivalent for controlled input (app acceptance not tested):

```text
airnavpro://direct-to?coordinates=wgs84-decimal&location=46.875_7.234%2C0.0%2CWP1%2CGrass%20field
```

No explicit coordinate ranges, finite-number checks, waypoint/route name limits, origin fallback rules, or error callbacks are supplied in the URL documentation. Use the format's valid coordinates, but distinguish general geographic validity from documented app parser enforcement.

## File-based app launch/import

The same official [Import / Export Data](https://airnavigation.aero/manual/en/html/manual/import-export-data.html) page documents Share/Open With into Air Navigation Pro for supported files: routes (GPX/GPXA export), waypoints (GPX and app format), aircraft profiles (ACP), PDF documents, KML points/lines/polygons, and custom maps MBTiles/GeoTIFF (Smart Advanced). Recorded flights export KML/GPX; logbook export includes text attachment. Export support alone does not establish every import MIME type.

No exact Android Intent extras/MIME allowlist or iOS UTI matrix is published on that page. No source repository for the app's launch parser was identified, so no source-level inference is claimed. Embedded Web Server, WebDAV file management and Air Navigation Manager backend APIs are deliberately excluded from the URL-launch contract.

## Comparison with map_launcher

Local sources: [`airnav_pro.dart`](../../lib/src/maps/airnav_pro.dart), [`map_app.dart`](../../lib/src/maps/map_app.dart), [`url_builder.dart`](../../lib/src/utils/url_builder.dart), [Android queries](../../android/src/main/AndroidManifest.xml), [iOS example plist](../../example/ios/Runner/Info.plist).

| Existing behavior | Assessment |
| --- | --- |
| Marker emits `direct-to`, `coordinates=wgs84-decimal`, `location=lat_lon,0.0` | **Concrete semantic mismatch with official action description:** “marker” starts direct-to navigation if accepted. Source comment “marker only” is misleading. |
| Location record omits identifier and name | **Underdocumented/truncated payload**, not proven invalid. Official grammar shows four fields, wrapper sends two. Needs installed-app test/vendor clarification. Title ignored. |
| Elevation fixed `0.0` | Sends a real zero-meter value; docs do not identify it as unknown. Wrapper has no altitude field. |
| `supportsDirectionsCoords=false`, but directions builder returns same direct-to URL | Capability/model inconsistency relative to aviation navigation contract; disabling directions does not make marker action passive. Ordinary driving/walking/transit/bicycling do not describe this app's aviation navigation. |
| Origin, waypoints, mode, zoom ignored | Omitted route/waypoint features; zoom and road modes not documented launch fields. `new-route` supports ordered points without a road-mode enum. |
| No search/web URL methods, `hasUniversalLink=false` | Conservative wrapper limitation. Android HTTPS native dispatch remains unverified, not a certified web fallback. |
| App Store ID `304684223` | **Concrete identity mismatch** with current official Apple product `301046057`. Android package correct. |

## Proposed validation inputs

1. Compare wrapper's two-field `location=46.875_7.234,0.0` with full `46.875_7.234,125.5,WP1,Grass field`. Check whether each is accepted, whether a route replaces current state, and which altitude/name is retained. Do this on the ground, not during flight.
2. Invoke both iOS custom scheme and Android HTTPS/custom scheme on cold/warm current releases. Confirm app association and actual action, not just browser success. Repeat with trial expired and active subscription.
3. Use `-33.8688_151.2093` to expose order/sign mistakes; zero elevation versus nonzero meters; malformed format, missing required keys, empty name/id, two and three ordered route waypoints.
4. Encode `A&B + café/港` and names containing comma/semicolon separately to discover outer-query versus inner-record parsing. `%20` versus `+` must be tested rather than assumed equivalent.
5. Compare `add-waypoints` (database mutation), `new-route` (load route) and `direct-to` (navigate) with separate expectations. Do not model all three as markers.
6. Assert store URL points to `301046057`; verify no app can be identified merely from a stale URL or absent lookup result.

No app behavior, subscription gating or platform URL-registration equivalence was verified. The official manual is strong evidence for command semantics but incomplete for defaults/limits, Android HTTPS routing, and permissive truncated records.
