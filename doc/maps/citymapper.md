# Citymapper

The plugin opens native directions on Android and iOS with destination coordinates and an optional coordinate origin; titles become `endname`/`startname`. Explicit travel modes and nonempty waypoints are rejected. Browser URLs and address labels are not exposed. Marker capability is false: the low-level marker builder opens directions, not a pin. Discovery uses Android `com.citymapper.app.release`, App Store `469463298`, and iOS `citymapper`; callers must declare the iOS query scheme.

Reference check: 2026-10-13. Protocol details below include provider features not exposed by the plugin.

## Sources

| Source | Purpose / caveat |
| --- | --- |
| [Launch Citymapper for Directions](https://citymapper.com/news/2386/launch-citymapper-for-directions) | Public HTTPS/native directions and six fields; no protocol version stated. |
| [Former tools URL](https://citymapper.com/tools/1053/launch-citymapper-for-directions) | Inaccessible: HTTP 404. The shorter `/tools/1053/` returns “Not Found”; `/news/1053/launch-citymapper-for-directions` returned HTTP 500. Do not silently attribute historical options to the current article. |
| [SDKs and APIs come to an end](https://citymapper.com/news/2596/sdks-and-apis-come-to-an-end) | Primary. `/powers` redirects through `/enterprise` to this notice. Self-service SDK/API shutdown effective **2023-06-23**; existing enterprise contracts excepted. |
| [2019 arriveby report](https://stackoverflow.com/questions/57251461/citymapper-url-ignoring-arriveby-parameter) | Secondary-only, question 2019-07-29, answer edited 2019-07-31; historical web behavior, not a current app contract. |

## Public launch actions and complete documented fields

Reference: Launch Citymapper for Directions.

| Action | Form | Semantics / platform |
| --- | --- | --- |
| Plan directions | `https://citymapper.com/directions?endcoord=<lat>,<lon>` | Cross-platform link; article says it launches the app and “works for all platforms.” Exact installed/uninstalled browser fallback and OS association behavior need tests. |
| Plan directions in native app | `citymapper://directions?endcoord=<lat>,<lon>` | Same fields as HTTPS. Article recommends this for older iOS and to force native app opening. No Android-specific intent extras or explicit `intent://` syntax published. |

| Field | Required / type | Values, defaults, constraints |
| --- | --- | --- |
| `endcoord` | **Required**, comma-delimited latitude,longitude | Decimal latitude then longitude; percent-encoded comma `%2C` shown. The only absolutely necessary field. Destination cannot be supplied solely by its name/address. |
| `endname` | Optional string | Business name or nickname; display label, not a place ID or geocoding input. No default label or length limit specified. |
| `endaddress` | Optional string | Street address shown at trip end to help find the door; does not replace coordinates. No length limit specified. |
| `startcoord` | Optional coordinate pair, same syntax | Explicit origin; omitted origin uses current location. Location-permission failure behavior unspecified. |
| `startname` | Optional string | Origin label, analogous to `endname`; independent label-only origin behavior unspecified. |
| `startaddress` | Optional string | Origin street-address label, analogous to `endaddress`. |

Coordinates look like ordinary geographic decimal degrees; **WGS84 is inferred**, not named in the guide. It gives no numeric bounds or precision limit. The library separately enforces finite latitude −90…90 and longitude −180…180 in `LocationCoords`; those are library constraints, not vendor-documented limits.

Encode each query value once as UTF-8 URI data. The reference explicitly encodes spaces as `%20` and commas as `%2C`. Keep structural `?`, `&`, and `=` outside values. A literal `&`, `+`, `#`, `%`, or non-ASCII character in a name must not become query syntax. Whether the native app accepts form-style `+` for spaces is runtime-unverified.

Example derived from the documented contract, not an executed launch:

```text
https://citymapper.com/directions?startcoord=51.50685%2C-0.142927&startname=Green%20Park&endcoord=51.532499%2C-0.10579&endname=Angel
```

### Historical and undocumented fields

| Category | Finding and source |
| --- | --- |
| Date/time | The secondary 2019 report uses `arriveby=2019-08-06T21:00+01:00` and describes day/result failures. Its suggested six-day limit is speculation. Current launch guide lists neither `arriveby` nor departure time. |
| Modes / preferences | No launch field for walking, cycling, transit, wheelchair access, avoidances, speed or alternatives; in-app choices are not URL fields. |
| IDs / stops / multiple points | No place ID, station ID, route ID, intermediate stops, waypoints, or multiple destinations documented. |
| Map / navigation lifecycle | No standalone marker, search-only action, zoom, heading, automatic GO/navigation start, or stop-navigation action documented. Directions mean journey planning, not guaranteed turn-by-turn activation. |
| Callbacks / credentials | No callback, x-callback-url, return URL, API key, partner ID, signature, login or enrollment field specified. |

The shutdown notice concerns self-service REST/embedded SDKs, not a stated retirement of public links. The launch article's closing SDK advertisement is stale; routing API fields are not native launch fields.

## Plugin limitations and code references

The shared encoder omits blank values and uses form-style `+` spaces, whereas the provider examples use `%20`; native equivalence has not been established. HTTPS app handoff, coverage and unavailable-location behavior are not established by URL construction tests.

Implementation: [`citymapper.dart`](../../lib/src/maps/citymapper.dart), [capabilities](../../lib/src/maps/map_app.dart), [coordinate model](../../lib/src/models/location.dart), [encoding](../../lib/src/utils/url_builder.dart). URL tests: [`nav_only_maps_test.dart`](../../test/maps/nav_only_maps_test.dart).
