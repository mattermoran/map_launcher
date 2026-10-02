# Google Maps Go external-launch audit

**Checked:** 2026-10-02. **Status:** primary product documentation available, **no Go-specific public external-intent specification established**; our native builders are source-inferred and runtime-unverified. Fetched `origin/master` and verified it includes [8aa7a6e](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131); checkout matched it.

## Sources and product boundaries

| Source | Date/version and what it establishes |
| --- | --- |
| [Use a lighter version of Google Maps](https://support.google.com/maps/answer/7566112?hl=en) | Fresh full retrieval; no update date displayed. Go is a **separate app**, preinstalled on Android Oreo Go devices and available from Play. Chrome required. |
| [Maps Go Play link](https://play.google.com/store/apps/details?id=com.google.android.apps.mapslite) | Package `com.google.android.apps.mapslite`, as linked by official help. Store listing was not independently used to infer intent filters. |
| [Navigation for Maps Go Play link](https://play.google.com/store/apps/details?id=com.google.android.apps.navlite) | **Separate companion** `com.google.android.apps.navlite`, linked by official help as required for turn-by-turn navigation. No external companion-launch grammar supplied by that help page. |
| [Standard Google Maps Android intents](https://developer.android.com/guide/components/google-maps-intents) | Updated **2026-02-26 UTC**; full Google Maps package **`com.google.android.apps.maps`**, not Go. Reference syntax only, not proof of Go compatibility. |
| [Universal Maps URLs](https://developers.google.com/maps/documentation/urls/guide) | Updated **2026-09-28 UTC**, `api=1`; opens standard Maps/browser. Does not promise routing to Go's package. |

The official Go help documents interactive search, place information, driving/transit/walking/cycling directions, region-dependent two-wheeler directions, departure/arrival-time selection and avoiding ferries/tolls/highways. **Interactive features are not an external parameter contract.** In particular, UI transit directions do not establish `google.navigation:mode=t`.

Go cannot share real-time location, download offline areas, report data problems, edit place information, measure distance or add persistent private labels, according to help. The last limitation does not establish whether a transient URI label renders. Navigation requires the companion and is region-dependent. Do not treat Go, Navigation for Go, full Maps or Android Automotive as one product.

## Native URLs: actual implementation versus reference grammar

Sources: [`google_go.dart`](../../lib/src/maps/google_go.dart) and [standard Maps Android intents](https://developer.android.com/guide/components/google-maps-intents). **Every provider-contract row below is documented for full Maps only. Go acceptance is unconfirmed.** This explicit separation prevents manufacturing a Go API from a different product's docs.

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

Additional full-Maps external actions relevant to future investigation, **not established Go support**:

- `geo:` plain display and categorical/address search.
- `google.navigation:` text destination and `mode=l`, `avoid=…`.
- `google.streetview:cbll=…` / `panoid=…` with camera `cbp`; no evidence Go resolves this.
- `https://plus.codes/…` location links and universal HTTPS map/panorama actions; browser behavior is not Go app dispatch.

The Go help's “add a stop” UI tip and date/time controls cannot justify waypoint or departure/arrival deep-link fields. No secondary-only field is asserted as supported, and no REST/embedded SDK field is imported.

## Exact capability and extras comparison

Sources: [`google_go.dart`](../../lib/src/maps/google_go.dart), [`map_app.dart`](../../lib/src/maps/map_app.dart), [`directions_request.dart`](../../lib/src/requests/directions_request.dart), [`launch_helper.dart`](../../lib/src/utils/launch_helper.dart), [`google_extra.dart`](../../lib/src/extras/google_extra.dart), [`Android launcher`](../../android/src/main/kotlin/dev/fluttered/map_launcher/MapLauncherPlugin.kt).

| Implementation | Assessment / action |
| --- | --- |
| Coordinate marker/directions true, text-search false, waypoints false | Coordinate support is source-inferred, not provider-verified. Search could be an omitted feature but needs **Go-specific evidence**, not blindly enabling full Maps syntax. Nonempty waypoints are rejected at request level. |
| All enum travel modes inherited as supported | **Capability/contract mismatch:** transit emits undocumented `t`. Restrict claim until a verified Go contract exists; don't infer supported navigation from transit planning UI. |
| Explicit coordinate origin ignored | **API semantic defect/risk:** caller's route start silently lost. Full Maps native navigation only supports current location; reject/disclose rather than inventing `saddr`. Search origin already rejected. |
| `google.navigation:?q=` | **Documented-reference syntax mismatch**, not proof Go fails at runtime. Prefer reference `google.navigation:q=` only after verifying target package and companion behavior; opaque URI needs a scheme-aware serializer. |
| Methods ignore `platform` and emit geo/navigation on explicit `.ios` calls | **Platform guard gap:** comments say Android-only, but direct scheme getters can return Android URIs on iOS. Normal discovery may omit Go because no iOS installation metadata; direct `show(map: .googleGo)` can still attempt it. |
| No Go extras type | Raw string extras accepted; `GoogleExtra` is universal-only keys (`query_place_id`, origin/destination IDs, `dir_action`) and **not documented for Go or these native URIs**. Do not recommend it by brand similarity. |
| No HTTPS fallback | If package-targeted launch fails, `MapLaunchException`; there is no retry through `navlite`, full Maps or browser. Merely installing Go is not proof navigation can start. |

Extras append during `show()`, not URL getters. Request/show extras merge with each other; builder keys are **not replaced**, so an extra `q` or `mode` yields duplicates with undefined provider precedence. Raw extras cannot remove the extra question mark, change target package, express a new action, establish companion availability or activate unsupported request types.

## Recommended verification and source gaps

- Existing Go cases in [`mobile_only_maps_test.dart`](../../test/maps/mobile_only_maps_test.dart) check scheme substrings and label inclusion; they do not check exact opaque navigation grammar, transit rejection or real package handling.
- Add exact URL tests for `google.navigation:q=59.3293%2C18.0686`, not merely `contains('google.navigation:')`; test default/d/b/w and explicitly reject or mark unsupported transit rather than accepting `t` as a successful test outcome.
- Test explicit distant origin, nonempty waypoints, iOS direct getter versus Android, and no universal fallback. Test literal `+`, ampersand, Unicode and nested label parentheses; don't assert real label display from substring tests.
- Device matrix needed: Go only; Go plus Navigation for Go; full Maps coinstalled; companion only; neither installed; Chrome absent/disabled. Resolve each URI **against the intended package**, then test actual screen/navigation behavior. Never substitute full Maps resolving an unqualified intent as evidence for Go.
- Evaluate zoom and text-search additions separately from defects; investigate provider or manifest evidence before advertising them. Browser fallback should be an explicit generic-Maps product choice, not called Go support.
- Access: official Go help and full Maps specifications were accessible. The substantive gap is **absence of an established Go external-launch contract**, not an inaccessible known spec. No app APK/manifest or runtime inspection was performed; store links were used only as provider-published product identities. No claim of real-app validation.
