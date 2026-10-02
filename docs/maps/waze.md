# Waze external-launch audit

**Checked:** 2026-10-02. **Status:** current primary-source audit; all app behavior runtime-unverified. Baseline: fetched `origin/master` and verified [8aa7a6e](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131) is included; checkout matched it.

## Sources and scope

[How to use Waze Deep Links](https://developers.google.com/waze/deeplinks), **updated 2026-06-01 UTC**, fetched fresh in full. This is the public external-launch interface, not an embedded navigation SDK or partner-only API. Current documented routing preferences are broader than older “navigation only” descriptions. No inaccessible source was needed for the table below; no secondary-only parameters are asserted.

## Universal and native launch contracts

- Universal: `https://waze.com/ul?key=value&…`; the same page also uses `https://www.waze.com/ul` examples. Desktop opens a web page; mobile opens Waze if installed, otherwise a web page. System configuration affects dispatch.
- Native: `waze://?key=value&…` replaces the HTTPS base for app-to-app use **only when Waze is known installed**. The source offers the same deep-link parameters, not a separate native-only parameter set. No browser fallback is inherent in this scheme.
- Android example uses `ACTION_VIEW`; store identity is `com.waze`. iOS checks `waze://` and requires `waze` in `LSApplicationQueriesSchemes` for the query. Store ID is `323229106`.
- Coordinates are comma-separated **latitude,longitude**, shown as decimal values. The URL source does not explicitly name a datum or publish numeric coordinate bounds; our `LocationCoords` enforces finite latitude −90…90 and longitude −180…180. Do not add GCJ/BD conversion or claim an SDK's coordinate contract here.
- Encode query values; the source explicitly calls for `%20` for spaces and shows `%2C` for commas. No maximum URL length, query length or precision is documented. Our URI encoder uses `+` for spaces; browser/app acceptance of that form remains runtime-unverified for Waze.

## Parameters and actions

Source for all rows: [current Waze deep-link tasks, routing table and examples](https://developers.google.com/waze/deeplinks). Requiredness is action-specific; a bare URL is allowed. The source says no parameters uses driver settings, while listing explicit defaults for routing parameters; precedence against stored user settings is not fully explained.

| Parameter | Type / requiredness / documented values and semantics |
| --- | --- |
| `ll` | Optional location selector: decimal `latitude,longitude`. With `navigate=yes`, navigate to location; without navigation, center/show the map. |
| `q` | Search text; needed for text-search action. Address search documented. Can combine with `ll` and `navigate=yes`; example uses all three but does not define exact location-versus-query precedence. |
| `navigate` | Optional action switch; **`yes`** starts navigation. No documented `no`/`false` semantics. Omit for non-navigation display/search. |
| `favorite` | Saved destination selector: **`home` or `work`**; example combines with `navigate=yes`. Arbitrary favorite names are not documented. Requires the user's saved place to exist for useful navigation; missing favorite behavior unspecified. |
| `z` | Map magnification: **6 closest to 8192 farthest**, opposite the usual “higher means closer” zoom convention. Numeric; integer/fraction restrictions not stated. No default specified. |
| `zoom` | **Example-only**: a navigation example uses `zoom=17`, and prose mentions “zoom parameter.” The magnification section formally specifies `z` instead. Alias equivalence/range is not established; do not normalize these as interchangeable without testing. |
| `avoid_tolls` | Optional `true`/`t` avoid, `false`/`f` allow; documented default **false**. |
| `avoid_ferries` | Optional same boolean strings; default **false**. |
| `avoid_freeways` | Optional same boolean strings; default **false**. This key is not `avoid_highways`. |
| `avoid_dangerous_turns` | Optional same boolean strings; default **true**. |
| `avoid_trails` | Optional `avoid_all` (**default**), `allow`, `avoid_long`; unpaved-road preference. |
| `vehicle_type` | Optional `private` (**default**), `taxi`, `motorcycle`. Not walking, transit or bicycle routing. |
| `utm_source` | Optional application/partner identifier string; encouraged for attribution/support. Not a callback. |

**Additional documented actions:** launch without parameters, show/center map, address search, search then navigate, navigate home/work, and routing preference/vehicle selection. Waze is therefore not inherently navigation-only.

**Not documented in this public contract:** explicit route origin, multiple waypoints, arrival/departure times, custom pin title, public POI/place-ID selector, callbacks/return URL, result payload, route alternatives selector, or pedestrian/transit/cycling modes. Do not infer support from a Waze SDK or from opaque shared-link IDs. Combinations of `favorite`, `q`, and `ll` have no general precedence rule; avoid conflicting selectors. No claim is made that unknown parameters are rejected rather than ignored.

## Exact implementation comparison

Sources: [`waze.dart`](../../lib/src/maps/waze.dart), [`waze_extra.dart`](../../lib/src/extras/waze_extra.dart), [`directions_request.dart`](../../lib/src/requests/directions_request.dart), [`launch_helper.dart`](../../lib/src/utils/launch_helper.dart).

| Current implementation | Finding / suggested treatment |
| --- | --- |
| HTTPS and native directions both emit `ll=destination&navigate=yes` | Matches documented coordinate navigation syntax. Android native launch targets `com.waze`; launch exception retries HTTPS without package. Native scheme preferred on mobile, HTTPS on web/desktop. This is launch acceptance, not route-success detection. |
| `supportsMarkerCoords=false`; marker URL null; text-search flags false | **Omitted capabilities:** provider documents map display, search and search-navigation. Tests call Waze “navigation only”; that describes this implementation, not the provider. |
| `supportsTravelMode` only driving | Appropriate for current request enum. Taxi/motorcycle are vehicle classes, not transit/bicycling. Omitted typed vehicle preference, not evidence that driving-only selection is wrong. |
| Coordinate `origin` accepted but unused | **API semantic defect/risk:** a caller can request a non-current origin but receive navigation from Waze's actual context. Reject unsupported origin or disclose it; do not invent an origin parameter. Search origins are already rejected by request-level capability checks. |
| Nonempty waypoints rejected by request layer | Appropriate absent a documented waypoint contract. Direct low-level builder accepts but ignores its waypoint argument; distinguish that from `DirectionsRequest` behavior. |
| `WazeExtra(navigate:false)` emits nothing | Cannot disable the builder's unconditional `navigate=yes`. `navigate:true` appends a second `navigate=yes`, redundant; boolean name/default must not imply navigation opt-out. |
| No typed route preferences, favorites or attribution | **Omitted capabilities.** Raw extras can carry route preferences and `utm_source` on the existing navigation URL. Favorites would conflict with generated `ll`; use a dedicated action rather than assuming precedence. |

Extras are only appended during `show()`, not URL getters. Show-level extras override request-level extras, **not builder fields**; raw `{'navigate':'no'}` produces duplicate keys and an undocumented value, not a supported cancellation mechanism. URI encoding is applied; extras cannot change action base/path or remove `ll`/`navigate`. Coordinate titles and zoom arguments are unused by navigation; there is no marker builder to consume zoom.

## Recommended verification and unresolved points

- Existing [`waze_test.dart`](../../test/maps/waze_test.dart) checks strings/flags only, not app navigation. Retain its valid coordinate tests but describe disabled marker/search as implementation limitations.
- Add URL-level cases with asymmetric coordinates `59.3293,18.0686`, explicit far-away origin, and waypoint rejection to expose silent origin loss versus correct waypoint rejection.
- Add extras tests for duplicate `navigate`, false not disabling navigation, each `avoid_*` spelling/default, `vehicle_type=taxi/motorcycle`, and `utm_source=Café & + #` encoded exactly once. These test serialization, not Waze acceptance.
- If adding marker/search, exercise native and HTTPS: bare launch, `ll` without navigate, encoded `q`, `q+ll+navigate`, home/work set/unset, magnification boundaries 6/8192 versus 5/8193. Separately investigate `zoom=17` versus `z=17` rather than asserting equality.
- Test installed/uninstalled Android and iOS, web fallback, location permission disabled, unsupported regions and stored routing preferences versus explicit defaults. No real-device tests, app screenshots, route-result checks or navigation-start validation were performed.
- Provider omissions: coordinate datum, `z` numeric subtype, `zoom` alias, conflicting-selector precedence, duplicate-key behavior and complete app/web routing-preference parity. These are **documentation gaps**, not verified provider defects.
