# 2GIS

The plugin builds native/HTTPS coordinate cards and legacy `routeSearch` routes with optional coordinate origins. Modes are `car/bus/pedestrian/bicycle`, default `car`; legacy cycling is not documented. Titles, zoom and waypoints are unused; search and immediate `/go` guidance are not exposed. Android targets `ru.dublgis.dgismobile`; iOS callers declare `dgis`. Current provider grammar below is distinct from the plugin's legacy route builder.

Reference check: 2026-10-02.

## Sources

- [Russian developer deep-link reference](https://help.2gis.ru/question/razrabotchikam-zapusk-ideystviya-vmobilnom-prilozhenii-cherez-deeplink): current actions and `directions/points`; labels `routeSearch` legacy, used before 2020. No minimum app version stated.
- [English developer launch reference](https://help.2gis.com/question/developers-launching-2gis-navigation-using-deeplink): narrower legacy launch/routes reference, with `ctx` for transit.
- [API Platform](https://docs.2gis.com/en/api-platform): REST/SDK product documentation, **not** the consumer-app URL contract. No API key from this platform is required by the deep-link reference.

The help pages do not name a coordinate datum or numeric validation ranges. Coordinates are geographic longitude,latitude.

## URL families and actions

Reference: Russian deep-link guide.

`dgis://2gis.ru/{path}` and `https://2gis.ru/{path}` support the documented scenarios. The source **prefers HTTPS** because absence of the app leaves a working web scenario. Bare `dgis://` and `https://2gis.ru/` launch the app/map with no action parameters. Short links such as `http://go.2gis.com/6kjcs` are accepted; offline inability to expand them or an unsupported scenario sends the link to the browser. Short-code creation is not specified. There is no deep-link launch-count restriction.

| Path/action | Required fields | Optional fields, semantics and limits |
| --- | --- | --- |
| `/search/{query}` | Search text path component | Opens results; encode text as a path component, not an extra query parameter. No limit or search-radius field stated. |
| `/firm/{id}` | Organization ID | Optional city prefix. Numeric-looking IDs should be preserved as opaque strings; no size/range specified. |
| `/geo/{id}` | Place ID | Optional city prefix; opens a place card. |
| `/geo/{lon},{lat}` | Floating longitude and latitude | Optional city prefix; opens arbitrary location card/marker. No zoom/title field documented. |
| `/platform/{id}` | Stop-platform ID | Optional city prefix. |
| `/stop/{id}` | Stop ID | Optional city prefix. |
| `/route/{id}` | Transit-route ID | Opens an existing route's card; **not** a point-to-point directions request. Optional city prefix. |
| `/stationEntrance/{id}` | Metro-entrance ID | Optional city prefix. |
| `/collections` | None | Opens Favorites. No collection ID or callback field documented. |
| `/directions/tab/{route_type}` | Mode in this shown form | Opens empty routing screen; origin may populate from location. Optional city prefix, e.g. `/moscow/directions/tab/car`. |
| `/directions[/tab/{route_type}]/points/{points}` | Destination coordinates in point list | Current route-building grammar detailed below. Optional city prefix. Square brackets here denote optional syntax, not literal characters. |
| `/routeSearch[/rsType/{type}]/to/{destination}/go` | Destination and `/go` command | Immediate car or pedestrian guidance; see navigation table below. |

## Current route fields

Reference: Russian guide, “Построение маршрута (актуально)”. Fields are path segments, not query parameters.

| Field | Type/requiredness | Values/defaults/constraints |
| --- | --- | --- |
| `city` | Optional string path prefix | Project/city selector; no exhaustive identifier list given. |
| `route_type` after `tab` | Optional enum string | `car`, `bus`, `pedestrian`, `bicycle`, `scooter`, `truck`, `taxi`. Parameter column says default `car`; adjacent scenario text says omitted type uses the user's selected mode. **Source conflict: explicitly specify mode when it matters.** |
| `points` | Ordered string of endpoint entries | Entries separated by ASCII `\|`; start first, destination last. |
| Each point | `lon,lat;object_id` | Floating geographic longitude **first**, latitude second; `object_id` optional. Coordinates mandatory for destination and explicit endpoints. Examples include object IDs; no title/address field in current grammar. |
| Origin | Optional first entry | Omit its content but **retain leading `\|`**, e.g. `points/\|37.665247,55.759725`. Current location can supply origin when determined. |
| Intermediate entries | Optional; **Android documented** | Add between origin and destination using the same format, **up to 10 intermediate points**. No iOS waypoint guarantee. No stopover/pass-through switch, optimization field, or mode-specific limits stated. |

The source's truck example omits `tab/truck`; do not copy that omission as a mode-selection guarantee. Its optional object-ID field is not a REST place lookup request. URL-encode path data correctly (especially the pipe separator as `%7C` on the wire where needed); the decoded path must retain delimiters and a deliberately empty origin. The page does not provide a full escaping specification for reserved characters inside IDs or textual legacy addresses.

## Legacy route and immediate-navigation fields

References: Russian legacy/guidance sections and English route section.

| Field/family | Contract | Evidence limits |
| --- | --- | --- |
| `routeSearch/rsType/{type}/from/{from}/to/{to}` | Legacy routing; Russian values `car`, `bus`, `taxi`, `pedestrian`; mode optional, prior selected mode when absent | English instead lists `car`, `ctx`, `pedestrian`, `taxi`. This is a documentation discrepancy, **not proof `bus` is wrong**. Neither legacy table lists `bicycle`. |
| Legacy `from`, `to` | Longitude/latitude coordinates; English says floats and allows no origin, using location if available | Russian describes richer `lon,lat╎address_string╎object_id`, requiring both delimiters even when latter fields empty, but also gives plain-coordinate examples. The glyph shown is `╎`, unlike current ASCII pipe; do not silently normalize this underspecified legacy encoding. |
| Guidance `/go` | Required command for immediate navigation | May occur anywhere after `routeSearch`, but must not split a composite token such as `rsType/car`. End position is simplest. |
| Guidance `type` | Optional `car` or `pedestrian` | Missing type, `bus`, or `taxi` starts **car** guidance; `pedestrian` starts walking guidance. Do not infer bicycle/truck navigation launch from planner support. |
| Guidance destination | Required longitude/latitude | `/routeSearch/to/82.808814,54.989664/go` is the official example. |
| Guidance origin | Optional but ineffective | Navigation **always** starts from current geolocation, even when an explicit origin is passed. |
| Guidance city/project | Optional | No default or allowed set specified. |

No callback, completion return URL, x-callback-url, language, avoidances, departure time, credentials, custom marker label, or URL-length limit is documented. Their absence from the reference is not a device-tested assertion of rejection. Ordinary route construction is distinct from `/go` guidance.

## Plugin limitations

Code: [builder](../../lib/src/maps/double_gis.dart), [capabilities](../../lib/src/maps/map_app.dart), [launch extras](../../lib/src/utils/launch_helper.dart).

| Capability | Current implementation | Assessment |
| --- | --- | --- |
| Marker | `/geo/lon,lat`, HTTPS and native | Matches current arbitrary-location card syntax. Zoom and title ignored; current docs do not establish those fields. |
| Directions | `routeSearch/rsType/{mode}[/from/lon,lat]/to/lon,lat` | Explicitly legacy routing, rather than current `directions/points`. HTTPS/native mirror each other. |
| Modes | Driving `car`, transit `bus`, walking `pedestrian`, bicycle `bicycle`; null `car` | `bus` corroborated by Russian legacy docs despite English `ctx`. `bicycle` is documented for **current** grammar but not this legacy grammar; compatibility is unverified, not a confirmed app failure. |
| Waypoints | Ignored; flag false | Documented Android current-format capability omitted. Do not set a global cross-platform flag without resolving iOS behavior. |
| Search/cards/Favorites | No dedicated builders; search flags false | Documented launch actions omitted. |
| Navigation | Does not add `/go` | Only planner launch represented; no immediate guidance API. |
| Extras | No typed class; query append | Cannot change path modes/grammar, add waypoints or `/go`. Identical built-in values are retained once; conflicts exclude discovery entries or cause `MapLaunchException` on explicit launch. |
| Launch selection | Native preferred on mobile; HTTPS fallback | Official guidance prefers HTTPS; this is a design difference, not proof native is invalid. Android package `ru.dublgis.dgismobile`, iOS detection `dgis://`. |

The confirmed gap is **legacy grammar and missing current actions**, not a verified broken transit link. The embedded Mobile SDK, navigation REST APIs, search APIs and their keys/vehicle fields are separate contracts and must not be copied into app URLs.
