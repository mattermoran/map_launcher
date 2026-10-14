# Google Maps

The plugin supports coordinate/text search and directions, coordinate/text origins, four travel modes and coordinate waypoints. Android uses HTTPS; iOS uses `comgooglemaps` for markers and text directions but HTTPS for coordinate directions. At preparation, Place-ID extras or `dir_action` select HTTPS. IDs require nonblank companion fields; `dir_action` requires directions. Invalid combinations use `MapConfigurationError`: discovery excludes them and explicit launch reports `MapLaunchException`. Universal markers ignore title/zoom; native iOS markers retain both. iOS callers declare `comgooglemaps` for installation queries.

Reference check: 2026-10-13; universal guide updated 2026-10-08 UTC. Tables include provider actions not exposed by the plugin.

## Sources

| Source | Version/update and scope |
| --- | --- |
| [Maps URLs guide](https://developers.google.com/maps/documentation/urls/guide) | URL API version **1**; universal actions and fields. |
| [iOS URL scheme](https://developers.google.com/maps/documentation/urls/ios-urlscheme) | Native `comgooglemaps` and desktop-URL import `comgooglemapsurl`. |
| [Android intents](https://developer.android.com/guide/components/google-maps-intents) ([Google documentation entry](https://developers.google.com/maps/documentation/urls/android-intents)) | Standard Android Google Maps, not Maps Go. |
| [Android Automotive intents](https://developer.android.com/training/cars/platforms/automotive-os/android-intents-automotive) | Updated **2026-03-05 UTC**; separate in-car product, including EV trips and action intents. |
| [x-callback-url specification](https://x-callback-url.com/specification/) | 1.0 draft R3; protocol authority, **not Google implementation evidence**. |

These are external-launch contracts, separate from REST and embedded SDK APIs. [Google Maps Go](google-go.md) is a separate product.

Coordinates are decimal **latitude,longitude**; the URL references do not name the datum. `LocationCoords` validates finite latitude −90…90 and longitude −180…180. Encode values once: commas `%2C`, pipes `%7C`, spaces `%20` or `+`; literal plus `%2B`, ampersand `%26`, hash `%23`. Universal/iOS links require no API key. IDs are opaque strings.

## Universal HTTPS URLs

The Maps URLs guide recommends this interface: Android/iOS open installed active Maps, otherwise browser; other devices use browser. URLs are limited to **2,048 characters**. Every action requires **`api=1`**; without it, parameters are ignored and default Maps opens. No other `api` value is documented.

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

Reference: Maps URLs guide, map/panorama tables. Neither action has a plugin builder.

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

The iOS scheme reference uses `comgooglemaps://?…`; installed app and scheme queries are required. iOS 9+ callers declare query schemes; bundle identifier is automatically sent. Universal links are supported on iOS 9+. No API key, native length limit, zoom range/default or full requiredness matrix is specified.

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

Directions do not guarantee automatic guidance. Listed short-link hosts do not establish continued resolution of every old short URL.

### Callback evidence is incomplete

The current iOS page's **page summary** mentions `comgooglemaps-x-callback://`, but the body does not supply a callback parameter contract. A fetch of [the candidate callback documentation URL](https://developers.google.com/maps/documentation/urls/ios-x-callback-url-scheme) failed with a network error; no claim is made that it is a valid current page or that the feature was removed.

Google's [iOS launch announcement](https://developers.googleblog.com/open-google-maps-from-your-ios-app/) (2015-03-30) confirms historical x-callback support and a return-to-caller button, but does not enumerate fields or promise return on arrival.

| Candidate field | Evidence / safe interpretation |
| --- | --- |
| `x-source` | Generic x-callback specification: URL-encoded friendly caller name; current Google acceptance unconfirmed. |
| `x-success` | General protocol defines return URL after success; must encode nested URL once as a value. Historical Google usage needs a recoverable provider source/device verification before promising return-button behavior or requiredness. |
| `x-error`, `x-cancel` | General protocol defines error/cancel return URLs. **Do not infer Google supports them** from generic x-callback conformance or page-summary wording. |

These are protocol-only/legacy-candidate findings, not a supported-current Google parameter list. Our implementation supports none of the callback schemes or typed callbacks. No arrival/completed-trip callback is established.

## Native Android phone intents

The Android intent reference uses `ACTION_VIEW` and encoded URIs targeting **`com.google.android.apps.maps`**. A receiving activity must exist; without package targeting a chooser may appear. These are full Maps contracts, not Go contracts. The plugin uses HTTPS rather than these phone intent builders.

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

The Automotive reference uses the same package and `ACTION_VIEW`. These additional actions are not implemented by the plugin and do not establish phone/Go support.

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

This inventory applies only to Automotive.

## Plugin limitations

Sources: [`google_maps.dart`](../../lib/src/maps/google_maps.dart), [`google_extra.dart`](../../lib/src/extras/google_extra.dart), [`map_app.dart`](../../lib/src/maps/map_app.dart), [`directions_request.dart`](../../lib/src/requests/directions_request.dart), [`launch_helper.dart`](../../lib/src/utils/launch_helper.dart), [`url_builder.dart`](../../lib/src/utils/url_builder.dart).

| Plugin behavior | Limit |
| --- | --- |
| HTTPS marker `/maps/search/?api=1&query=lat,lng` | Title/zoom ignored; the search action has no documented custom-label or zoom field. Map-only zoom is a different action. |
| iOS marker prefers `comgooglemaps://?q=lat,lng(title)&zoom=…` | `zoom` documented; parenthesized label grammar is documented for Android, **not iOS**. Runtime-unverified assumption. |
| HTTPS directions support destination/origin coordinates or search, four modes, pipe waypoints | Final HTTPS URLs are capped at 2,048 characters. Up to nine intermediate stops on Android package-targeted and desktop transports; three on mobile unpinned HTTPS. Over-limit transports are excluded, never truncated. `two-wheeler`, avoid and waypoint IDs lack typed API. Nonempty waypoints with search destination are rejected by the request layer. |
| iOS coordinate directions use HTTPS (no native coordinate override); iOS search directions use `comgooglemaps` | Important asymmetry: destination representation changes parameter contract even on same platform. Native text origin uses `saddr`; universal uses `origin`. |
| `GoogleExtra` Place IDs and `dir_action=navigate`; raw `waypoint_place_ids` | Select universal URL at launch; ID companions must be nonblank and navigation must target directions. |
| `dir_action=navigate` | May navigate, preview or be ignored according to device, origin and route; not guaranteed immediate guidance. |
| Launch extras | Getters omit extras. Identical built-in values are retained once; conflicts use `MapConfigurationError`. Existing bytes are preserved. Google transports use the same Google options; an Apple fallback does not inherit them. Extras cannot change endpoint. |
| Android HTTPS targets full Maps, with eligible untargeted fallback | Four-to-nine-stop routes cannot retry via the three-stop mobile browser transport. Phone-specific direct navigation/Street View and Automotive actions are not exposed. |

Additional omitted actions: bare app launch, map-only viewport/layers, Street View, editable empty directions form, native desktop-URL import, callback scheme, Automotive categories/EV/control actions. Plain extras cannot reliably implement actions requiring a different path/scheme. Empty iOS `views=` is expressible via raw launch extras (append preserves empty values), despite `buildUrl` filtering empty builder values.

Use request `providerExtras: {.google: GoogleExtra(...)}` before automatic
launch or discovery. Options are immutable snapshots matched by provider ID and
are conditional preferences, not portable requirements. Nonempty raw extras
require explicit `show(map: .google, extra: ...)`. Picker entries capture
validated options and expose parameterless `show()`, never switching provider.
Transport retries require confirmed non-handoff; blocked popups and unknown
outcomes stop immediately. Automatic launch may try Apple only after Google is
ineligible or its eligible transports confirm failure.

## Reference limits

The current callback contract was not recovered. Native iOS zoom bounds, datum and complete product/mode compatibility remain unspecified. [`google_maps_test.dart`](../../test/maps/google_maps_test.dart) covers generated URLs, not provider runtime behavior.
