# Apple Maps

The plugin uses legacy HTTPS root links for coordinate markers, text search and directions with coordinate/text origins. It emits `dirflg=d/w/r` for driving/walking/transit; cycling and waypoints are rejected. `AppleExtra` supplies map type and nearby search bias. Apple Maps is treated as always available on iOS; there is no native scheme override. Modern action paths below are provider features, not plugin builders.

Reference check: 2026-10-02.

## Sources

- [Unified Maps URLs](https://developer.apple.com/documentation/mapkit/unified-map-urls) — current primary source; no update date displayed. Availability: iOS 18.4+, macOS 15.4+, watchOS 11.4+. This is external URL documentation, despite living under MapKit.
- [Map Links, Apple URL Scheme Reference](https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html) — archived compatibility interface, updated 2017-09-19.
- [Default navigation app](https://developer.apple.com/documentation/mapkit/preparing-your-app-to-be-the-default-navigation-app) — primary search-result evidence for `geo-navigation://`; not evidence that it always targets Apple Maps. EU iOS/iPadOS 18.4+, Japan iOS 26.2+ stated in the source.

## Universal links: current interface

Base: `https://maps.apple.com`. Paths select independent actions; adding modern keys to the legacy root URL is not a documented migration. Coordinates are decimal floating-point **latitude,longitude**. These URL pages do not explicitly name the geodetic datum; do not infer a coordinate conversion from SDK documentation. Text must be encoded as URL query values; examples use `%20`. There is no published URL-length or waypoint-count limit in this source.

### Framing and search

Reference: Unified Maps URLs, framing/search tables.

| Path / fields | Requirement, syntax and behavior |
| --- | --- |
| `/frame`: `center` | Optional coordinate pair; required when setting camera properties. Center alone is a documented action. |
| `/frame`: `span` | Optional pair of angular deltas. Prose says longitude and latitude, while the linked coordinate-span initializer uses latitude delta then longitude delta. **Order is ambiguous in this page**; examples use equal values. Do not resolve by assumption. |
| `/frame`: `mode` | Optional `follow`, `follow-with-heading`, `none`. Tracking takes precedence over camera properties. No default stated. |
| `/frame`: `heading`, `pitch`, `distance` | Optional camera orientation, vertical angle and apparent viewer distance; numeric examples. Ranges/defaults are not specified; degree notation appears in examples, but distance prose/example numbers disagree. Camera properties override `span`. |
| `/frame`: `map` | Optional `explore`, `driving`, `transit`, `satellite`, `hybrid`; default not stated. |
| `/search`: `query` | Search text: category, place, address or city. Necessary to express the requested search; no formal requiredness table. |
| `/search`: `center` | Optional coordinate bias; defaults to the person's location. |
| `/search`: `span` | Optional search-area angular deltas; same ordering ambiguity as frame. Not a distance in meters. |

### Place cards, Look Around, guides and reports

Reference: Unified Maps URLs, place/action tables.

| Path / fields | Requirement, syntax and behavior |
| --- | --- |
| `/place`: `coordinate`, `address`, `place-id` | Alternative location selectors: lat/lon pair, address string, Apple POI identifier. Examples use each independently; precedence when combined is not stated. |
| `/place`: `name` | Optional custom place-card name when a card is available; documented for a dropped coordinate pin. |
| `/place`: `map` | Optional `explore`, `driving`, `transit`, `satellite`, `hybrid`. |
| `/place?place-id=my-location` | Special identifier; location permission required. |
| `/place?place-id=parked-car` | Special identifier; Maps permission to record parking required. |
| `/look-around`: `coordinate`, `address`, `place-id` | Select initial Look Around location using one of these selectors. No documented heading, pitch, panorama ID or callback fields here. Coverage still matters. |
| `/guides` | Opens guides/curated places; no parameters documented. |
| `/report-a-problem`: `coordinate`, `address`, `place-id` | Location selectors; opens a report sheet for the person to provide details, not an automatic report submission API. No combined-selector precedence stated. |
| Short links on `maps.apple` | Shared links can be shortened; recover full URL from HTTP 301 response. No short-link creation API documented. |

Apple Place IDs are not Google Place IDs. The documentation links a Place ID lookup tool and SDKs as ways to discover IDs; that does not make unrelated SDK properties URL fields.

### Directions and navigation

Directions use `/directions`; reference: Unified Maps URLs, directions table.

| Field | Requirement / syntax / semantics |
| --- | --- |
| `source` | Optional address, coordinate or place name; omitted uses person's current location. |
| `destination` | Address, coordinate or place name. All destination-specific examples provide it; empty-destination behavior is not documented. |
| `source-place-id` | Optional Apple Place ID; **requires `source`**. |
| `destination-place-id` | Optional Apple Place ID; **requires `destination`**. |
| `waypoint` | Optional intermediate address, coordinate or place name. **Repeat the query key** for multiple stops; not a pipe-delimited string. No maximum stated. |
| `waypoint-place-id` | Optional Apple Place ID for waypoint. Pairing rules for repeated waypoints/IDs are not fully specified; do not invent positional empty-slot semantics. |
| `mode` | Optional `driving`, `walking`, `transit`, `cycling`; no default specified. This is `cycling`, not our enum's `bicycling`. |
| `avoid` | Optional comma-separated `tolls`, `highways`, `busy-roads`, `stairs`; options apply only to respective transport modes. A walking example also uses `hills`, **documented in an example only**, absent from the table. Full mode/option matrix is unspecified. |
| `transit-preferences` | Optional comma-separated `bus`, `subway`, `commuter`, `ferry`; meaningful for transit. |
| `start` | Optional integer delay in seconds before navigation begins. No allowed range, minimum, default, origin restrictions or confirmation behavior stated. |

The overview mentions multistop driving, walking and transit, but concrete multistop examples are driving; the complete mode/waypoint matrix is unspecified.

## Legacy root links and native schemes

The archived specification uses `http://maps.apple.com/?…`, not a `maps:` scheme; the plugin uses HTTPS. Neither URL reference defines a separate `maps://` contract or callbacks.

Reference: archived Map Links table.

| Field | Requirement / values / constraints |
| --- | --- |
| `t` | Optional `m` standard, `k` satellite, `h` hybrid, `r` transit. Unrecognized/omitted uses current map type. |
| `q` | Encoded search text; `*` unsupported. With `ll` or `address`, can label a location; Maps tries to match the name there. |
| `address` | Address string for displaying a location rather than general search. `ll` takes precedence if both exist. |
| `ll` | Optional center lat/lon pair; can be a pin location **when `q` supplies a name**. |
| `near` | Optional lat/lon search hint; used if `sll` missing or incomplete. |
| `sll` | Optional lat/lon search location, alone or with `q`. |
| `z` | Optional floating-point zoom **2–21**; table requires `ll`; incompatible with `spn` or `sspn`. Examples inconsistently use `sll` plus `z` without `ll`. |
| `spn` | Optional latitude-delta,longitude-delta span around `ll`; incompatible with `z`. |
| `sspn` | Optional latitude-delta,longitude-delta search span around `sll`; incompatible with `z`. |
| `saddr` | Optional geocodable origin address; omission means “here”. Our coordinate strings are source-inferred usage, not separately typed in this archived table. |
| `daddr` | Required for directions; geocodable destination address. |
| `dirflg` | Optional `d` driving, `w` walking, `r` transit. Unknown value ignored; omission uses preferred/previous transport type. **`b` is absent**. |

The archive's examples also use `t=s`, contrary to the enumerated table. Treat those as documentation inconsistencies, not additional validated values.

`geo-navigation://` targets the default navigation app, not specifically Apple Maps. The default-navigation reference describes `/directions` with `source`, `destination`, repeated `waypoint` (address/place/coordinates), and `/place` with `coordinate` or `address`. The plugin does not use it.

## Plugin limitations

Sources: [`apple_maps.dart`](../../lib/src/maps/apple_maps.dart), [`apple_extra.dart`](../../lib/src/extras/apple_extra.dart), [`map_app.dart`](../../lib/src/maps/map_app.dart), [`directions_request.dart`](../../lib/src/requests/directions_request.dart), [`launch_helper.dart`](../../lib/src/utils/launch_helper.dart), [`url_builder.dart`](../../lib/src/utils/url_builder.dart).

| Plugin behavior | Limit |
| --- | --- |
| Marker `/?ll=lat,lng&q=title&z=int`; `q` only with title | Without a name, legacy `ll` documents centering rather than guaranteed pin placement. Modern `/place` is not exposed. |
| Search `/?q=text`; directions `/?daddr=…&saddr=…&dirflg=…` | Matches archived contract for search/address directions; text origin appended under `saddr`. No native scheme override. |
| Bicycling unsupported | Getters return null; discovery excludes Apple and explicit launch reports `MapLaunchException`. Automatic launch can try Google. Modern `/directions?mode=cycling` is a separate contract. |
| Waypoints unsupported | Requests reject nonempty waypoints; modern repeated keys cannot be represented by `Map<String,String>` extras. |
| `AppleExtra(display, near)` emits `t=m/k/h/r`, `near=lat,lng` | Correct archived values; no typed current `map`, camera, IDs, route preferences, `start` or waypoint support. |
| Integer zoom, no range/combination checks | Omitted fractional zoom; invalid 1/22 or `extra` spans can violate archived constraints. |
| Always available on iOS; HTTPS launch | May open web content; modern paths have separate OS minima and are not emitted by the plugin. |

Extras apply during launch preparation, not URL getters. Use request
`providerExtras: {.apple: AppleExtra(...)}` for automatic launch or discovery;
these are conditional Apple preferences, not requirements for a Google fallback.
Nonempty raw extras require explicit `show(map: .apple, extra: ...)`. Show extras
override request extras, which override provider options; identical built-in
values are retained once and conflicts use `MapConfigurationError`. Picker
entries capture validated options and their parameterless `show()` stays Apple.
Existing URL bytes are preserved. The builder filters blank values, while launch
extras preserve them. Extras cannot select modern action paths or represent
repeated waypoint keys. Retry requires confirmed non-handoff; blocked or unknown
outcomes are terminal.

## Reference limits

Source examples contain malformed percent escapes, `heading=18a0`, distance prose/number disagreement and inconsistent visible versus linked coordinates. Parameter tables take precedence. Datum, complete mode/avoid compatibility and numeric camera limits are unspecified. The library separately validates finite latitude −90…90 and longitude −180…180. [`apple_maps_test.dart`](../../test/maps/apple_maps_test.dart) covers generated URLs, not native behavior.
