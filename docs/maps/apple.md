# Apple Maps external-launch audit

**Checked:** 2026-10-02. **Status:** current primary documentation plus an explicitly archived compatibility interface; no real-app validation. Baseline: fetched `origin/master` and verified it contains [8aa7a6e](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131); checkout matched that commit.

## Sources and confidence

- [Unified Maps URLs](https://developer.apple.com/documentation/mapkit/unified-map-urls) — current primary source; no update date displayed. Availability: iOS 18.4+, macOS 15.4+, watchOS 11.4+. This is external URL documentation, despite living under MapKit.
- [Map Links, Apple URL Scheme Reference](https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html) — **archived**, updated 2017-09-19. Page-reader request failed, but direct HTTPS retrieval succeeded and the entire parameter table was inspected.
- [Default navigation app](https://developer.apple.com/documentation/mapkit/preparing-your-app-to-be-the-default-navigation-app) — primary search-result evidence for `geo-navigation://`; not evidence that it always targets Apple Maps. EU iOS/iPadOS 18.4+, Japan iOS 26.2+ stated in the source.

“Documented” below means provider URL documentation, not observed app behavior. “Source-inferred” means our code establishes the behavior. Unspecified ranges/defaults are not supplied from embedded MapKit or REST APIs. No secondary-only parameter is promoted to supported status.

## Universal links: current interface

Base: `https://maps.apple.com`. Paths select independent actions; adding modern keys to the legacy root URL is not a documented migration. Coordinates are decimal floating-point **latitude,longitude**. These URL pages do not explicitly name the geodetic datum; do not infer a coordinate conversion from SDK documentation. Text must be encoded as URL query values; examples use `%20`. There is no published URL-length or waypoint-count limit in this source.

### Framing and search

Source: [unified URL framing/search tables](https://developer.apple.com/documentation/mapkit/unified-map-urls).

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

Source: [unified URL place/action tables](https://developer.apple.com/documentation/mapkit/unified-map-urls).

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

Source: [unified URL directions table and examples](https://developer.apple.com/documentation/mapkit/unified-map-urls).

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

The article's overview mentions multistop driving, walking and transit, but concrete multistop examples are driving. It does not give a complete mode/waypoint support matrix. Test combinations before promising equivalence across OS versions or browser fallback.

## Legacy root links and native schemes

The archived specification explicitly uses regular `http://maps.apple.com/?…`, **not a `maps:` scheme**. Our builder uses HTTPS. The modern article also uses HTTPS; neither audited page establishes a separate `maps://` parameter contract. No callbacks are documented on either audited Apple Maps URL interface.

Source: [archived Map Links table](https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html).

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

`geo-navigation://` is a separate **default-navigation-app** handoff, not Apple-specific targeting. Primary search evidence describes `/directions` with `source`, `destination`, repeated `waypoint` (address/place/coordinates), and `/place` with `coordinate` or `address`. Our Apple builder does not use it. Full behavioral/OS routing validation remains outside this audit; do not substitute it silently for Apple Maps.

## Exact implementation comparison

Sources: [`apple_maps.dart`](../../lib/src/maps/apple_maps.dart), [`apple_extra.dart`](../../lib/src/extras/apple_extra.dart), [`map_app.dart`](../../lib/src/maps/map_app.dart), [`directions_request.dart`](../../lib/src/requests/directions_request.dart), [`launch_helper.dart`](../../lib/src/utils/launch_helper.dart), [`url_builder.dart`](../../lib/src/utils/url_builder.dart).

| Current code | Assessment / actionable consequence |
| --- | --- |
| Marker `https://maps.apple.com/?ll=lat,lng&q=title&z=int`; `q` only with title | **Semantic gap:** unnamed “marker” is only documented as centering, not guaranteed pin placement. Consider current `/place?coordinate=…` for guaranteed place action on supported OS versions; test unnamed legacy pins. |
| Search `/?q=text`; directions `/?daddr=…&saddr=…&dirflg=…` | Matches archived contract for search/address directions; text origin appended under `saddr`. No native scheme override. |
| All four enum modes accepted; bicycling emits `dirflg=b` | **Undocumented legacy value**, not a proven runtime defect. Modern documented spelling is `/directions?mode=cycling`. Gate/migrate or explicitly document runtime evidence before promising cycling. |
| `supportsWaypoints=false`; nonempty waypoint request rejected | **Omitted current capability**, not a bug in the legacy contract. Modern repeated `waypoint` keys need a new path and repeated-key representation. `Map<String,String>` extras cannot represent repeated keys. |
| `AppleExtra(display, near)` emits `t=m/k/h/r`, `near=lat,lng` | Correct archived values; no typed current `map`, camera, IDs, route preferences, `start` or waypoint support. |
| Integer zoom, no range/combination checks | Omitted fractional zoom; invalid 1/22 or `extra` spans can violate archived constraints. |
| Universal capability; always available on iOS; no iOS scheme | Repository assumption is not proof of installed app or modern-path support on every device/browser. Universal URLs can open web content; new-path platform minima must be accounted for. |

Extras append at launch, not in `getUrl()`/`getUniversalUrl()`/`getSchemeUrl()`. They are query strings, not native SDK options. Request/show extras merge with show values winning each other, but **do not replace builder keys**: `extra={'q':'other'}` appends a second `q`. Provider duplicate-key precedence is unspecified. `buildUrl` filters blank values and uses Dart URI encoding; launch-time append preserves blank extras. Modern action paths cannot be selected through extras.

## Verification gaps and recommended cases

- Existing [`apple_maps_test.dart`](../../test/maps/apple_maps_test.dart) checks URL construction, not app behavior; its all-modes test only checks that `dirflg` exists. Add exact `d/w/r` expectations and explicitly track legacy cycling uncertainty.
- Distinguish marker with/without title at `59.3293,18.0686`; test `/place` separately. Do not infer pin behavior from a URL containing `ll`.
- Encode `Café & Ferry + #1` once; decode generated parameters and ensure reserved characters do not become new fields. Exercise coordinate boundaries already enforced by `LocationCoords` (finite latitude −90…90, longitude −180…180).
- Test legacy zoom 2/21 versus 1/22, and span conflicts. Test unequal modern spans `0.02,0.07` to resolve the provider ambiguity on a real device.
- If migrating, test repeated distinct waypoints, ID companion requirements, omitted source, cycling, tracking-versus-camera precedence, `start` opt-in and older-OS/browser fallback. Do not silently drop stops.
- Source inconsistencies include malformed percent escapes, `heading=18a0`, distance prose/number disagreement and inconsistent visible versus linked coordinates. Parameter tables are stronger evidence than those example URLs.
- No Apple app, OS-version matrix, permission state, browser fallback, navigation start or callback behavior was tested. Archived page access was recovered; current full URL page was accessible. No fixed datum, complete mode/avoid matrix or numeric camera limits were established.
