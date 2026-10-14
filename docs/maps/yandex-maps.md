# Yandex Maps

The plugin builds HTTPS and native coordinate markers (`pt=lon,lat`, optional `z`, fixed `l=map`) and routes (`rtext` in lat,lon order). Routes include an optional origin, waypoints and `rtt=auto/pd/mt/bc`; omitted origin preserves an empty first token. Native cycling and empty-origin/multi-point semantics exceed the explicit native reference. Search and other actions below are not exposed. Android targets `ru.yandex.yandexmaps`; iOS callers declare `yandexmaps`.

Reference check: 2026-10-02.

## Sources

- [Android launch reference](https://yandex.com/dev/yandex-apps-launch-maps/doc/en/concepts/yandexmaps-android-app): applies to **app version 4+**.
- [iOS launch reference](https://yandex.com/dev/yandex-apps-launch-maps/doc/en/concepts/yandexmaps-ios-app): applies to **app version 7.1.1+**.
- [Web launch reference](https://yandex.com/dev/yandex-apps-launch-maps/doc/en/concepts/yandexmaps-web): web URL grammar.
- [Launch product index](https://yandex.com/dev/yandex-apps-launch): distinguishes Maps from Navigator and Metro.

The official references include legacy-looking Public Map/native API examples, without a stated deprecation or publication date. Documentation revision `r19109751` is not an app release version.

## Native and universal URL families

References: Android, iOS and web launch guides above.

| Family | Launch actions | Platform/notes |
| --- | --- | --- |
| `yandexmaps://maps.yandex.com/?…` | Open map, placemark, text search, organization card, route | Android `ACTION_VIEW`; iOS `openURL`. Official examples also use `maps.yandex.ru`. |
| `yandexmaps://?…` | What's-here object card and panorama | Root custom-scheme examples use bracketed query keys. No host required in those examples. |
| `https://yandex.ru/maps/?…` | Map, marker(s), search, route, what's-here, panorama | Public web launch contract. Repository uses `.com/maps/`; official docs also use `.com` for organization URLs. App interception/fallback varies by platform and is not proved merely by HTTPS syntax. |
| `https://yandex.com/maps/org/{oid}` | Organization card | ID is a **path component**, unlike native `oid` query field. `.ru` also appears in examples. |
| `geo:lat,lon?z=…` | Open map center | Android-only alternative explicitly documented, e.g. `geo:47.6,-122.3?z=11`; chooser may appear for multiple handlers. No separate search or navigation Geo URI contract specified by this reference. |

These pages name geographic longitude/latitude, use decimal-degree examples and degree spans, but do not explicitly state datum, latitude/longitude bounds or maximum URL length. Do not import WGS84 declarations, quotas or waypoint limits from unrelated REST/SDK documentation as if these pages specified them.

## Parameters, actions and defaults

“Action field” means needed to express that action; the references do not give a formal requiredness matrix. Optional map state generally defaults to the previous session.

| Field | Type/action | Format, values, default and limits |
| --- | --- | --- |
| `ll` | Optional float pair; map/search center | **Longitude,latitude**. Search area falls back to previous session if absent. |
| `z` | Optional integer; map/search | Native **1–18**, web **1–19**. 1 least detailed/world. No constant default; prior map state applies. Geo URI example uses `z`, but no separate Geo URI range specified. |
| `spn` | Optional float pair; map/search | Longitude span,latitude span in degrees; centered by `ll`. Ignored when `z` is present. No min/max given. |
| `l` | Optional string; map/search | `map`, `sat`, `skl`; native additionally lists `pmap`. Traffic `trf` alone or comma-combined, e.g. `map,trf`. Previous-session default. Routing explicitly does not accept a map-type override. |
| `pt` | Action float pair; placemark | **Longitude,latitude**. Without `ll`, center at `pt`. No custom marker title/description field specified. |
| Multiple `pt` points | Web marker action | `lon,lat~lon,lat`; web explicitly documents multiple markers. Native table only describes one marker. No maximum count given. |
| `text` | Action string; search | Query text, percent-encoded; `ll` plus `z` or `spn` scopes search, otherwise previous viewport. No length limit specified. |
| `oid` | Action integer; native organization | Unique organization ID. Web places it in `/maps/org/{oid}`. Source offers no numeric range; avoid precision loss when storing IDs. |
| `whatshere[point]` | Action float pair; object card | Geographic coordinates; examples consistently **longitude,latitude**. Shows street, stop, organization or other object at point. |
| `whatshere[zoom]` | Zoom for what's-here card | Native prose: integer **1–18**; native type column incorrectly says `float,float`. Web correctly says integer **1–19**. Default/mandatory status not specified. |
| `rtext` | Action coordinate sequence; route | **Latitude,longitude**, `~` separated. Native explicitly says start and end; web says “points on the route” but illustrates two. See omission/waypoint qualification below. |
| `rtt` | Optional string; route | Native `auto`, `mt`, `pd`; web additionally `bc`. Driving, transit, walking, cycling respectively. Android/web omission: previous route type, falling back to driving; iOS prose says driving. |
| `panorama[point]` | Action float pair; panorama | **Longitude,latitude** of panorama position. |
| `panorama[direction]` | Float pair; panorama view | Azimuth,elevation angle, in degrees; source states accepted 0–360 degrees without separate elevation bounds. Do not silently substitute SDK angular constraints. Requiredness/default not stated. |
| `panorama[span]` | Float pair; panorama viewport | Horizontal,vertical angular size in degrees; requiredness/default/range not stated. |

User strings and query components must be URL-encoded once. Official examples use `%20` for spaces and UTF-8 escaping examples; bracketed keys are shown literally. The repository uses Dart query encoding (including encoded commas and spaces as `+`); equivalent decoding must preserve the coordinate and tilde grammar. No callbacks, return URL, navigation completion, avoidances, departure times, route optimization, or explicit auto-start-navigation flag are documented. Native route text says routes account for traffic; a route display is not a promise that turn-by-turn guidance starts.

## Empty origin plus waypoints: what is and is not established

Native route sections prescribe explicit start/end pairs; they do not document an empty first `rtext` token or an empty-origin/multi-waypoint example. The web reference says “points” but supplies no missing-origin rule or waypoint maximum. Multiple placemarks are a separate documented feature.

With two waypoints and no origin, the builder emits decoded `rtext=~W1lat,W1lon~W2lat,W2lon~Dlat,Dlon`. Current-location routing for that combination is unverified. Removing the first empty token changes the serialized origin to the first waypoint.

Search found generated public Maps URLs with `rtext=~destination` and third-party wrappers using the same pattern. That is secondary/observational evidence of usage only, not primary documentation of the combined case. Navigator's distinct `lat_from`/`lat_via_N` API also cannot establish Maps behavior. Likewise, [REST route waypoints](https://yandex.ru/maps-api/docs/router-api/request.html) and [JavaScript multiroutes](https://yandex.com/dev/jsapi-v2-1/doc/en/v2-1/dg/concepts/router/about) are unrelated embedded/server APIs; their 25/50/unlimited point limits do not belong in this URL contract.

## Plugin limitations

Code: [Maps builder](../../lib/src/maps/yandex_maps.dart), [capabilities](../../lib/src/maps/map_app.dart), [encoding](../../lib/src/utils/url_builder.dart), [launch extras](../../lib/src/utils/launch_helper.dart).

| Capability | Implementation | Assessment |
| --- | --- | --- |
| Marker | `pt=lnglat`, optional `z`, fixed `l=map`; same fields for HTTPS/native | Correct documented order and marker/map fields. No provider-level native/web zoom-range distinction or validation. Title ignored; no documented title field omitted. |
| Directions | `rtext` from origin-or-empty, waypoints, destination in `latlng` order | Correct documented route coordinate orientation. Empty origin and native multi-point semantics remain unverified. |
| Travel modes | `auto`, `pd`, `mt`, `bc` on both families | First three documented natively; `bc` only documented in the web reference. **Native contract discrepancy**, not demonstrated rejection. |
| Null mode | Omits `rtt` | Allows provider/session defaults; does not guarantee driving on Android/web even though helper switch has a null-to-auto branch. |
| Waypoint flag | `supportsWaypoints=true` globally | Broader than explicit native documentation; no app-specific limit enforced. |
| Search | No builders; flags false | Documented `text` search is omitted. |
| Other actions | No center-only, organization, multiple marker, what's-here or panorama API | Documented capabilities omitted; root scheme/path changes cannot always be represented as extras. |
| Extras | No typed Maps extra; query append | Absent options can be appended at launch. Identical built-in values are retained once; conflicts exclude discovery entries or cause `MapLaunchException` on explicit launch. Paths/actions cannot be changed. |
