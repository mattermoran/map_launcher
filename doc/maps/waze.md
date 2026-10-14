# Waze

The plugin opens destination navigation with `ll` and `navigate=yes` through HTTPS or `waze://`. It accepts omitted/driving mode and rejects explicit origins, non-driving modes and nonempty waypoints, including direct builders. Marker/search actions are not exposed; destination title and zoom are unused. Android targets `com.waze`; iOS callers declare `waze` for installation queries. Provider actions and preferences below extend beyond plugin builders.

Reference check: 2026-10-13.

## Sources and scope

[How to use Waze Deep Links](https://developers.google.com/waze/deeplinks), updated 2026-06-01 UTC: public launch actions, routing preferences and examples.

## Universal and native launch contracts

- Universal: `https://waze.com/ul?key=value&…`; the same page also uses `https://www.waze.com/ul` examples. Desktop opens a web page; mobile opens Waze if installed, otherwise a web page. System configuration affects dispatch.
- Native: `waze://?key=value&…` replaces the HTTPS base for app-to-app use **only when Waze is known installed**. The source offers the same deep-link parameters, not a separate native-only parameter set. No browser fallback is inherent in this scheme.
- Android example uses `ACTION_VIEW`; store identity is `com.waze`. iOS checks `waze://` and requires `waze` in `LSApplicationQueriesSchemes` for the query. Store ID is `323229106`.
- Coordinates are comma-separated **latitude,longitude**, shown as decimal values. The URL source does not explicitly name a datum or publish numeric coordinate bounds; our `LocationCoords` enforces finite latitude −90…90 and longitude −180…180. Do not add GCJ/BD conversion or claim an SDK's coordinate contract here.
- Encode query values; the source explicitly calls for `%20` for spaces and shows `%2C` for commas. No maximum URL length, query length or precision is documented. Our URI encoder uses `+` for spaces; browser/app acceptance of that form remains runtime-unverified for Waze.

## Parameters and actions

The Waze reference allows bare launch using driver settings, while also listing routing defaults below; precedence against stored settings is unspecified.

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

## Plugin limitations

Sources: [`waze.dart`](../../lib/src/maps/waze.dart), [`waze_extra.dart`](../../lib/src/extras/waze_extra.dart), [`directions_request.dart`](../../lib/src/requests/directions_request.dart), [`launch_helper.dart`](../../lib/src/utils/launch_helper.dart).

| Plugin behavior | Limit |
| --- | --- |
| HTTPS and native directions both emit `ll=destination&navigate=yes` | Matches documented coordinate navigation syntax. Android native launch targets `com.waze`; confirmed rejection permits retrying HTTPS without package. Native scheme preferred on mobile, HTTPS on web/desktop. This is launch acceptance, not route-success detection. |
| Marker/search flags false; marker URL null | Provider map display, search and search-navigation actions are not exposed. |
| Driving-only travel mode | Taxi/motorcycle are vehicle classes, not selectable enum modes; no typed vehicle preference. |
| Origins and nonempty waypoints | Rejected by request capabilities and direct builders. |
| `WazeExtra(navigate:false)` emits nothing | Does not disable unconditional `navigate=yes`; `navigate:true` matches the built-in value and is retained once. |
| No typed preferences, favorites or attribution | Raw extras can carry preferences and `utm_source`. Combining favorite selection with generated `ll` has unspecified precedence. |

Extras apply during launch preparation, not getters. Show extras override request extras; identical built-in values are retained once. Conflicting `ll`/`navigate` values exclude discovery entries or cause `MapLaunchException` on explicit launch. Extras cannot remove navigation or select a different action. Absent routing preferences and attribution can be appended.

## Reference limits

Coordinate datum, `z` numeric subtype, `zoom` alias, selector precedence and full app/web preference parity are unspecified. [`waze_test.dart`](../../test/maps/waze_test.dart) covers generated URLs and capability flags, not app navigation.
