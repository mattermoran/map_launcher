# Yandex Maps: external launch audit

Checked **2026-10-02** against [8aa7a6e](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131), fetched and verified on `origin/master`. Documentation research only; **no device testing**.

## Status and sources

**Marker URLs match the documented coordinate order. Native bicycle routing, native multi-point routing, and especially empty-origin routes with waypoints are not established by the public launch documentation inspected.** This is a support-evidence gap, not proof the apps reject them.

Primary documentation, read in full from server HTML:

- [Android launch reference](https://yandex.com/dev/yandex-apps-launch-maps/doc/en/concepts/yandexmaps-android-app): applies to **app version 4+**.
- [iOS launch reference](https://yandex.com/dev/yandex-apps-launch-maps/doc/en/concepts/yandexmaps-ios-app): applies to **app version 7.1.1+**.
- [Web launch reference](https://yandex.com/dev/yandex-apps-launch-maps/doc/en/concepts/yandexmaps-web): web URL grammar.
- [Launch product index](https://yandex.com/dev/yandex-apps-launch): distinguishes Maps from Navigator and Metro.

No publication/update dates were displayed. The iOS HTML identifies documentation revision `r19109751`; it is a content revision, **not an app release version/date**. These remain official pages but contain legacy-looking fields such as Public Map and old native API examples. Do not turn that observation into an unsupported claim of deprecation.

**Access limitation recovered:** the page reader returned only an “out of date browser” notice. `curl -L` retrieved the full server-rendered HTML; the substantive `.yfm` article and its tables were read, excluding duplicated tooltip definitions. No browser/app interaction was used to validate launch behavior. Search results from third-party wrappers and generated Maps links were not treated as a specification.

## Native and universal URL families

Sources: [Android](https://yandex.com/dev/yandex-apps-launch-maps/doc/en/concepts/yandexmaps-android-app), [iOS](https://yandex.com/dev/yandex-apps-launch-maps/doc/en/concepts/yandexmaps-ios-app), [web](https://yandex.com/dev/yandex-apps-launch-maps/doc/en/concepts/yandexmaps-web).

| Family | Launch actions | Platform/notes |
| --- | --- | --- |
| `yandexmaps://maps.yandex.com/?…` | Open map, placemark, text search, organization card, route | Android `ACTION_VIEW`; iOS `openURL`. Official examples also use `maps.yandex.ru`. |
| `yandexmaps://?…` | What's-here object card and panorama | Root custom-scheme examples use bracketed query keys. No host required in those examples. |
| `https://yandex.ru/maps/?…` | Map, marker(s), search, route, what's-here, panorama | Public web launch contract. Repository uses `.com/maps/`; official docs also use `.com` for organization URLs. App interception/fallback varies by platform and is not proved merely by HTTPS syntax. |
| `https://yandex.com/maps/org/{oid}` | Organization card | ID is a **path component**, unlike native `oid` query field. `.ru` also appears in examples. |
| `geo:lat,lon?z=…` | Open map center | Android-only alternative explicitly documented, e.g. `geo:47.6,-122.3?z=11`; chooser may appear for multiple handlers. No separate search or navigation Geo URI contract specified by this reference. |

These pages name geographic longitude/latitude, use decimal-degree examples and degree spans, but do not explicitly state datum, latitude/longitude bounds or maximum URL length. Do not import WGS84 declarations, quotas or waypoint limits from unrelated REST/SDK documentation as if these pages specified them.

## Parameters, actions and defaults

Sources adjacent to this table: [native Android](https://yandex.com/dev/yandex-apps-launch-maps/doc/en/concepts/yandexmaps-android-app), [native iOS](https://yandex.com/dev/yandex-apps-launch-maps/doc/en/concepts/yandexmaps-ios-app), [web differences](https://yandex.com/dev/yandex-apps-launch-maps/doc/en/concepts/yandexmaps-web). “Action field” below means needed to express that action; the source does not give a formal mandatory/optional matrix for every parameter. Other map options are optional and omitted map state generally uses the previous user session.

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

The [native route sections](https://yandex.com/dev/yandex-apps-launch-maps/doc/en/concepts/yandexmaps-ios-app) prescribe explicit start and end coordinate pairs. They **do not document an empty first `rtext` token**, nor a combined empty-origin/multi-waypoint example or limit. The [web reference](https://yandex.com/dev/yandex-apps-launch-maps/doc/en/concepts/yandexmaps-web) uses the plural “points”, but supplies no missing-origin rule or waypoint maximum. Do not confuse its explicitly documented multiple **placemarks** with multiple route points.

The builder emits decoded `rtext=~W1lat,W1lon~W2lat,W2lon~Dlat,Dlon` when origin is omitted and two waypoints are supplied. This is an observation about our code, **not verified current-location routing behavior**. It intentionally preserves an empty first token; simply removing that token would make the first waypoint a candidate origin and can drop the requested current-position leg. Do not “fix” the leading tilde by filtering empty entries without an explicit product decision and tests.

Search found generated public Maps URLs with `rtext=~destination` and third-party wrappers using the same pattern. That is secondary/observational evidence of usage only, not primary documentation of the combined case. Navigator's distinct `lat_from`/`lat_via_N` API also cannot establish Maps behavior. Likewise, [REST route waypoints](https://yandex.ru/maps-api/docs/router-api/request.html) and [JavaScript multiroutes](https://yandex.com/dev/jsapi-v2-1/doc/en/v2-1/dg/concepts/router/about) are unrelated embedded/server APIs; their 25/50/unlimited point limits do not belong in this URL contract.

## Implementation comparison and gaps

Inspected [Maps builder](../../lib/src/maps/yandex_maps.dart), [base capabilities](../../lib/src/maps/map_app.dart), [query builder](../../lib/src/utils/url_builder.dart), and [generic extras](../../lib/src/utils/launch_helper.dart).

| Capability | Implementation | Assessment |
| --- | --- | --- |
| Marker | `pt=lnglat`, optional `z`, fixed `l=map`; same fields for HTTPS/native | Correct documented order and marker/map fields. No provider-level native/web zoom-range distinction or validation. Title ignored; no documented title field omitted. |
| Directions | `rtext` from origin-or-empty, waypoints, destination in `latlng` order | Correct documented route coordinate orientation. Empty origin and native multi-point semantics remain unverified. |
| Travel modes | `auto`, `pd`, `mt`, `bc` on both families | First three documented natively; `bc` only documented in the web reference. **Native contract discrepancy**, not demonstrated rejection. |
| Null mode | Omits `rtt` | Allows provider/session defaults; does not guarantee driving on Android/web even though helper switch has a null-to-auto branch. |
| Waypoint flag | `supportsWaypoints=true` globally | Broader than explicit native documentation; no app-specific limit enforced. |
| Search | No builders; flags false | Documented `text` search is omitted. |
| Other actions | No center-only, organization, multiple marker, what's-here or panorama API | Documented capabilities omitted; root scheme/path changes cannot always be represented as extras. |
| Extras | No typed Maps extra; query append | Can append absent options but does not replace existing `pt`, `l`, `rtext` or `rtt`; duplicate keys have unverified provider precedence. |

## Concrete proposed tests (not executed)

1. Decode generated marker and route URLs for `(lat=59.944869, lon=30.335429)` and asymmetric origin/waypoints; assert marker longitude-first versus route latitude-first on HTTPS, Android and iOS.
2. Exact empty-origin cases: 0, 1 and 2 waypoints; assert `~D`, `~W1~D`, `~W1~W2~D` and retention of every requested point. Also test explicit origin. These unit checks only protect serialization, not app acceptance.
3. Native device matrix for those cases, permission allowed/denied, location available/unavailable, all four modes and recorded app versions. Verify each waypoint and actual first leg, not merely app launch. Resolve native `bc` separately from web support.
4. Native zoom 1/18/19 and web 1/19/20; agree a validation policy rather than claiming the builder currently clamps. Search Unicode/reserved-character encoding if implemented.
5. Omit mode after a prior transit route on each platform to test documented default differences; test extras collisions before recommending overrides.
