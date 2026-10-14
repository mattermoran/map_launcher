# Air Navigation Pro

Checked: **2026-10-13**. No flight-navigation or native-device execution was performed.

## Plugin behavior

**Metadata only: all launch builders return null.** Coordinate markers and directions are disabled on both platforms. The official [Direct-To manual](https://airnavigation.aero/manual/en/html/manual/import-export-data.html#direct-to) says the command instantly navigates, not passively displays a marker. No safe display-only contract is established, and `add-waypoints` mutates the database. The plugin retains discovery scheme `airnavpro://`, Android package `com.xample.airnavigation` and Apple ID `301046057`. Lack of an established passive marker is an integration limitation, not proof that no private display API exists.

## Sources and identity

Primary contract: official [Import / Export Data → Import via URL](https://airnavigation.aero/manual/en/html/manual/import-export-data.html#import-via-url), manual **8.4.150** (no page modification date supplied). This is separate from the manager REST API.

| Platform | Identity / release snapshot | Launch scope |
| --- | --- | --- |
| Android | [`com.xample.airnavigation`](https://play.google.com/store/apps/details?id=com.xample.airnavigation), Air Navigation SA; listing updated 2026-07-17 | Matches builder/package query. |
| iOS | Apple [`301046057`](https://apps.apple.com/us/app/air-navigation-pro/id301046057), bundle `ch.xample.Airnav`; Apple [lookup](https://itunes.apple.com/lookup?id=301046057): version **8.4.176**, released **2026-09-22T16:31:47Z** | Matches plugin metadata. |
| Custom scheme | `airnavpro://<command>?<query>` in official manual | Matches plugin iOS discovery scheme; launch remains disabled. Manual gives no platform-by-platform scheme-registration matrix. |
| Android HTTPS | No established external-launch format | Official URL docs specify `airnavpro://`, not an HTTPS direct-to or universal-link/browser contract. |
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

## Integration limits

Local sources: [`airnav_pro.dart`](../../lib/src/maps/airnav_pro.dart), [`map_app.dart`](../../lib/src/maps/map_app.dart), [`url_builder.dart`](../../lib/src/utils/url_builder.dart), [example Android queries](../../example/android/app/src/main/AndroidManifest.xml), [iOS example plist](../../example/ios/Runner/Info.plist).

Ordinary driving/walking/transit/bicycling do not model aviation navigation. `new-route`, `add-waypoints` and `direct-to` are distinct, state-changing operations, none implemented by the plugin. The manual is strong evidence for command semantics but leaves defaults, limits, subscription gating, platform registration and truncated-record acceptance unresolved.
