# Google Maps external-launch audit

**Checked:** 2026-10-02. **Status:** current primary URL/intent documentation audited; no real-app validation. Baseline: fetched `origin/master`, verified it contains [8aa7a6e](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131), and confirmed checkout matched it.

## Sources and evidence status

| Source | Version/update and scope |
| --- | --- |
| [Maps URLs guide](https://developers.google.com/maps/documentation/urls/guide) | Updated **2026-09-28 UTC**, URL API version **1**; current universal links. |
| [iOS URL scheme](https://developers.google.com/maps/documentation/urls/ios-urlscheme) | Updated **2026-09-28 UTC**; current `comgooglemaps` and `comgooglemapsurl` documentation. |
| [Android intents](https://developer.android.com/guide/components/google-maps-intents) ([Google documentation entry](https://developers.google.com/maps/documentation/urls/android-intents)) | Updated **2026-02-26 UTC**; standard Android Google Maps, not Maps Go. |
| [Android Automotive intents](https://developer.android.com/training/cars/platforms/automotive-os/android-intents-automotive) | Updated **2026-03-05 UTC**; separate in-car product, including EV trips and action intents. |
| [x-callback-url specification](https://x-callback-url.com/specification/) | 1.0 draft R3; protocol authority, **not Google implementation evidence**. |

All four main provider pages were read fresh in full. “Documented” means those external-launch contracts, not REST Directions/Routes, Places or embedded SDK APIs. Source-inferred implementation behavior is called out below. Callback details have weaker evidence, explicitly separated. Google Maps Go has its own [audit](google-go.md).

Coordinates in these launch interfaces are decimal **latitude,longitude** pairs, not longitude-first or projected coordinates. The audited URL pages do not explicitly specify the datum; no datum conversion is justified by this audit. Our `LocationCoords` validates finite latitude −90…90 and longitude −180…180. Encode values once: commas `%2C`, pipes `%7C`, spaces `%20` or `+`; literal plus `%2B`, ampersand `%26`, hash `%23`. No API key needed for universal/iOS links. IDs are opaque strings, not coordinates or labels.

## Universal HTTPS URLs

Source: [Maps URLs guide](https://developers.google.com/maps/documentation/urls/guide). Android/iOS open installed active Google Maps, otherwise browser; other devices use browser. Google's recommendation is to prefer this cross-platform interface. URL limit: **2,048 characters**. All actions require **`api=1`**; without it, parameters are ignored and default Maps opens. `api` has no other documented value.

### Search and directions

| Endpoint / field | Requirement, values, defaults and limits |
| --- | --- |
| `/maps/search/`: `query` | **Required** place name, address, decimal lat/lon or general search text. Coordinate search drops a pin; no custom-title field. Include locality in categorical query to bias it; otherwise nearby current location. |
| `/maps/search/`: `query_place_id` | Optional Google Place ID; still requires `query`. ID takes precedence; query is fallback if ID not found. |
| `/maps/dir/`: `origin` | Optional name/address/lat-lon; defaults to relevant start such as current location, otherwise user-entry form. **Required if `origin_place_id` supplied**. |
| `/maps/dir/`: `origin_place_id` | Optional Place ID with companion `origin`. |
| `/maps/dir/`: `destination` | Optional name/address/lat-lon; omission may show blank entry form. **Required if `destination_place_id` supplied**. |
| `/maps/dir/`: `destination_place_id` | Optional Place ID with companion `destination`. |
| `/maps/dir/`: `travelmode` | Optional `driving`, `walking`, `bicycling`, `two-wheeler`, `transit`. Omission selects relevant modes/user preferences, **not guaranteed driving**. Two-wheeler is motorized and region-dependent. |
| `/maps/dir/`: `dir_action` | Optional **`navigate`**. Navigation if origin absent/current/near current location and device location available; otherwise route preview. Ignored on products/routes without navigation. Not guaranteed immediate navigation. |
| `/maps/dir/`: `waypoints` | Optional ordered pipe-separated names, addresses or lat/lon pairs; **up to 3 on mobile browsers, 9 otherwise**. Ignored on unsupported products. Required if `waypoint_place_ids` provided. |
| `/maps/dir/`: `waypoint_place_ids` | Optional pipe-separated IDs matching waypoint order; requires `waypoints`. Do not assume unequal list lengths or unsupported products work. |
| `/maps/dir/`: `avoid` | Optional comma-separated **`ferries`, `highways`, `tolls`**; route should try to avoid them, not an absolute exclusion guarantee. |
| All actions: `utm_source`, `utm_campaign` | Optional recommended attribution strings: application name and intended action respectively. No functional callback semantics. |

`/maps/dir/?api=1` opening an editable directions form is a documented action our required-destination API omits. The guide does not give a complete travel-mode/waypoint/avoid compatibility matrix; do not borrow one from the REST Directions API.

### Map display and Street View

Source: [map and panorama action tables](https://developers.google.com/maps/documentation/urls/guide).

| Endpoint / field | Requirement, values and defaults |
| --- | --- |
| `/maps/@`: `map_action=map` | Required for map-only action (no markers or directions), alongside `api=1`. |
| Map: `center` | Optional decimal lat/lon; bare map example centers on current location. |
| Map: `zoom` | Optional **integer 0–21**, default **15**; maximum depends on imagery/data availability. Not `z`, and not documented on `/search/`. |
| Map: `basemap` | Optional `roadmap` (**default**), `satellite`, `terrain`. |
| Map: `layer` | Optional one of `none` (**default**), `transit`, `traffic`, `bicycling`. No comma-list contract here. |
| `/maps/@`: `map_action=pano` | Required for panorama action, alongside `api=1`. |
| Panorama: `viewpoint` | Lat/lon nearest panorama; **one of `viewpoint` or `pano` required**. Imagery refresh may change selected panorama. |
| Panorama: `pano` | Specific panorama ID; takes precedence over viewpoint; viewpoint is fallback if ID fails. If ID fails without viewpoint, map opens in default current-location mode. FIFE image key with `F:` prefix shown in an example. |
| Panorama: `heading` | Optional degrees clockwise from north, **−180…360**. Default chosen from viewpoint and image location. |
| Panorama: `pitch` | Optional **−90…90** degrees; positive up, negative down; default **0**, relative to capture and not always horizontal. |
| Panorama: `fov` | Optional **10…100** degrees, default **90**; smaller means greater zoom. |

## Native iOS links

Source: [iOS URL scheme](https://developers.google.com/maps/documentation/urls/ios-urlscheme). Base `comgooglemaps://?…`; requires installed app and scheme availability checks. iOS 9+ callers declare query schemes; bundle identifier is automatically sent. Universal links are supported on iOS 9+. No API key. Source does not publish native URL length, zoom range/default, or full required-field matrix.

| Action / parameter | Contract |
| --- | --- |
| Bare `comgooglemaps://` | Launch app; map-display parameters all optional. |
| Map: `center` | Comma-separated latitude,longitude viewport center. |
| Map: `mapmode` | `standard` or `streetview`; omitted uses current app settings. |
| Map: `views` | `satellite`, `traffic`, `transit`; **comma-separated multiple values allowed**. Explicit empty value clears all views. |
| Map: `zoom` | Zoom level; no documented numeric range/default on this page. Do not transfer HTTPS's range as a native guarantee. |
| Search: `q` | Search query; can combine with map parameters above. Android's `lat,lon(label)` custom-label grammar is **not specified here**. |
| Directions: `saddr` | Lat/lon or address query; ambiguous query selects first result; blank uses current location. |
| Directions: `daddr` | Same format/behavior as `saddr`; destination. Page does not provide a formal requiredness matrix. |
| Directions: `directionsmode` | `driving`, `transit`, `bicycling`, `walking`; no two-wheeler value/default specified. |
| Directions + map parameters | Examples combine `center` and `zoom` with directions. No documented native waypoints, Place-ID fields, `avoid`, or `dir_action`. |
| `comgooglemapsurl://…` | Replace `http://` or `https://` on an existing Maps desktop URL. Supported hosts: `maps.google.{TLD}`, `(www.)google.{TLD}/maps/`, `goo.gl/maps/`. Distinct scheme, not `comgooglemaps://?url=…`. Check scheme availability. |

Directions provide access to navigation; the page does not promise automatic turn-by-turn start for every native directions request. Short-link host examples are documentation, not a fresh guarantee of a specific old short URL's continued resolution.

### Callback evidence is incomplete

The current iOS page's **page summary** mentions `comgooglemaps-x-callback://`, but the body does not supply a callback parameter contract. A fetch of [the candidate callback documentation URL](https://developers.google.com/maps/documentation/urls/ios-x-callback-url-scheme) failed with a network error; no claim is made that it is a valid current page or that the feature was removed.

**Legacy primary evidence:** Google's [Open Google Maps from your iOS app](https://developers.googleblog.com/open-google-maps-from-your-ios-app/), published **2015-03-30**, was retrieved fresh. It confirms x-callback support and a button pointing back to the calling app in Google's historical link-building utility. It does not enumerate the fields or promise automatic return on arrival. This corroborates historical capability, not a complete current contract.

| Candidate field | Evidence / safe interpretation |
| --- | --- |
| `x-source` | General [x-callback specification](https://x-callback-url.com/specification/) defines friendly calling-app name, URL-encoded string. **Not confirmed as current Google Maps support by this audit.** |
| `x-success` | General protocol defines return URL after success; must encode nested URL once as a value. Historical Google usage needs a recoverable provider source/device verification before promising return-button behavior or requiredness. |
| `x-error`, `x-cancel` | General protocol defines error/cancel return URLs. **Do not infer Google supports them** from generic x-callback conformance or page-summary wording. |

These are protocol-only/legacy-candidate findings, not a supported-current Google parameter list. Our implementation supports none of the callback schemes or typed callbacks. No arrival/completed-trip callback is established.

## Native Android phone intents

Source: [Android Maps intents](https://developer.android.com/guide/components/google-maps-intents). `ACTION_VIEW` plus URL-encoded URI; package **`com.google.android.apps.maps`** explicitly selects full Google Maps. Check a matching receiving activity, not merely package installation. Without package, OS may show a chooser. These contracts do not establish Maps Go support.

| URI / parameter | Requirement, grammar, defaults and constraints |
| --- | --- |
| `geo:latitude,longitude?z=zoom` | Map center; optional `z` **0–21**, upper bound depends on local data; default not stated. |
| `geo:latitude,longitude?q=query` | Search; `q` required. Address, place name or category; URI coordinate biases results. `geo:0,0` without a meaningful search center means nearby/general search. |
| `geo:0,0?q=latitude,longitude(label)` | Coordinate marker with optional string label in parentheses; labels only documented with coordinate query, not text-address query. `z` can also bias search scale. |
| `https://plus.codes/global-code` / `https://plus.codes/local-code,locality` | Documented alternative location links; examples use global `849VQJQ5+XX` and local `QJQ5+XX,San%20Francisco`. Preserve path syntax; not a new `place_id` parameter. |
| `google.navigation:q=address-or-lat,lon` | Destination required for navigation; **no `?` after colon in documented grammar**. Origin is always current location; ambiguous query chooses first result. |
| Navigation: `mode` | Optional `d` driving (**default**), `b` bicycling, `l` motorized two-wheeler, `w` walking. **No `t` transit**. Regional two-wheeler availability applies. |
| Navigation: `avoid` | Optional concatenation of `t` tolls, `h` highways, `f` ferries, e.g. `tf`. Not HTTPS's comma-separated words. |
| `google.streetview:cbll=lat,lon` / `google.streetview:panoid=id` | One selector required; nearest panorama for coordinate, ID takes precedence if both supplied. No `?` after colon. |
| Street View: `cbp=0,bearing,0,zoom,tilt` | Optional five-slot comma list; first/third unsupported and should be 0. Bearing clockwise north and wraps (360/720 equivalent to 0). Zoom default 0; 1 doubles magnification; clamped 0…panorama maximum. Tilt **−90 up, 0 horizon, +90 down**: opposite HTTPS pitch sign. |

The Android page's extracted west-bearing sentence is malformed, but its clockwise-north rule and wrapping are clear. No phone native waypoint/origin/callback contract is documented here. Do not copy Automotive extensions onto phone navigation without separate evidence.

## Android Automotive is a distinct documented product

Source: [Automotive intents](https://developer.android.com/training/cars/platforms/automotive-os/android-intents-automotive). Same package and `ACTION_VIEW`, but these additional actions are **omitted by our API**, not phone/Go guarantees.

| Action / field | Contract and limitations |
| --- | --- |
| `geo:lat,lon?z=…&q=…` | Map/search, z 0–21. A single `q` result becomes destination. During navigation, search is along route and coordinate bias ignored. |
| `geo:lat,lon?c=category` | Required category selector for categorical action: `gas_station`, `restaurant`, `cafe`, `parking`, `electric_vehicle_charging_station`; fixed spellings independent of locale. |
| `google.navigation:q=…` or `google.navigation:place=…` | Destination address/coordinates, or `place=home/work`; origin always current location. |
| Navigation `avoid` | Optional `t`, `h`, `f` combinations. |
| Navigation `waypoints` | Optional ordered pipe-separated addresses/lat-lon; source says as many as needed (no numeric cap). **Multiple destinations show overview; navigation does not start automatically.** |
| EV final `q`, `q_type`, `q_name`, `q_power_output_kw` | Charging destination: coordinate `q`, `q_type=1`, required name; optional double kW power. To mark charging stops, trip must include at least one waypoint and final destination. |
| EV `waypoint_types` | Parallel pipe-list: 0 ordinary (**default**), 1 charging; charging waypoint must be coordinates. |
| EV `waypoint_names` | Parallel pipe-list, name mandatory for each charging waypoint. |
| EV `waypoint_power_outputs_kw` | Parallel pipe-list of optional doubles; empty slot means unknown. Lists exclude final destination; unequal list lengths malformed. Power is fallback if station match absent. No numeric power range stated. |
| `geo.action:?act=…` | Required action name from inventory below. `select_search_result` additionally takes zero-based integer `id`; no maximum stated. Unlike navigation/Street View, this source explicitly includes `?`. |

Complete documented `act` inventory:

- Voice/display: `mute`, `unmute`, `show_traffic`, `hide_traffic`, `show_satellite`, `hide_satellite`.
- Navigation-only in table: `show_alternates`, `route_overview`, `query_next_turn`, `distance_to_next_turn`, `time_to_next_turn`, `distance_to_destination`.
- Screen/location: `go_back`, `my_location`, `show_map`, `clear_search_results`.
- Spoken information: `query_current_road`, `query_destination`, `traffic_report`; while navigating, `eta`, `time_to_destination`.
- EV search filters: `apply_electric_vehicle_connector_filter`, `remove_electric_vehicle_connector_filter`, `apply_electric_vehicle_payment_filter`, `remove_electric_vehicle_payment_filter`, `apply_electric_vehicle_fast_charging_filter`, `remove_electric_vehicle_fast_charging_filter`.
- Routing changes while navigating, potentially rerouting: `avoid_tolls`, `allow_tolls`, `avoid_ferries`, `allow_ferries`, `avoid_highways`, `allow_highways`.
- `exit_navigation`; `select_search_result&id=0` starts navigation to displayed result at index 0 (other nonnegative indexes select other displayed results).

No phone support is implied by this inventory. No Automotive runtime was used.

## Exact implementation comparison and priorities

Sources: [`google_maps.dart`](../../lib/src/maps/google_maps.dart), [`google_extra.dart`](../../lib/src/extras/google_extra.dart), [`map_app.dart`](../../lib/src/maps/map_app.dart), [`directions_request.dart`](../../lib/src/requests/directions_request.dart), [`launch_helper.dart`](../../lib/src/utils/launch_helper.dart), [`url_builder.dart`](../../lib/src/utils/url_builder.dart).

| Current behavior | Finding / action |
| --- | --- |
| HTTPS marker `/search/?api=1&query=lat,lng&z=zoom`; title ignored | **Contract mismatch:** `z` is not a documented search parameter. Renaming to `zoom` would not fix endpoint incompatibility; map-only action has documented zoom but no marker. Document limitation or introduce a distinct view action. No universal custom-label field exists, so ignoring title is a limitation, not a wrong spelling. |
| iOS marker prefers `comgooglemaps://?q=lat,lng(title)&zoom=…` | `zoom` documented; parenthesized label grammar is documented for Android, **not iOS**. Runtime-unverified assumption. |
| HTTPS directions support destination/origin coordinates or search, four modes, pipe waypoints | Mostly documented. `two-wheeler`, avoid and waypoint IDs lack typed API. No 2,048-character or 3/9-stop enforcement. Nonempty waypoints with search destination rejected by request layer although universal provider supports that combination: **omission**. |
| iOS coordinate directions use HTTPS (no native coordinate override); iOS search directions use `comgooglemaps` | Important asymmetry: destination representation changes parameter contract even on same platform. Native text origin uses `saddr`; universal uses `origin`. |
| `GoogleExtra`: `query_place_id`, `destination_place_id`, `origin_place_id`, `dir_action=navigate` | **Platform/action mismatch:** these are universal keys. Unchanged extras are appended to iOS native marker/search-directions URLs where not documented. Prefer universal path when universal-only options are requested, or map only genuinely equivalent native fields. |
| `originPlaceId` without `from` | Produces HTTPS URL missing required companion `origin`; **validation gap**. Search ID extra on directions or directions extras on marker also not action-scoped. Destination companion present in generated universal directions. |
| `navigate` doc says starts immediately | **Overstatement:** documented universal behavior may show preview or ignore navigation. Native `dir_action` not documented at all. |
| Raw extras appended to existing query | Cannot replace built-in keys or change endpoint; can create duplicate `query`, `travelmode`, etc. Provider precedence unspecified. Typed extras merge only with other extras; URL getters omit all extras. Same extras are used on fallback. |
| No native Android override; Android launches HTTPS targeted to full Maps package, fallback untargeted | Valid provider-recommended strategy, **not missing native intents as a correctness defect**. Omits phone-specific direct navigation/Street View and Automotive actions. |

Additional omitted actions: bare app launch, map-only viewport/layers, Street View, editable empty directions form, native desktop-URL import, callback scheme, Automotive categories/EV/control actions. Plain extras cannot reliably implement actions requiring a different path/scheme. Empty iOS `views=` is expressible via raw launch extras (append preserves empty values), despite `buildUrl` filtering empty builder values.

## Verification plan and limits

- Existing [`google_maps_test.dart`](../../test/maps/google_maps_test.dart) tests generated strings, not provider behavior. No application code/tests changed in this audit.
- Assert full decoded URLs per platform and destination type: iOS coordinate directions HTTPS versus text directions native; query/destination/origin IDs applied only on documented endpoints; missing companion rejected or handled deliberately.
- Test waypoint counts 3/4 and 9/10, long encoded URLs 2,048/2,049 characters, asymmetric waypoint order, names containing `|`, and search destination plus stops. Do not silently truncate stops.
- Test `Café & Bar + #1`, label parentheses and Unicode; verify literal plus encoded once and `extra` duplicate keys visible. Android opaque `google.navigation:q=` grammar must not be routed through a helper that inserts `?`.
- Distinguish zoom search limitation from map-only zoom 0/21, map layer single value versus native comma `views`, HTTPS pitch +30 versus Android tilt −30, pano ID failure with/without viewpoint fallback.
- Real-device follow-up: far-away origin versus current location under navigate; denied location; installed/uninstalled fallback; invalid Place ID; regional two-wheeler; native labeled pins; callback scheme availability. Separately test Automotive overview/EV parallel lists and navigation-only actions.
- Source access gap: callback contract not recovered; page summary alone is inadequate. No confirmed current Google callback requiredness or completion semantics. Numeric native iOS zoom bounds, datum and complete product/mode compatibility matrix remain undocumented here. No claim of app validation, route correctness or runtime rejection of undocumented keys.
