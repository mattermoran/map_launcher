# Google Maps Go

The Android-only integration targets `com.google.android.apps.mapslite`, emits coordinate `geo:` markers and `google.navigation:?q=…` directions, and has no HTTPS fallback. Explicit origins are unsupported and are not serialized; zoom and waypoints are not serialized. Mode is the first enum letter (`d/w/b/t`), with all modes inherited as supported. No Go-specific external-intent contract has been established: full Maps intent syntax below is a comparison reference, not evidence of Go acceptance.

Reference check: 2026-10-13. Full Maps Android reference updated 2026-10-06; the Go help recheck failed, so product details retain the earlier reference evidence.

## Sources and product boundaries

| Source | Date/version and what it establishes |
| --- | --- |
| [Use a lighter version of Google Maps](https://support.google.com/maps/answer/7566112?hl=en) | Product requirements/features: separate app, preinstalled on Android Oreo Go devices and available from Play; Chrome required. |
| [Maps Go Play link](https://play.google.com/store/apps/details?id=com.google.android.apps.mapslite) | Package `com.google.android.apps.mapslite`, as linked by official help. Store listing was not independently used to infer intent filters. |
| [Navigation for Maps Go Play link](https://play.google.com/store/apps/details?id=com.google.android.apps.navlite) | **Separate companion** `com.google.android.apps.navlite`, linked by official help as required for turn-by-turn navigation. No external companion-launch grammar supplied by that help page. |
| [Standard Google Maps Android intents](https://developer.android.com/guide/components/google-maps-intents) | Full Maps package **`com.google.android.apps.maps`**; comparison grammar, not Go compatibility. |
| [Universal Maps URLs](https://developers.google.com/maps/documentation/urls/guide) | `api=1`; standard Maps/browser dispatch, not guaranteed Go targeting. |

The official Go help documents interactive search, place information, driving/transit/walking/cycling directions, region-dependent two-wheeler directions, departure/arrival-time selection and avoiding ferries/tolls/highways. **Interactive features are not an external parameter contract.** In particular, UI transit directions do not establish `google.navigation:mode=t`.

Go cannot share real-time location, download offline areas, report data problems, edit place information, measure distance or add persistent private labels, according to help. The last limitation does not establish whether a transient URI label renders. Navigation requires the companion and is region-dependent. Do not treat Go, Navigation for Go, full Maps or Android Automotive as one product.

## Native URL formats and fields

Every provider-contract row below comes from the full Maps Android reference; Go acceptance is unconfirmed.

| URI / field | Full Maps documented contract | Our Go builder / confidence |
| --- | --- | --- |
| `geo:latitude,longitude` | Displays centered map; latitude first, longitude second. | Uses `geo:0,0` with search `q`; reference-compatible syntax, **Go source-inferred**. |
| `q` on `geo:` | Required for search. Name/address/category, or `lat,lon(label)`; label optional and only documented for coordinate queries. Coordinates can bias categorical search; 0,0 used for unspecified search center. | Coordinate `q`, optional parenthesized `title`; no text-search builder/capability. |
| `z` on `geo:` | Optional zoom 0–21, upper limit depends on map data; no default stated. | `zoom` argument **ignored**. Raw extra `z` serializable, not confirmed for Go. |
| `google.navigation:q=…` | Destination lat/lon or address; always navigates from current location. **No question mark after colon**. Ambiguous address picks first result. | Emits **`google.navigation:?q=lat,lng`** because shared `buildUrl` inserts `?`; diverges from documented full Maps grammar. Go runtime behavior unknown. |
| Navigation `mode` | Optional `d` driving (**default**), `b` bicycle, `l` two-wheeler, `w` walking. No transit mode. | First character of enum name: driving `d`, walking `w`, bicycling `b`, **transit `t`**. Go inherits “all modes supported”; transit is an unsupported assumption even against reference grammar. |
| Navigation `avoid` | Optional concatenated `t` tolls, `h` highways, `f` ferries, e.g. `tf`. | No typed option. Raw extras can serialize it; acceptance by Go unverified. |

Coordinate order is **lat,lon**, decimal degrees. Our `LocationCoords` enforces finite latitude −90…90, longitude −180…180; URL sources do not explicitly name a datum. Values are encoded by Dart `Uri`: commas `%2C`, spaces `+`, literal `+` `%2B`, ampersand `%26`. Full Maps docs allow `%20` or `+` spaces; that is not Go-specific validation. No Go URL length, precision, query-length, zoom range or waypoint limit was found.

Native Android launches are `ACTION_VIEW` with package `com.google.android.apps.mapslite`; generic URI compatibility does not prove that package resolves it. The library checks package installation for discovery, not whether Go has an activity for a particular marker/navigation URI or whether Navigation for Go is present. No Go iOS app/scheme contract was established.

## Universal links and additional launch actions

There is **no Go-specific universal-link contract established by the sources**. Our Go `markerUrl` and `directionsUrl` return null and `hasUniversalLink=false`; web/desktop are intentionally unavailable. Standard Google URLs are a possible generic Maps/browser fallback, but would not preserve guaranteed Go targeting.

The complete standard Google URL/intent inventory is in [Google Maps](google.md), including required `api=1`, search/Place IDs, directions, ordered waypoints (3 mobile-browser/9 otherwise), navigation action, map display, Street View, native iOS and Automotive. These are **not Go capabilities** merely because Go uses Chrome. No Go public URL fields were found for origin, waypoints, place identifiers, callbacks, favorites, map layers, time selection or two-wheeler choice.

Other full-Maps actions, not established Go support:

- `geo:` plain display and categorical/address search.
- `google.navigation:` text destination and `mode=l`, `avoid=…`.
- `google.streetview:cbll=…` / `panoid=…` with camera `cbp`; no evidence Go resolves this.
- `https://plus.codes/…` location links and universal HTTPS map/panorama actions; browser behavior is not Go app dispatch.

The help's “add a stop” UI tip and date/time controls supply no external waypoint or timing grammar.

## Plugin limitations

Sources: [`google_go.dart`](../../lib/src/maps/google_go.dart), [`map_app.dart`](../../lib/src/maps/map_app.dart), [`directions_request.dart`](../../lib/src/requests/directions_request.dart), [`launch_helper.dart`](../../lib/src/utils/launch_helper.dart), [`google_extra.dart`](../../lib/src/extras/google_extra.dart), [`Android launcher`](../../android/src/main/kotlin/dev/fluttered/map_launcher/MapLauncherPlugin.kt).

| Plugin behavior | Limit |
| --- | --- |
| Coordinate marker/directions advertised; text search and waypoints false | Go's protocol is unconfirmed. Nonempty waypoints are rejected at request level, ignored by direct builders. |
| All enum travel modes inherited as supported | Transit emits `t`, absent from full Maps navigation grammar; no Go-specific mode contract is established. |
| Explicit coordinate origin unsupported | Capability is false; request validation rejects it. Direct builders do not serialize origin. |
| `google.navigation:?q=` | Differs from full Maps opaque `google.navigation:q=` grammar; Go acceptance is unknown. |
| Direct scheme getters ignore `platform` | Can return Android URIs on iOS despite Android-only discovery metadata; explicit `show(map: .googleGo)` can attempt launch. |
| No Go extras type | Raw extras accepted; `GoogleExtra` Place IDs and `dir_action` belong to universal URLs, not these native families. |
| No HTTPS fallback | If package-targeted launch fails, `MapLaunchException`; there is no retry through `navlite`, full Maps or browser. Merely installing Go is not proof navigation can start. |

Extras apply during launch preparation, not getters. Identical built-in values are retained once; conflicts exclude a discovery entry or produce `MapLaunchException` on explicit launch. Extras cannot remove the question mark, change package/action or establish companion availability. `GoogleExtra` universal fields do not apply to these native URI families.

## Reference limits

Go's receiving activities, companion dispatch and supported external modes remain unknown. Installation detection does not establish URI resolution, and full Maps resolving an unqualified intent does not establish Go support. [Shared mobile URL tests](../../test/maps/mobile_only_maps_test.dart) cover serialization only.
